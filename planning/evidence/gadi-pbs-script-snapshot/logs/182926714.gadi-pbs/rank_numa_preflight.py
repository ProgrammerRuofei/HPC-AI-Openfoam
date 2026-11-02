#!/usr/bin/env python3
"""Prepare job-local rankfiles from measured logical core IDs; validate probe only."""
import csv,json,re,sys,collections
from pathlib import Path
mode=sys.argv[1];e=Path(sys.argv[2]);table=Path(sys.argv[3])
rows=list(csv.DictReader(table.open()));assert len(rows)==416
assert {int(r['rank']) for r in rows}==set(range(416))
for n in range(4):
 block=[r for r in rows if int(r['node_index'])==n]
 assert len(block)==104 and {int(r['candidate_slot']) for r in block}==set(range(104))
 for r in block:
  assert int(r['rank'])//104==n and int(r['control_slot'])==int(r['rank'])%104
  assert int(r['control_slot'])//52==int(r['candidate_slot'])//52==int(r['socket_preserved'])
top={}
for line in (e/'topology.csv').read_text().splitlines():
 if line.startswith('#'):continue
 cpu,core,socket,numa=map(int,line.split(','));top[cpu]=(socket,core,numa)
def read(name):
 data=[json.loads(p.read_text()) for p in (e/name).glob('rank-*.json')]
 assert len(data)==104 and {x['rank'] for x in data}==set(range(104))
 data=sorted(data,key=lambda x:x['rank']);assert len({x['host'] for x in data})==1
 for x in data:
  assert x['size']==104 and x['sum']==5356 and x['ring_from']==(x['rank']+103)%104
  assert x['pre_cpus']==x['post_cpus'] and x['post_cpus']
  assert len({top[c][:2] for c in x['post_cpus']})==1
  assert x['ucp_path'] and x['ucp_version']!='MISSING'
 assert len({top[x['post_cpus'][0]][:2] for x in data})==104
 return data
base=read('baseline')
for x in base:
 socket,core,numa=top[x['post_cpus'][0]]
 r=rows[x['rank']]
 assert socket==int(r['socket_preserved']) and numa==int(r['control_numa']), 'new allocation differs from topology template'
assert collections.Counter(top[x['post_cpus'][0]][2] for x in base)=={n:13 for n in range(8)}
if mode=='prepare':
 text=(e/'baseline.bindings.txt').read_text();logical={}
 for m in re.finditer(r'Rank (\d+) bound to package\[(\d+)\]\[core:L(\d+)\]',text):
  rank,socket,core=map(int,m.groups());assert rank not in logical;logical[rank]=core
  assert socket==top[base[rank]['post_cpus'][0]][0]
 assert set(logical)==set(range(104)) and len(set(logical.values()))==104
 host=base[0]['host']
 def emit(name,slots):
  with (e/(name+'.rankfile')).open('x') as f:
   for r,k in enumerate(slots):f.write('rank %d=%s slot=%d\n'%(r,host,logical[k]))
 emit('control',range(104))
 for n in range(4):emit('candidate-node%d'%n,[int(rows[104*n+r]['candidate_slot']) for r in range(104)])
 (e/'logical-core-map.json').write_text(json.dumps(logical,sort_keys=True)+'\n')
elif mode=='validate':
 report={}
 for name in ['control']+['candidate-node%d'%n for n in range(4)]:
  data=read(name);n=None if name=='control' else int(name[-1]);changed=0
  for r,x in enumerate(data):
   slot=r if n is None else int(rows[104*n+r]['candidate_slot'])
   y=base[slot]
   for key in ('pre_cpus','post_cpus','host','ucp_path','ucp_version'):assert x[key]==y[key],(name,r,key)
   changed+=x['post_cpus']!=base[r]['post_cpus']
  report[name]={'ranks':104,'changed_core_masks':changed,'pre_post_MPI_match':True,'allreduce_sum':5356,'ring_pass':True}
 assert sum(v['changed_core_masks'] for k,v in report.items() if k!='control')==21
 (e/'acceptance.json').write_text(json.dumps(report,indent=2)+'\n')
else:raise SystemExit('unknown mode')
