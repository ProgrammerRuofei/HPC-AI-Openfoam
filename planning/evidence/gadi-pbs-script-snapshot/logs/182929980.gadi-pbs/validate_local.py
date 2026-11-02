from pathlib import Path
import hashlib,json,csv,collections,re
import sys
p=Path(sys.argv[1])
assert (p/'collection-complete.json').exists()
for line in (p/'remote-sha256.txt').read_text().splitlines():
 h,n=line.split(None,1);n=n[2:] if n.startswith('./') else Path(n).name
 assert hashlib.sha256((p/n).read_bytes()).hexdigest()==h,n
q=(p/'qstat.txt').read_text();out=(p/'preflight_rank_numa_1n_v2.pbs.out').read_text()
assert re.search(r'Exit_status = 0\b',q) and 'job_state = F' in q
assert (p/'exit-status.txt').read_text()=='script_exit_rc=0\n'
assert 'ICX20253_OMPI5010_RANK_NUMA_PREFLIGHT_1N_V2_PASS' in out
assert hashlib.sha256((p/'submitted.pbs').read_bytes()).hexdigest()=='74a325010a6f0800860928faf9e7f5b1166131acb190f95a53e83c254e73c655'
expected={'rank_numa_probe.c':'693de09cc0d8adeec5cb6badd3c7218ffb1f013122fdbb4c9fb23ef86404f52b','rank_numa_preflight.py':'0e6cff53301a5c079e7b4824e2eeca25a167e47d1ecc91681d8d7d584945b431','candidate-map-v1.csv':'b82e7f750816a3f0b9fb5951ee7be00f83b2c75ec02e8be6454c4c7a8fda3c91'}
for n,h in expected.items():assert hashlib.sha256((p/n).read_bytes()).hexdigest()==h
rows=list(csv.DictReader((p/'candidate-map-v1.csv').open()));top={}
for l in (p/'topology.csv').read_text().splitlines():
 if not l.startswith('#'):
  c,core,sock,numa=map(int,l.split(','));top[c]=(sock,core,numa)
def read(name):
 data=sorted([json.loads(f.read_text()) for f in (p/name).glob('rank-*.json')],key=lambda x:x['rank'])
 assert len(data)==104 and [x['rank'] for x in data]==list(range(104))
 assert len({x['host'] for x in data})==1
 for x in data:
  assert x['size']==104 and x['sum']==5356 and x['ring_from']==(x['rank']+103)%104
  assert x['pre_cpus']==x['post_cpus'] and x['post_cpus']
  assert len({top[c][:2] for c in x['post_cpus']})==1
 assert len({top[x['post_cpus'][0]][:2] for x in data})==104
 assert collections.Counter(top[x['post_cpus'][0]][2] for x in data)=={i:13 for i in range(8)}
 return data
base=read('baseline');report={};allrows=base.copy()
for name in ['control']+[f'candidate-node{i}' for i in range(4)]:
 d=read(name);allrows+=d;changes=0
 for rank,x in enumerate(d):
  row=rows[rank if name=='control' else 104*int(name[-1])+rank];slot=rank if name=='control' else int(row['candidate_slot'])
  for k in ['pre_cpus','post_cpus','host','ucp_path','ucp_version']:assert x[k]==base[slot][k],(name,rank,k)
  assert top[x['post_cpus'][0]][0]==top[base[rank]['post_cpus'][0]][0]
  changes+=x['post_cpus']!=base[rank]['post_cpus']
 report[name]=changes
assert list(report.values())==[0,3,6,10,2]
assert len(allrows)==624
assert {x['ucp_path'] for x in allrows}=={'/usr/lib64/libucp.so.0'}
assert {x['ucp_version'] for x in allrows}=={'1.21.0'}
warn={}
for f in list(p.glob('*.stdout'))+list(p.glob('*.bindings.txt')):
 text=f.read_text();warn[f.name]={'unused_UCX_env':text.count('unused environment variables'),'MR_registration_failure':text.count('Failed to register MR')}
assert all(x['MR_registration_failure']==0 for x in warn.values())
result={'independent_local_validation':'PASS','job':'182929980.gadi-pbs','state':'F','exit_status':0,'walltime_s':48,'actual_SU':2.77,'memory_used_reported_GB':20.89,'jobfs_used_reported_GB':1.94,'host':base[0]['host'],'receipts':624,'changed_core_masks':report,'allreduce_sum':5356,'ring_pass':True,'pre_post_MPI_masks_equal':True,'each_launch_distinct_cores':104,'ranks_per_NUMA':13,'ucp_path':'/usr/lib64/libucp.so.0','ucp_version':'1.21.0','warnings':warn,'limits':['MPI probe only; no OpenFOAM performance or Cd','single node; candidate node blocks tested on same host','CPU masks do not establish memory-page placement','UCX/UCC module names do not establish effective collective selection']}

print(json.dumps(result,indent=2))
