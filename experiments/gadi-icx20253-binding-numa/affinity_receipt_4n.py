#!/usr/bin/env python3
"""Record allowed CPUs before exec, or validate a 416-rank/four-host placement pair."""
import collections
import glob
import json
import os
from pathlib import Path
import socket
import sys


def rows(folder):
    result = [json.loads(p.read_text()) for p in sorted(Path(folder).glob('rank-*.json'))]
    assert len(result) == 416 and {r['rank'] for r in result} == set(range(416)), 'incomplete ranks'
    hosts = {r['host'] for r in result}
    assert len(hosts) == 4, 'host count'
    for host in hosts:
        group = [r for r in result if r['host'] == host]
        assert len(group) == 104 and {r['local_rank'] for r in group} == set(range(104)), 'local ranks'
        assert len({r['rank']//104 for r in group}) == 1, 'rank block crosses hosts'
    assert all(r['cpus'] and r['cores'] and r['numa'] for r in result), 'ambiguous placement'
    return sorted(result, key=lambda r: r['rank'])


def core_check(data):
    assert all(len(r['cores']) == 1 and len(r['numa']) == 1 for r in data), 'not one physical core per rank'
    assert len({(r['host'],tuple(r['cores'][0])) for r in data}) == 416, 'shared physical cores'


mode = sys.argv[1]
if mode == 'record':
    folder = Path(sys.argv[2])
    rank = int(os.environ['OMPI_COMM_WORLD_RANK'])
    cpus = sorted(os.sched_getaffinity(0))
    cores, numa = set(), set()
    for cpu in cpus:
        base = Path('/sys/devices/system/cpu') / ('cpu%d' % cpu)
        cores.add((int((base/'topology/physical_package_id').read_text()),
                   int((base/'topology/core_id').read_text())))
        numa.update(int(Path(p).name[4:]) for p in glob.glob(str(base/'node[0-9]*')))
    status = Path('/proc/self/status').read_text().splitlines()
    mems = next((s.split(':',1)[1].strip() for s in status if s.startswith('Mems_allowed_list:')), 'unknown')
    data = dict(rank=rank, local_rank=int(os.environ['OMPI_COMM_WORLD_LOCAL_RANK']),
                host=socket.gethostname(), cpus=cpus, cores=sorted(cores), numa=sorted(numa),
                mems_allowed_list=mems, pid=os.getpid(), phase='pre-exec')
    with (folder/('rank-%d.json' % rank)).open('x') as f:
        json.dump(data, f, sort_keys=True); f.write('\n')
    if len(sys.argv) > 3:
        command = sys.argv[3:]
        assert os.path.isabs(command[0]), 'exec target must be absolute'
        os.execv(command[0], command)
elif mode == 'validate':
    data = rows(sys.argv[2])
    if sys.argv[3] == 'core': core_check(data)
    print(json.dumps(dict(ranks=416, core_widths=dict(collections.Counter(len(r['cores']) for r in data)),
                         numa_masks=dict(collections.Counter(','.join(map(str,r['numa'])) for r in data))), sort_keys=True))
elif mode == 'compare':
    a,b = rows(sys.argv[2]), rows(sys.argv[3]); core_check(b)
    for x,y in zip(a,b):
        assert (x['host'],x['local_rank']) == (y['host'],y['local_rank']), 'rank placement changed'
        assert set(map(tuple,y['cores'])) <= set(map(tuple,x['cores'])), 'core binding changed rank NUMA placement'
        assert set(y['cpus']) <= set(x['cpus']), 'core CPU mask outside default mask'
    different = any(x['cpus'] != y['cpus'] for x,y in zip(a,b))
    print(json.dumps(dict(can_run_binding=different, ranks=416, hosts=sorted({r['host'] for r in a}),
                         core_distinct_physical_cores=416, core_within_default=True), sort_keys=True))
else:
    raise SystemExit('unknown mode')
