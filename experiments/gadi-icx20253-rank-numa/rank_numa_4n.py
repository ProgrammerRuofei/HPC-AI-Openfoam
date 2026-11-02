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
elif mode == 'prepare':
    base=rows(sys.argv[2]);core_check(base)
    import csv,re
    table=list(csv.DictReader(open(sys.argv[3])))
    assert len(table)==416 and [int(x['rank']) for x in table]==list(range(416))
    logical={}
    for m in re.finditer(r'Rank (\d+) bound to package\[(\d+)\]\[core:L(\d+)\]',Path(sys.argv[4]).read_text()):
        rank,sock,core=map(int,m.groups());assert rank not in logical
        assert base[rank]['cores'][0][0]==sock
        logical[rank]=core
    assert set(logical)==set(range(416))
    for node in range(4):
        block=base[node*104:(node+1)*104]
        assert len({logical[x['rank']] for x in block})==104
        assert collections.Counter(x['numa'][0] for x in block)=={i:13 for i in range(8)}
        assert {int(x['candidate_slot']) for x in table[node*104:(node+1)*104]}==set(range(104))
    for arm in ['control','candidate']:
        lines=[]
        for rank,row in enumerate(table):
            assert int(row['node_index'])==rank//104 and int(row['control_slot'])==rank%104
            assert base[rank]['numa']==[int(row['control_numa'])]
            slot=rank%104 if arm=='control' else int(row['candidate_slot'])
            dest=base[104*(rank//104)+slot]
            assert dest['host']==base[rank]['host']
            assert dest['cores'][0][0]==base[rank]['cores'][0][0]==int(row['socket_preserved'])
            if arm=='candidate':assert dest['numa']==[int(row['candidate_numa'])]
            lines.append('rank %d=%s slot=%d\n'%(rank,dest['host'],logical[dest['rank']]))
        with (Path(sys.argv[2]).parent/(arm+'.rankfile')).open('x') as f:f.writelines(lines)
    print(json.dumps({'ranks':416,'hosts':4,'rankfiles':['control','candidate'],'logical_core_ids_measured':True}))
elif mode == 'check':
    import csv
    base=rows(sys.argv[2]);data=rows(sys.argv[3]);core_check(base);core_check(data)
    table=list(csv.DictReader(open(sys.argv[4])));arm=sys.argv[5];assert arm in ['control','candidate']
    changes=[0,0,0,0]
    for rank,x in enumerate(data):
        slot=rank%104 if arm=='control' else int(table[rank]['candidate_slot'])
        y=base[(rank//104)*104+slot]
        for k in ['host','cpus','cores','numa','mems_allowed_list']:assert x[k]==y[k],(rank,k)
        assert x['local_rank']==rank%104
        changes[rank//104]+=x['cpus']!=base[rank]['cpus']
    assert changes==([0,0,0,0] if arm=='control' else [3,6,10,2])
    print(json.dumps({'ranks':416,'changed_masks_by_node':changes,'same_node_socket':True}))
elif mode == 'mpi':
    placement=rows(sys.argv[2]);data=sorted([json.loads(p.read_text()) for p in Path(sys.argv[3]).glob('rank-*.json')],key=lambda x:x['rank'])
    assert len(data)==416 and [x['rank'] for x in data]==list(range(416))
    for rank,x in enumerate(data):
        y=placement[rank]
        assert x['size']==416 and x['sum']==86320 and x['ring_from']==(rank+415)%416
        assert x['pre_cpus']==x['post_cpus']==y['cpus'] and x['host']==y['host']
        assert x['ucp_path'] and x['ucp_version']!='MISSING'
    assert len({(x['ucp_path'],x['ucp_version']) for x in data})==1
    print(json.dumps({'ranks':416,'sum':86320,'ring':True,'pre_post_affinity_match':True,'runtime_UCP':sorted({(x['ucp_path'],x['ucp_version']) for x in data})}))
else:
    raise SystemExit('unknown mode')
