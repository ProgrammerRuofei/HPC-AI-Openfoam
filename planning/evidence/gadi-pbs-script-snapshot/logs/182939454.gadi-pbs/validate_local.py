from pathlib import Path
import json,csv,hashlib,re,math,collections,sys
root=Path(sys.argv[1]);wt=Path('/Users/sofia/.codex/worktrees/gadi-gcc162-build/openfoam-aspire2a')
assert (root/'collection.json').exists(),'collection incomplete'
for line in (root/'SHA256SUMS').read_text().splitlines():
 dig,rel=line.split('  ',1);assert hashlib.sha256((root/rel).read_bytes()).hexdigest()==dig,rel
q=(root/'qstat-xf.txt').read_text();assert 'job_state = F' in q and 'Exit_status = 0' in q
out=(root/'run_rank_numa_pair_4n_v2.pbs.out').read_text();assert 'ICX20253_OMPI5010_RANK_NUMA_PAIR_4N_150STEP_V2_PASS' in out
assert (root/'evidence/exit-status.txt').read_text().strip()=='pair_exit_rc=0'
assert hashlib.sha256((root/'evidence/submitted-pair.pbs').read_bytes()).hexdigest()=='601e73fe815561997173f2a409aa82140790a23acc174889c1191414beba4e8c'
# Reviewed maps and scripts are local inputs, independently pinned by the archived expected-scripts receipt.
for line in (root/'evidence/expected-scripts.sha256').read_text().splitlines():
 dig,rel=line.split('  ',1);assert hashlib.sha256((wt/rel).read_bytes()).hexdigest()==dig,rel
mapping=list(csv.DictReader((wt/'experiments/gadi-icx20253-rank-numa/candidate-map-v1.csv').open()))
assert len(mapping)==416
results={};alldata={}
def load(folder,kind):
 rows=[json.loads(p.read_text()) for p in folder.glob('rank-*.json')];rows.sort(key=lambda x:x['rank'])
 assert len(rows)==416 and [x['rank'] for x in rows]==list(range(416)),kind
 hosts=collections.Counter(x['host'] for x in rows);assert len(hosts)==4 and set(hosts.values())=={104}
 return rows
for arm in ['control','candidate']:
 p=root/arm/'evidence';log=(p/'run.log').read_text();solver=(p/'simpleFoam.log').read_text()
 assert (p/'exit-status.txt').read_text().strip()=='script_exit_rc=0'
 assert f'ICX20253_OMPI5010_RANK_NUMA_4N_150STEP_{arm}_V2_PASS' in log
 for filename in ['10_decomposePar.log','20_renumberMesh.log','30_potentialFoam.log','40_applyBoundaryLayer.log','simpleFoam.log']:
  assert re.search(r'^End$',(p/filename).read_text(),re.M),filename
 assert 'Finalising parallel run' in solver
 assert [int(x) for x in re.findall(r'^Time = (\d+)\s*$',solver,re.M)]==list(range(1,151))
 t=float(re.findall(r'Average wall-clock time per time step\s*=\s*([0-9.eE+-]+)',solver)[-1]);assert math.isfinite(t) and t>0
 decomp=(p/'10_decomposePar.log').read_text();assert 'Decomposition method scotch' in decomp
 keep=[s.strip() for s in decomp.splitlines() if re.match(r'^Processor \d+$',s) or re.match(r'\s+Number of (cells|points|faces shared with processor|processor patches|processor faces|boundary faces)',s)]
 ghash=hashlib.sha256(json.dumps(keep,separators=(',',':')).encode()).hexdigest();assert ghash=='6c3d197ff7f601a68ed937fe736b99f9e2c280392cd802a3895a250b46c724b5'
 cells=[int(x) for x in re.findall(r'^\s+Number of cells = (\d+)',decomp,re.M)];assert len(cells)==416 and sum(cells)==65334765
 assert (p/'partition-identity.txt').read_text().strip()==ghash
 # Expected scientific dictionaries were actually checked; master mesh was checked after solve.
 for line in (p/'expected-source.sha256').read_text().splitlines():assert line.split('  ',1)[1]+': OK' in log
 for key in ['gcc-16.2.0.181342083.gadi-pbs.tar.gz: OK','openmpi-5.0.10.181346004.gadi-pbs.tar.gz: OK','gadi-icx20253-ompi5010-of2512.181392981.gadi-pbs.tar.gz: OK','/bin/simpleFoam: OK']:assert key in log,key
 assert sum(x.endswith(': OK') for x in (p/'master-mesh-after.txt').read_text().splitlines())==5
 data={kind:load(p/kind,kind) for kind in ['baseline','placement','solver-affinity','mpi-runtime']}
 for kind in ['baseline','placement','solver-affinity']:
  a=data[kind];assert all(len(x['cores'])==len(x['numa'])==1 for x in a)
  assert len({(x['host'],tuple(x['cores'][0])) for x in a})==416
  for node in range(4):
   block=a[node*104:(node+1)*104];assert len({x['host'] for x in block})==1
   assert [x['local_rank'] for x in block]==list(range(104))
   assert collections.Counter(x['numa'][0] for x in block)=={i:13 for i in range(8)}
 base=data['baseline'];changes=[0]*4
 for i,row in enumerate(data['placement']):
  slot=i%104 if arm=='control' else int(mapping[i]['candidate_slot']);expected=base[(i//104)*104+slot]
  for k in ['host','cpus','cores','numa','mems_allowed_list']:
   assert row[k]==expected[k],(arm,i,k)
   assert data['solver-affinity'][i][k]==row[k],('solver',arm,i,k)
  assert row['host']==base[i]['host'] and row['cores'][0][0]==base[i]['cores'][0][0]
  changes[i//104]+=row['cpus']!=base[i]['cpus']
  runtime=data['mpi-runtime'][i];assert runtime['size']==416 and runtime['sum']==86320 and runtime['ring_from']==(i+415)%416
  assert runtime['pre_cpus']==runtime['post_cpus']==row['cpus'] and runtime['host']==row['host']
 assert changes==([0]*4 if arm=='control' else [3,6,10,2])
 ucp={(x['ucp_path'],x['ucp_version']) for x in data['mpi-runtime']};assert len(ucp)==1 and all(x[1]!='MISSING' for x in ucp)
 hostlines=[s.split() for s in (p/'rank-host-map.txt').read_text().splitlines()];assert len(hostlines)==416
 hostmap={int(x[0]):x[1] for x in hostlines};assert set(hostmap)==set(range(416))
 for i in range(416):assert hostmap[i]==base[i]['host']
 for node,idx in enumerate([0,104,208,312]):
  assert 'Xeon(R) Platinum 8470Q' in (p/f'lscpu-{idx}.txt').read_text()
  assert 'STAGE_4N_RUNTIME_PASS host='+base[idx]['host'] in (p/f'stage-runtime-{idx}.txt').read_text()
 coeff=[];columns=None
 for line in (p/'coefficient.dat').read_text().splitlines():
  if line.startswith('#'):
   fields=line.lstrip('#').split()
   if 'Time' in fields and 'Cd' in fields:columns=fields
  elif line.strip():
   fields=line.split();coeff.append((float(fields[0]),float(fields[columns.index('Cd')])))
 assert coeff and coeff[-1][0]==150 and all(math.isfinite(v) for row in coeff for v in row)
 assert 0.27<=coeff[-1][1]<=0.30
 results[arm]={'s_per_step':t,'final_cd':coeff[-1][1],'cd_points':len(coeff),'cells':sum(cells),'partition_sha256':ghash,'changed_masks_by_node':changes,'ucp':sorted(ucp),'hosts':sorted(set(hostmap.values())),'rank_receipts':sum(len(x) for x in data.values())}
 alldata[arm]={'data':data,'coeff':coeff}
a=root/'control/evidence';b=root/'candidate/evidence'
for file in ['case-inputs.sha256','source-mesh.sha256','partition-identity.txt']:assert (a/file).read_bytes()==(b/file).read_bytes(),file
for i in range(416):
 for k in ['rank','local_rank','host','cpus','cores','numa','mems_allowed_list']:assert alldata['control']['data']['baseline'][i][k]==alldata['candidate']['data']['baseline'][i][k]
assert results['control']['ucp']==results['candidate']['ucp']
ca=alldata['control']['coeff'];cb=alldata['candidate']['coeff'];assert [x[0] for x in ca]==[x[0] for x in cb]
maxcd=max(abs(x[1]-y[1]) for x,y in zip(ca,cb));assert maxcd<=1e-8
summary=json.loads((root/'evidence/pair-summary.json').read_text());assert summary['control_s_step']==results['control']['s_per_step'] and summary['candidate_s_step']==results['candidate']['s_per_step'] and summary['max_abs_Cd_difference']==maxcd
su=float(re.findall(r'Service Units:\s*([0-9.]+)',out)[-1]);assert su==474.01
report={'independent_acceptance':'PASS','job':'182939454.gadi-pbs','pbs_exit':0,'actual_su':su,'walltime_seconds':2051,'arms':results,'max_abs_cd_difference':maxcd,'candidate_improvement_percent':100*(results['control']['s_per_step']-results['candidate']['s_per_step'])/results['control']['s_per_step'],'limits':['one control-then-candidate pair, no repeatability claim','probe runtime selection does not prove every solver collective','pre-exec CPU affinity is not memory page residency','CPU/MPI flags unchanged; no causal mechanism identified']}
(root/'independent-validation.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report,indent=2))
