#!/usr/bin/env python3
"""Local-only graph screening. Never emits a runnable rankfile or accesses Gadi."""
from pathlib import Path
import csv,hashlib,json,re,collections,math
ROOT=Path(__file__).resolve().parents[3]
OUT=Path(__file__).resolve().parent
RAW=ROOT/'planning/evidence/gadi-pbs-script-snapshot/logs'
inputs=[]
def verified(job,rel):
 p=RAW/job/rel
 manifest={line.split('  ',1)[1]:line.split('  ',1)[0] for line in (RAW/job/'SHA256SUMS').read_text().splitlines()}
 h=hashlib.sha256(p.read_bytes()).hexdigest();assert manifest[rel]==h,(job,rel)
 inputs.append({'file':str(p.relative_to(ROOT)),'sha256':h,'verified_against_archived_manifest':True})
 return p
job='182830268.gadi-pbs'
log=verified(job,'default/10_decomposePar.log').read_text()
cells={};reported_faces={};directed={};rank=None
for line in log.splitlines():
 m=re.fullmatch(r'Processor (\d+)',line)
 if m:rank=int(m[1]);continue
 if rank is None:continue
 m=re.fullmatch(r'    Number of cells = (\d+)',line)
 if m:cells[rank]=int(m[1])
 m=re.fullmatch(r'    Number of processor faces = (\d+)',line)
 if m:reported_faces[rank]=int(m[1])
 m=re.fullmatch(r'    Number of faces shared with processor (\d+) = (\d+)',line)
 if m:directed[(rank,int(m[1]))]=int(m[2])
assert set(cells)==set(range(416))
for (a,b),w in directed.items():assert directed[b,a]==w
edges=sorted((a,b,w) for (a,b),w in directed.items() if a<b)
for r in cells:assert sum(w for (a,b),w in directed.items() if a==r)==reported_faces[r]
gcc=ROOT/'results/gadi-gcc162-ompi5010-scotch/pmpi-181908113-rank-edges.csv'
gcc_edges=sorted((int(r['rank_a']),int(r['rank_b']),int(r['faces'])) for r in csv.DictReader(gcc.open()))
assert edges==gcc_edges,'ICX graph differs from GCC PMPI graph'
inputs.append({'file':str(gcc.relative_to(ROOT)),'sha256':hashlib.sha256(gcc.read_bytes()).hexdigest(),'verified_against_archived_manifest':False,'role':'derived GCC cross-check; ICX raw log is primary'})
hosts={int(l.split()[0]):l.split()[1] for l in verified(job,'default/rank-host-map.txt').read_text().splitlines()}
assert set(hosts)==set(cells)
assert len(set(hosts.values()))==4
for n in range(4):assert len({hosts[r] for r in range(104*n,104*(n+1))})==1
# P0 Linux topology and core receipts are a historical template only.
p0='182588070.gadi-pbs'
top={}
for l in verified(p0,'topology.csv').read_text().splitlines():
 if l.startswith('#'):continue
 cpu,core,socket,numa=map(int,l.split(','));top[cpu]=(core,socket,numa)
slot={}
for r in range(104):
 j=json.loads(verified(p0,f'core/rank-{r}.json').read_text())
 assert j['rank']==r and len(j['cpus'])==1 and len(j['numa'])==1
 cpu=j['cpus'][0];core,socket,numa=top[cpu]
 assert j['numa']==[numa] and j['cores'][0][0]==socket
 slot[r]={'cpu':cpu,'socket':socket,'numa':numa,'template_core':core}
assert len({s['cpu'] for s in slot.values()})==104
assert collections.Counter(s['numa'] for s in slot.values())=={n:13 for n in range(8)}
# Four-node Open MPI binding text independently confirms rank r -> logical core r%104.
bind=verified('182637290.gadi-pbs','core/evidence/placement.bindings.txt').read_text()
observed={}
for m in re.finditer(r'Rank (\d+) bound to package\[(\d+)\]\[core:L(\d+)\]',bind):
 r,so,core=map(int,m.groups());assert r not in observed;observed[r]=(so,core)
assert set(observed)==set(cells)
for r,(so,c) in observed.items():assert c==r%104 and so==slot[r%104]['socket']
node={r:r//104 for r in cells};socket={r:slot[r%104]['socket'] for r in cells}
base={r:slot[r%104]['numa'] for r in cells};candidate=base.copy()
adj=collections.defaultdict(dict)
for a,b,w in edges:adj[a][b]=w;adj[b][a]=w
swaps=[]
def groupcells(mapping):
 sums=collections.Counter()
 for r in cells:sums[node[r],mapping[r]]+=cells[r]
 return sums
# Deterministic best-improving swaps, no random starts or measured timings used.
for n in range(4):
 for so in range(2):
  ranks=[r for r in cells if node[r]==n and socket[r]==so]
  domains=sorted({base[r] for r in ranks});assert len(ranks)==52 and len(domains)==4
  cap=max(groupcells(base)[n,d] for d in domains)
  while True:
   loads=groupcells(candidate);best=None
   for i,a in enumerate(ranks):
    for b in ranks[i+1:]:
     ga,gb=candidate[a],candidate[b]
     if ga==gb:continue
     if loads[n,ga]-cells[a]+cells[b]>cap or loads[n,gb]-cells[b]+cells[a]>cap:continue
     delta=0
     for v,w in adj[a].items():
      if v!=b and node[v]==n and socket[v]==so:delta+=w*((gb!=candidate[v])-(ga!=candidate[v]))
     for v,w in adj[b].items():
      if v!=a and node[v]==n and socket[v]==so:delta+=w*((ga!=candidate[v])-(gb!=candidate[v]))
     if delta<0 and (best is None or (delta,a,b)<best):best=(delta,a,b)
   if best is None:break
   delta,a,b=best;candidate[a],candidate[b]=candidate[b],candidate[a]
   swaps.append({'node_index':n,'socket':so,'rank_a':a,'rank_b':b,'face_cut_delta':delta})
# Bounded deterministic look-ahead: allow temporary non-improving swaps,
# commit only the best strictly improving prefix. Every step honors load caps.
lookahead_commits=[]
for n in range(4):
 for so in range(2):
  ranks=[r for r in cells if node[r]==n and socket[r]==so]
  domains=sorted({base[r] for r in ranks});cap=max(groupcells(base)[n,d] for d in domains)
  for pass_id in range(6):
   trial=candidate.copy();free=set(ranks);history=[];cumulative=0;best_total=0;best_prefix=0
   while len(free)>1:
    loads=groupcells(trial);best=None;rr=sorted(free)
    for i,a in enumerate(rr):
     for b in rr[i+1:]:
      ga,gb=trial[a],trial[b]
      if ga==gb:continue
      if loads[n,ga]-cells[a]+cells[b]>cap or loads[n,gb]-cells[b]+cells[a]>cap:continue
      delta=0
      for v,w in adj[a].items():
       if v!=b and node[v]==n and socket[v]==so:delta+=w*((gb!=trial[v])-(ga!=trial[v]))
      for v,w in adj[b].items():
       if v!=a and node[v]==n and socket[v]==so:delta+=w*((ga!=trial[v])-(gb!=trial[v]))
      if best is None or (delta,a,b)<best:best=(delta,a,b)
    if best is None:break
    delta,a,b=best;trial[a],trial[b]=trial[b],trial[a];free.remove(a);free.remove(b)
    cumulative+=delta;history.append((a,b,delta))
    if cumulative<best_total:best_total=cumulative;best_prefix=len(history)
   if best_prefix==0:break
   for a,b,delta in history[:best_prefix]:candidate[a],candidate[b]=candidate[b],candidate[a]
   lookahead_commits.append({'node':n,'socket':so,'pass':pass_id,'delta':best_total,'swaps':history[:best_prefix]})
# Map candidate groups onto the same historical physical slots; no rankfile emitted.
target={}
for n in range(4):
 for d in range(8):
  ranks=sorted(r for r in cells if node[r]==n and candidate[r]==d)
  slots=sorted(k for k,v in slot.items() if v['numa']==d)
  assert len(ranks)==len(slots)==13
  kept=[r for r in ranks if base[r]==d]
  for r in kept:target[r]=r%104
  free_slots=[k for k in slots if k not in {r%104 for r in kept}]
  for r,k in zip([r for r in ranks if r not in kept],free_slots):target[r]=k
for n in range(4):assert {target[r] for r in cells if node[r]==n}==set(range(104))
for r in cells:assert slot[target[r]]['socket']==socket[r]
def stats(mapping):
 result=collections.Counter()
 for a,b,w in edges:
  if node[a]!=node[b]:kind='cross_node'
  elif socket[a]!=socket[b]:kind='within_node_cross_socket'
  elif mapping[a]!=mapping[b]:kind='within_socket_cross_numa'
  else:kind='same_numa'
  result[kind+'_faces']+=w;result[kind+'_edges']+=1
 result['within_node_cross_numa_faces']=result['within_node_cross_socket_faces']+result['within_socket_cross_numa_faces']
 result['total_unique_faces']=sum(w for a,b,w in edges)
 loads=groupcells(mapping);mean=sum(cells.values())/32
 result['max_cells_per_numa']=max(loads.values());result['numa_cell_cv_percent']=100*math.sqrt(sum((v-mean)**2 for v in loads.values())/32)/mean
 return dict(result)
a,b=stats(base),stats(candidate)
assert a['cross_node_faces']==b['cross_node_faces']==300065
assert a['within_node_cross_socket_faces']==b['within_node_cross_socket_faces']
assert a['total_unique_faces']==b['total_unique_faces']==2690403
assert b['max_cells_per_numa']<=a['max_cells_per_numa']
assert b['within_socket_cross_numa_faces']<a['within_socket_cross_numa_faces']
summary={'analysis_date':'2026-11-02','scope':'offline geometric proxy only, 0 SU; not a measured performance improvement','raw_graph_job':job,'GCC_PMPI_graph_identical':True,'cell_count':sum(cells.values()),'edge_count':len(edges),'control':a,'candidate':b,'greedy_swaps':len(swaps),'lookahead_passes':len(lookahead_commits),'ranks_changed_numa':sum(base[r]!=candidate[r] for r in cells),'ranks_changed_core_slot':sum(target[r]!=r%104 for r in cells),'within_socket_face_reduction_percent':100*(1-b['within_socket_cross_numa_faces']/a['within_socket_cross_numa_faces']),'within_node_cross_numa_reduction_percent':100*(1-b['within_node_cross_numa_faces']/a['within_node_cross_numa_faces']),'limitations':['Historical topology/core placement template must be verified on new allocation','Interface face counts are not measured bytes or time','Partition cells are a workload proxy, not timing','No memory page placement/bandwidth measured','Deterministic greedy plus bounded swap-prefix search; no global optimum claim','Pair control and treatment both core bound; no claim core binding is a selected speedup','Full current-job per-rank raw receipt archival remains incomplete']}
(OUT/'summary.json').write_text(json.dumps(summary,indent=2)+'\n')
(OUT/'input-provenance.json').write_text(json.dumps(inputs,indent=2)+'\n')
(OUT/'swaps.json').write_text(json.dumps({'greedy':swaps,'lookahead':lookahead_commits},indent=2)+'\n')
with (OUT/'candidate-analysis-only.csv').open('w',newline='') as f:
 w=csv.writer(f,lineterminator='\n');w.writerow(['rank','node_index','socket_preserved','control_numa','candidate_numa','control_slot','candidate_slot','template_linux_cpu','cells'])
 for r in range(416):w.writerow([r,node[r],socket[r],base[r],candidate[r],r%104,target[r],slot[target[r]]['cpu'],cells[r]])
with (OUT/'numa-loads.csv').open('w',newline='') as f:
 w=csv.writer(f,lineterminator='\n');w.writerow(['node_index','numa','control_cells','candidate_cells','ranks_each'])
 ca,cb=groupcells(base),groupcells(candidate)
 for n in range(4):
  for d in range(8):w.writerow([n,d,ca[n,d],cb[n,d],13])
print(json.dumps(summary,indent=2))
