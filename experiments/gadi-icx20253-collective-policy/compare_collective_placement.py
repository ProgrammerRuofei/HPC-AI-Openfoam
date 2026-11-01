#!/usr/bin/env python3
"""Require identical pre-exec CPU/rank placement for this collective-only comparison."""
from pathlib import Path
import sys,json,collections

def rows(folder):
    data=[json.loads(p.read_text()) for p in Path(folder).glob('rank-*.json')]
    assert len(data)==416 and {r['rank'] for r in data}==set(range(416))
    hosts=collections.Counter(r['host'] for r in data);assert len(hosts)==4 and set(hosts.values())=={104}
    return sorted(data,key=lambda r:r['rank'])
a,b=rows(sys.argv[1]),rows(sys.argv[2])
for x,y in zip(a,b):
    for key in ('rank','local_rank','host','cpus','cores','numa','mems_allowed_list'):
        assert x[key]==y[key], (x['rank'],key,'placement changed')
print(json.dumps({'ranks':416,'hosts':sorted({r['host'] for r in a}), 'pre_exec_placement_identical':True}))
