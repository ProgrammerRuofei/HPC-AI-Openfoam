from pathlib import Path

import matplotlib.pyplot as plt
from matplotlib import rcParams

OUT = Path(__file__).parent / "figures"
OUT.mkdir(exist_ok=True)
rcParams.update({"font.family": "DejaVu Sans", "font.size": 13, "axes.spines.top": False,
                 "axes.spines.right": False, "axes.edgecolor": "#8795ad", "axes.labelcolor": "#243b63",
                 "xtick.color": "#52647d", "ytick.color": "#52647d"})
NAVY, BLUE, TEAL, PURPLE, CORAL, GREY = "#1e2b74", "#347fbd", "#2aa494", "#8067b8", "#e3645b", "#8794a8"

def finish(fig, name):
    fig.savefig(OUT / name, dpi=180, bbox_inches="tight", facecolor="white")
    plt.close(fig)

# The missing stock-Opt point is intentionally represented without a timing value.
fig, ax = plt.subplots(figsize=(9.2, 4.3))
labels = ["Hierarchical (8 8 8)", "Hierarchical (16 8 4)", "Hierarchical (32 16 1)"]
ys = [2, 1, 0]
for y, x, color in [(2, 3.355476, GREY), (0, 3.064002, TEAL)]:
    ax.plot([2.95, x], [y, y], color="#dde4ef", lw=3, zorder=1)
    ax.scatter(x, y, s=220, color=color, zorder=3)
    ax.text(x + .014, y + .05, f"{x:.3f}", color=color, fontweight="bold", fontsize=15)
ax.text(2.98, 1, "Pending stock Opt run — no timing plotted", color=PURPLE,
        fontweight="bold", fontsize=12, va="center")
ax.set_yticks(ys, labels)
ax.set_xlim(2.95, 3.52); ax.set_ylim(-.5, 2.5)
ax.set_xlabel("Average wall-clock time (s/step) — lower is better")
ax.grid(axis="x", color="#e6eaf1")
ax.set_axisbelow(True)
finish(fig, "hierarchical_xyz_pending.png")

fig, ax = plt.subplots(figsize=(9.2, 4.3))
names = ["Hierarchical (32 16 1)", "Plain Scotch", "Weighted Scotch"]
values = [3.064002, 2.912440, 2.905191]
colors = [GREY, BLUE, TEAL]
for y, x, c in zip([2,1,0], values, colors):
    ax.plot([2.86, x], [y,y], color="#dde4ef", lw=4, zorder=1)
    ax.scatter(x,y,s=260,color=c,zorder=3)
    ax.text(x+.009,y+.06,f"{x:.3f}",color=c,fontweight="bold",fontsize=15)
ax.set_yticks([2,1,0],names)
ax.set_xlim(2.86,3.13);ax.set_ylim(-.5,2.5)
ax.set_xlabel("Average wall-clock time (s/step) — truncated axis")
ax.grid(axis="x",color="#e6eaf1");ax.set_axisbelow(True)
finish(fig,"basic_decomposition.png")

fig, ax = plt.subplots(figsize=(9.2, 4.3))
names=["Hierarchical (32 16 1)","Plain Scotch","Weighted Scotch"]
mpi=[27.29,19.68,19.03]; compute=[100-x for x in mpi]
ys=[2,1,0]
ax.barh(ys,compute,color=BLUE,height=.48,label="Outside MPI")
ax.barh(ys,mpi,left=compute,color=CORAL,height=.48,label="Inside MPI")
for y,a,b in zip(ys,compute,mpi):
    ax.text(a/2,y,f"{a:.1f}%",va="center",ha="center",color="white",fontweight="bold")
    ax.text(a+b/2,y,f"{b:.1f}%",va="center",ha="center",color="white",fontweight="bold")
ax.set_yticks(ys,names);ax.set_xlim(0,100);ax.set_ylim(-.5,2.5)
ax.set_xlabel("Mean rank wall-time share (%)")
ax.legend(loc="lower center",bbox_to_anchor=(.5,1.02),ncol=2,frameon=False)
ax.grid(axis="x",color="#e6eaf1");ax.set_axisbelow(True)
finish(fig,"pmpi_three_way.png")

fig,ax=plt.subplots(figsize=(9.2,4.3))
nodes=[1,2,4];steps=[40,80,150];times=[13.3450719,6.3961193,2.9051915]
bars=ax.bar(nodes,times,width=.58,color=[PURPLE,BLUE,TEAL])
for b,t,s in zip(bars,times,steps):
    ax.text(b.get_x()+b.get_width()/2,t+.22,f"{t:.3f}",ha="center",color=NAVY,fontweight="bold",fontsize=15)
    ax.text(b.get_x()+b.get_width()/2,.38,f"{s} steps",ha="center",color="white",fontweight="bold",fontsize=11)
ax.set_xticks(nodes,["1 node\n128 ranks","2 nodes\n256 ranks","4 nodes\n512 ranks"])
ax.set_ylabel("Average wall-clock time (s/step)")
ax.set_ylim(0,15.3);ax.grid(axis="y",color="#e6eaf1");ax.set_axisbelow(True)
finish(fig,"basic_scaling.png")

# Compare measurement contexts; differences are not presented as exact overhead.
fig,ax=plt.subplots(figsize=(9.2,4.3))
names=["Hierarchical (32 16 1)","Plain Scotch","Weighted Scotch"]
raw=[3.064002,2.912440,2.905191]
profiled=[3.064982,2.963529,2.921232]
for y,a,b in zip([2,1,0],raw,profiled):
    ax.plot([a,b],[y,y],color="#b9c8db",lw=3,zorder=1)
    ax.scatter(a,y,s=170,facecolor="white",edgecolor=BLUE,lw=2.5,zorder=3)
    ax.scatter(b,y,s=170,color=PURPLE,zorder=3)
    ax.text(max(a,b)+.012,y+.06,f"{a:.3f} / {b:.3f}",color=NAVY,fontsize=11)
ax.set_yticks([2,1,0],names);ax.set_xlim(2.86,3.22);ax.set_ylim(-.5,2.5)
ax.set_xlabel("Average wall-clock time (s/step) — truncated axis")
ax.legend(handles=[plt.Line2D([0],[0],marker='o',markerfacecolor='white',markeredgecolor=BLUE,ls='',label='Unprofiled'),
                   plt.Line2D([0],[0],marker='o',color=PURPLE,ls='',label='PMPI')],
          loc='lower center',bbox_to_anchor=(.5,1.02),ncol=2,frameon=False)
ax.grid(axis='x',color='#e6eaf1');ax.set_axisbelow(True)
finish(fig,'pmpi_method_context.png')
