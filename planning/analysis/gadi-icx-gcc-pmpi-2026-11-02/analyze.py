#!/usr/bin/env python3
"""Local-only, original-byte PMPI validation and comparison. No cluster access."""
import csv,io,json,math,re,statistics as st,tarfile,hashlib
from pathlib import Path
from collections import Counter,defaultdict
ROOT=Path(__file__).resolve().parents[3]
OUT=Path(__file__).resolve().parent
RAW=ROOT/'planning/evidence/gadi-pbs-script-snapshot/logs'
JOBS={'GCC':'181908113.gadi-pbs','ICX':'182940799.gadi-pbs'}
def quant(v):
 v=sorted(v)
 def p(q):
  pos=(len(v)-1)*q;i=int(pos);return v[i]+(v[min(i+1,len(v)-1)]-v[i])*(pos-i)
 return dict(mean=st.mean(v),median=st.median(v),p95=p(.95),min=v[0],max=v[-1])
def corr(a,b):
 am=st.mean(a);bm=st.mean(b);d=math.sqrt(sum((x-am)**2 for x in a)*sum((x-bm)**2 for x in b))
 return sum((x-am)*(y-bm) for x,y in zip(a,b))/d if d else None

def load(path):
 full={};buckets={};members=[]
 for arch in sorted((path/'pmpi-raw').glob('node-*.tar.gz')):
  with tarfile.open(arch,'r:gz') as tar:
   for m in tar:
    if not m.isfile() or not m.name.endswith('.csv'):continue
    assert m.name not in members;memb=m.name;members.append(memb)
    rows=list(csv.DictReader(io.TextIOWrapper(tar.extractfile(m))))
    rank=int(rows[0]['rank']);assert all(int(r['rank'])==rank for r in rows)
    dst=buckets if memb.endswith('-buckets.csv') else full
    assert rank not in dst;dst[rank]=rows
 assert set(full)==set(buckets)==set(range(416))
 for rank,rows in full.items():
  for r in rows:
   b=[x for x in buckets[rank] if x['call']==r['call']]
   assert sum(int(x['count']) for x in b)==int(r['count'])
   assert sum(int(x['total_ns']) for x in b)==int(r['total_ns'])
   assert max([int(x['max_ns']) for x in b] or [0])==int(r['max_ns'])
 return full,buckets

def partition(p):
 ranks={};edges={};cur=None
 for l in p.read_text().splitlines():
  m=re.fullmatch(r'Processor (\d+)',l)
  if m:cur=int(m[1]);ranks[cur]={};continue
  if cur is None:continue
  for label,key in [('cells','cells'),('processor faces','faces'),('boundary faces','boundary')]:
   m=re.fullmatch(r'    Number of '+label+r' = (\d+)',l)
   if m:ranks[cur][key]=int(m[1])
  m=re.search(r'faces shared with processor (\d+) = (\d+)',l)
  if m:edges[cur,int(m[1])]=int(m[2])
 assert len(ranks)==416
 for (a,b),v in edges.items():assert edges[b,a]==v
 for r in ranks:assert sum(v for (a,b),v in edges.items() if a==r)==ranks[r]['faces']
 return ranks,edges

def main():
 data={};summ={};output=[];graphs={}
 for name,j in JOBS.items():
  path=RAW/j;full,buck=load(path);data[name]=(full,buck)
  ranks,edges=partition(path/'10_decomposePar.log');graphs[name]=(ranks,edges)
  solver=(path/'simpleFoam.log').read_text();steps=list(map(int,re.findall(r'^Time = (\d+)$',solver,re.M)))
  assert steps==list(range(1,151));assert '\nEnd\n' in solver and 'Finalising parallel run' in solver
  for f in ['10_decomposePar.log','20_renumberMesh.log','30_potentialFoam.log','40_applyBoundaryLayer.log']:assert '\nEnd\n' in (path/f).read_text(),f
  assert 'script_exit_rc=0' in (path/'exit-status.txt').read_text()
  assert 'SCOTCH_4N_PMPI_PROFILE_PASS' in (path/'run.log').read_text()
  avg=float(re.findall(r'Average wall-clock time per time step = (\S+)',solver)[-1])
  coeff=[l.split() for l in (path/'coefficient.dat').read_text().splitlines() if l.strip() and not l.startswith('#')]
  assert len(coeff)==150;assert [float(r[0]) for r in coeff]==list(range(1,151));cd=float(coeff[-1][1]);assert .27<=cd<=.30
  hosts={r:full[r][0]['host'] for r in full};assert sorted(Counter(hosts.values()).values())==[104]*4
  maptext=(path/'rank-host-map.txt').read_text();assert {int(l.split()[0]):l.split()[1] for l in maptext.splitlines() if l.strip()}==hosts
  elapsed=[int(v[0]['elapsed_ns'])/1e9 for v in full.values()]
  calls=[r['call'] for r in full[0]]
  rawbar=[int(next(v for v in full[r] if v['call']=='MPI_Barrier')['total_ns'])/1e9 for r in full]
  unique_cross=sum(v for (a,b),v in edges.items() if a<b and hosts[a]!=hosts[b])
  summ[name]={'job':j,'avg_step_s':avg,'Cd':cd,'steps':len(steps),'timed_steps':149,'hosts':dict(Counter(hosts.values())),'reports':416,'bucket_reports':416,'full_bucket_reconciliation':'PASS','elapsed_s':quant(elapsed),'full_barrier_s':quant(rawbar),'cells':sum(r['cells'] for r in ranks.values()),'unique_faces':sum(r['faces'] for r in ranks.values())//2,'unique_cross_node_faces':unique_cross,'calls':calls,'windows':{}}
  summ[name]['barrier_buckets']={str(w):sum(int(x['total_ns']) for rows in buck.values() for x in rows if x['call']=='MPI_Barrier' and int(x['window_start_s'])==w)/416e9 for w in sorted({int(x['window_start_s']) for rows in buck.values() for x in rows if x['call']=='MPI_Barrier'})}
 common_end=int(min(summ[n]['elapsed_s']['min'] for n in summ)//10)*10
 windows={'full':(0,None),'steady70':(70,None),'common70':(70,common_end),'common80':(80,common_end),'common100':(100,common_end)}
 for name,(full,buck) in data.items():
  ranks,edges=graphs[name];s=summ[name];s['common_end_s']=common_end
  for window,(low,high) in windows.items():
   stats={};rankrows=[]
   for rank in range(416):
    row={'stack':name,'window':window,'rank':rank,'host':full[rank][0]['host'],'cells':ranks[rank]['cells'],'processor_faces':ranks[rank]['faces']}
    selected=[x for x in buck[rank] if int(x['window_start_s'])>=low and (high is None or int(x['window_start_s'])<high)]
    for c in s['calls']:
     v=[x for x in selected if x['call']==c]
     row[c+'_s']=sum(int(x['total_ns']) for x in v)/1e9
     row[c+'_count']=sum(int(x['count']) for x in v)
    row['timed_MPI_nonBarrier_s']=sum(row[c+'_s'] for c in s['calls'] if c!='MPI_Barrier')
    rankrows.append(row);output.append(row)
   for c in s['calls']:
    stats[c]={'seconds_per_rank':quant([r[c+'_s'] for r in rankrows]),'global_calls':sum(r[c+'_count'] for r in rankrows)}
   stats['timed_MPI_nonBarrier_s']=quant([r['timed_MPI_nonBarrier_s'] for r in rankrows])
   stats['corr_faces_waitall']=corr([r['processor_faces'] for r in rankrows],[r['MPI_Waitall_s'] for r in rankrows])
   stats['slowest_waitall']=sorted([{'rank':r['rank'],'host':r['host'],'faces':r['processor_faces'],'waitall_s':r['MPI_Waitall_s']} for r in rankrows],key=lambda r:r['waitall_s'],reverse=True)[:10]
   stats['node_mean_waitall_s']={h:st.mean(r['MPI_Waitall_s'] for r in rankrows if r['host']==h) for h in s['hosts']}
   s['windows'][window]=stats
  s['bucket_timeline']={str(w):{c:sum(int(x['total_ns']) for rows in buck.values() for x in rows if x['call']==c and int(x['window_start_s'])==w)/416e9 for c in ['MPI_Waitall','MPI_Allreduce','MPI_Barrier']} for w in sorted({int(x['window_start_s']) for rows in buck.values() for x in rows})}
 count_mismatch=[(r,a['call']) for r in range(416) for a,b in zip(data['GCC'][0][r],data['ICX'][0][r]) if a['call']!=b['call'] or a['count']!=b['count']]
 summ['comparison']={'per_rank_full_call_count_mismatches':count_mismatch,'partition_equal':graphs['GCC']==graphs['ICX'],'science_inputs_equal':(RAW/JOBS['GCC']/'case-inputs.sha256').read_bytes()==(RAW/JOBS['ICX']/'case-inputs.sha256').read_bytes(),'source_manifest_equal':(RAW/JOBS['GCC']/'expected-source.sha256').read_bytes()==(RAW/JOBS['ICX']/'expected-source.sha256').read_bytes(),'diagnostic_ICX_faster_pct':100*(1-summ['ICX']['avg_step_s']/summ['GCC']['avg_step_s'])}
 assert summ['comparison']['partition_equal'];assert summ['comparison']['science_inputs_equal']
 with (OUT/'rank-metrics.csv').open('w',newline='') as f:
  w=csv.DictWriter(f,fieldnames=output[0].keys(),lineterminator='\n');w.writeheader();w.writerows(output)
 (OUT/'summary.json').write_text(json.dumps(summ,indent=2)+'\n')
 print(json.dumps({n:{k:v for k,v in s.items() if k not in ['windows','bucket_timeline']} for n,s in summ.items()},indent=2))
 for window in windows:
  print(window)
  for call in ['MPI_Waitall','MPI_Allreduce','MPI_Isend','MPI_Irecv','MPI_Send','MPI_Recv']:
   print(call,[(n,summ[n]['windows'][window][call]) for n in JOBS])
if __name__=='__main__':main()
