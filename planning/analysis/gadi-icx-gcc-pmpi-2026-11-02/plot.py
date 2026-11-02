from pathlib import Path
import os,csv,json
os.environ.setdefault('MPLCONFIGDIR','/private/tmp/mpl-icx-pmpi')
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
p=Path(__file__).resolve().parent
s=json.loads((p/'summary.json').read_text());rows=list(csv.DictReader((p/'rank-metrics.csv').open()))
fig,axes=plt.subplots(2,2,figsize=(11,7),layout='constrained')
for name,color in [('GCC','#2166ac'),('ICX','#b35806')]:
 r=[x for x in rows if x['stack']==name and x['window']=='common80']
 for ax,call in zip(axes[0],['MPI_Waitall','MPI_Allreduce']):
  a=sorted(float(x[call+'_s']) for x in r);ax.plot(a,[(i+1)/416*100 for i in range(416)],label=name,color=color,lw=2)
  ax.set_title(call+' · common 80–360 s window');ax.set_xlabel('Accumulated seconds per rank');ax.set_ylabel('Ranks at or below (%)');ax.grid(alpha=.2)
 t=s[name]['bucket_timeline'];x=sorted(int(k) for k in t if 80<=int(k)<360)
 for ax,call in zip(axes[1],['MPI_Waitall','MPI_Allreduce']):
  ax.plot(x,[t[str(k)][call] for k in x],color=color,label=name);ax.set_title(call+' · 10 s buckets');ax.set_xlabel('Bucket start after MPI_Init (s)');ax.set_ylabel('Mean seconds per rank');ax.grid(alpha=.2)
axes[0,0].legend();fig.suptitle('GCC vs ICX PMPI · identical Scotch partition · 416 ranks\nSingle diagnostic per stack; time windows are not iteration-aligned',fontsize=13)
fig.savefig(p/'mpi-comparison.png',dpi=170);fig.savefig(p/'mpi-comparison.svg')
