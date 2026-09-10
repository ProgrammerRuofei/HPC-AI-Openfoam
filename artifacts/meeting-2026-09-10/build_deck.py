import json
d=json.load(open('chart-data.json'))
svg={k:open(f'chart-{k}.svg').read().replace('<?xml version="1.0" ?>','') for k in ('scaling','decomposition','profiling')}

HEAD = '''<title>Gadi OpenFOAM Optimization Review</title>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=IBM+Plex+Sans:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600;700&display=swap">
<style>
:root{
  --sans:"IBM Plex Sans",system-ui,sans-serif; --mono:"IBM Plex Mono",ui-monospace,monospace;
  --ground:#f4f6f9; --surface:#ffffff; --ink:#12151c; --mute:#5b6472; --rule:#dfe3ea; --fill:#eceef2;
  --accent:#0b4f9c; --accent2:#4a86c8; --accent3:#9dc2e6;
  --warn:#b45309; --crit:#a4161a; --good:#14683c;
}
@media (prefers-color-scheme:dark){
 :root:not([data-theme="light"]){
  --ground:#0d1117; --surface:#161b22; --ink:#e8ecf2; --mute:#98a3b3; --rule:#2b3441; --fill:#20272f;
  --accent:#69a9e8; --accent2:#3f7cb8; --accent3:#2b5a86;
  --warn:#e0993d; --crit:#f0736f; --good:#57b87f;
 }
}
:root[data-theme="dark"]{
  --ground:#0d1117; --surface:#161b22; --ink:#e8ecf2; --mute:#98a3b3; --rule:#2b3441; --fill:#20272f;
  --accent:#69a9e8; --accent2:#3f7cb8; --accent3:#2b5a86;
  --warn:#e0993d; --crit:#f0736f; --good:#57b87f;
}
*{box-sizing:border-box}
body{margin:0;background:var(--ground);color:var(--ink);font-family:var(--sans);
  height:100vh;overflow:hidden;display:grid;place-items:center}
.deck{width:min(100vw,177.78vh);aspect-ratio:16/9;position:relative;font-size:calc(min(100vw,177.78vh)/64)}
.slide{position:absolute;inset:0;background:var(--surface);display:none;
  grid-template-rows:auto auto 1fr auto;padding:2.0em 2.6em 1.0em;gap:.75em}
.slide[data-on]{display:grid}
.eyebrow{font-size:.62em;font-weight:600;letter-spacing:.16em;text-transform:uppercase;color:var(--mute);font-family:var(--mono)}
h1{font-size:2.05em;font-weight:600;line-height:1.08;margin:.18em 0 0;text-wrap:balance;letter-spacing:-.015em}
h1.big{font-size:2.55em}
.take{font-size:.92em;color:var(--ink);border-left:.22em solid var(--accent);padding-left:.7em;font-weight:500}
.note{font-size:.6em;color:var(--mute);line-height:1.45}
.body{min-height:0;display:flex;flex-direction:column;gap:.7em;justify-content:center}
svg{width:100%;height:100%;max-height:100%;display:block;object-fit:contain}
.body>svg{flex:1;min-height:0}
table{width:100%;border-collapse:collapse;font-size:.72em}
th{text-align:left;font-size:.78em;letter-spacing:.1em;text-transform:uppercase;color:var(--mute);
  font-weight:600;padding:0 .7em .5em;border-bottom:2px solid var(--rule)}
td{padding:.62em .7em;border-bottom:1px solid var(--rule);vertical-align:middle}
tr:last-child td{border-bottom:none}
td.n{font-family:var(--mono);font-variant-numeric:tabular-nums;font-weight:500}
td.d{font-weight:600}
.funnel{display:flex;gap:.3em;align-items:center;font-family:var(--mono);font-size:.56em;color:var(--mute)}
.funnel b{font-weight:600;padding:.3em .7em;border-radius:99em;background:var(--fill);color:var(--mute)}
.funnel b[data-here]{background:var(--accent);color:var(--surface)}
.funnel i{font-style:normal;opacity:.45}
.foot{display:flex;justify-content:space-between;align-items:end;font-size:.55em;color:var(--mute);font-family:var(--mono);border-top:1px solid var(--rule);padding-top:.55em}
.cols{display:grid;grid-template-columns:1fr 1fr 1fr;gap:1.3em}
.col h3{font-size:.72em;margin:0 0 .5em;letter-spacing:.1em;text-transform:uppercase;color:var(--mute);font-weight:600;font-family:var(--mono)}
.col ul{margin:0;padding-left:1.1em;font-size:.72em;line-height:1.65}
.col li::marker{color:var(--accent)}
.tiles{display:flex;flex-direction:column;gap:.5em}
.tile b{font-family:var(--mono);font-size:1.5em;font-weight:600;line-height:1.05;display:block;letter-spacing:-.02em}
.tile b.w{color:var(--warn)} .tile b.c{color:var(--crit)} .tile b.a{color:var(--accent)}
.tile span{font-size:.62em;color:var(--mute);line-height:1.3;display:block}
.mech{font-family:var(--mono);font-size:.58em;line-height:1.7;background:var(--fill);padding:.75em .9em;border-radius:.25em;border-left:.2em solid var(--crit)}
.chip{font-family:var(--mono);font-size:.86em;font-weight:600;padding:.2em .55em;border-radius:.25em;white-space:nowrap}
.ok{background:color-mix(in srgb,var(--good) 15%,transparent);color:var(--good)}
.bad{background:color-mix(in srgb,var(--crit) 15%,transparent);color:var(--crit)}
.neu{background:var(--fill);color:var(--mute)}
.hero{display:flex;flex-direction:column;justify-content:center;gap:1.4em;height:100%}
.stats{display:grid;grid-template-columns:repeat(3,1fr);gap:1.1em;font-size:.72em}
.stat b{display:block;font-family:var(--mono);font-size:2.1em;font-weight:600;line-height:1.1;letter-spacing:-.02em}
.stat span{color:var(--mute)}
.nav{position:absolute;bottom:.5em;right:.9em;font-family:var(--mono);font-size:.55em;color:var(--mute);display:flex;gap:.5em;align-items:center}
.nav button{font:inherit;color:inherit;background:var(--fill);border:1px solid var(--rule);border-radius:.25em;cursor:pointer;padding:.15em .5em}
.nav button:focus-visible{outline:2px solid var(--accent);outline-offset:2px}
@media print{
  body{height:auto;overflow:visible;display:block;background:#fff}
  .deck{width:100%;aspect-ratio:auto;font-size:13pt}
  .slide{display:grid!important;position:static;page-break-after:always;height:100vh;border:none}
  .nav{display:none}
}
@media (prefers-reduced-motion:no-preference){.slide[data-on]{animation:f .18s ease-out}}
@keyframes f{from{opacity:.55}to{opacity:1}}
</style>'''

def funnel(here):
    st=['Baseline','Scaling','Decomposition','MPI placement','Compiler','Profiling']
    out=[]
    for i,x in enumerate(st):
        out.append(f'<b{" data-here" if i==here else ""}>{x}</b>')
        if i<len(st)-1: out.append('<i>&rarr;</i>')
    return '<div class="funnel">'+''.join(out)+'</div>'

def foot(n,left):
    return f'<div class="foot"><span>{left}</span><span>{n} / 6</span></div>'

S=[]

S.append(f'''<section class="slide" data-on>
<div class="eyebrow">2026 APAC HPC-AI &#183; NCI Gadi &#183; review 2026-09-10</div>
<div class="hero">
<h1 class="big">OpenFOAM HPC Optimization Progress</h1>
<div class="take">Controlled one-variable-at-a-time optimization.</div>
{funnel(-1)}
<div class="stats">
<div class="stat"><b>65.3 M</b><span>cells &#183; occDrivAerStaticMesh, simpleFoam</span></div>
<div class="stat"><b>12</b><span>validated experiments across SPR and CLX</span></div>
<div class="stat"><b>2.140</b><span>s/step &#183; official 4-node SPR baseline</span></div>
</div>
</div>
{foot(1,'OpenFOAM v2512 &#183; OpenMPI 4.1.7 &#183; fixedIter &#183; endTime 150')}
</section>''')

S.append(f'''<section class="slide">
<div class="eyebrow">Stage 1 &#183; scaling</div>
<h1>Observed Per-Step Scaling on Official Configurations</h1>
<div class="body">{svg["scaling"]}
<div class="take">Per-step runtime decreases almost proportionally from 1 to 4 SPR nodes.</div>
<div class="note">Official runs use different endTime values (40 / 80 / 150). Speedup is based on average seconds per step; &gt;100% efficiency should not be interpreted as a controlled superlinear-scaling result.</div>
</div>
{foot(2,'178153587 &#183; 178154724 &#183; 178149002 &#8212; OFFICIAL VALID')}
</section>''')

rows=[('Scaling','1&rarr;2&rarr;4 SPR nodes','8.824 &rarr; 4.297 &rarr; 2.140 s/step','Good observed per-step scaling','neu'),
      ('Decomposition','(16 13 2) &rarr; (26 8 2)','robust gain ~0.13&ndash;0.22%','Stop tuple search','ok'),
      ('MPI placement','site default placement','1 rank/core, no SMT','No tuning now','ok'),
      ('Compiler','GCC reference &rarr; ICC generic','ICC 2.66% slower','No ICC generic win','bad'),
      ('Architecture targeting','generic &rarr; -xCORE-AVX512','substantial 256-bit SIMD','SIGFPE compatibility issue','bad'),
      ('Profiling','valid perf profile','IPC&#8776;1.0; stalls 63.1%; L3 stalls 33.6%','Memory hierarchy first','neu')]
tr=''.join(f'<tr><td class="d">{a}</td><td>{b}</td><td class="n">{c}</td><td><span class="chip {e}">{dd}</span></td></tr>' for a,b,c,dd,e in rows)
S.append(f'''<section class="slide">
<div class="eyebrow">Stage 1&ndash;6 &#183; summary</div>
<h1>Optimization Results at a Glance</h1>
<div class="body"><table>
<thead><tr><th>Area</th><th>What we tested</th><th>Quantitative result</th><th>Decision</th></tr></thead>
<tbody>{tr}</tbody></table></div>
{foot(3,'Full job IDs and status labels in results/experiment-index.md')}
</section>''')

S.append(f'''<section class="slide">
<div class="eyebrow">Stage 3 &#183; decomposition</div>
<h1>Why Decomposition Headroom Is Small</h1>
<div class="body">{svg["decomposition"]}
<div class="take">Partition quality improved structurally, but the runtime gain is now smaller than the noise between two runs of the same tuple.</div>
</div>
{foot(4,'178576776 &#183; 178577482 &#183; 178616881 &#8212; CONTROLLED VALID')}
</section>''')

S.append(f'''<section class="slide">
<div class="eyebrow">Stage 5&ndash;6 &#183; compiler and profiling</div>
<h1>Compiler Experiment: SIMD Achieved, But Memory Stalls Appear More Important</h1>
<div class="body"><div class="cols">
<div class="col"><h3>ICC generic</h3><ul>
<li>numerical libraries essentially scalar</li>
<li>valid 65M screening run</li>
<li><b>5.282 s/step</b> &#8212; 2.66% slower than the historical CLX GCC reference</li></ul></div>
<div class="col"><h3>ICC OptAVX512</h3><ul>
<li>substantial 256-bit YMM SIMD generated</li>
<li>no 512-bit arithmetic at all</li>
<li>GAMG smoke fails with SIGFPE</li></ul>
<div class="mech">masked zero-fill tail load<br>&rarr; unmasked vdivpd<br>&rarr; inactive lane computes 0.0/0.0<br>&rarr; FE_INVALID under -fp-trap=common</div></div>
<div class="col"><h3>Valid perf profile</h3>
<div class="tiles">
<div class="tile"><b>1.03</b><span>IPC &#183; rank 24 / node 0</span></div>
<div class="tile"><b class="w">63.1%</b><span>cycles stalled &#183; rank 120 / node 2</span></div>
<div class="tile"><b class="c">33.6%</b><span>cycles on L3-miss stalls &#183; rank 120</span></div>
<div class="tile"><b>91.4%</b><span>LLC load miss &#183; rank 168 / node 3</span></div>
<div class="tile"><b class="a">87.9%</b><span>FP elements scalar &#183; rank 72 / node 1</span></div>
</div></div>
</div>
<div class="take">Wider SIMD is achievable, but memory-hierarchy stalls appear more important than arithmetic width.</div>
<div class="note">Representative-rank evidence, not a cluster-wide proof. MPI wall-time fraction is not measured &#8212; perf cannot separate it, and OpenMPI busy-wait contributes cycles and instructions.</div>
</div>
{foot(5,'178570241 &#183; 178640018 &#183; 178663697 &#183; 178677055')}
</section>''')

S.append(f'''<section class="slide">
<div class="eyebrow">Conclusion</div>
<h1>Current Conclusion &amp; Next Step</h1>
<div class="body"><div class="cols">
<div class="col"><h3>Established</h3><ul>
<li>strong scaling is already good</li>
<li>decomposition headroom is small</li>
<li>MPI placement is reasonable</li>
<li>ICC generic is not faster</li>
<li>architecture targeting adds SIMD</li>
<li>memory-hierarchy stalls are substantial</li></ul></div>
<div class="col"><h3>Unknown</h3><ul>
<li>MPI wall-time fraction</li>
<li>exact memory bandwidth saturation</li>
<li>cross-socket / cross-NUMA variation</li>
<li>whether a fixed AVX512 build would be faster end-to-end</li></ul></div>
<div class="col"><h3>Next</h3><ul>
<li><b>Memory / cache behaviour before further compiler tuning.</b></li>
<li>Remaining allocation is low &#8212; preserve evidence and resume runtime profiling after allocation reset.</li>
<li>ICC architecture targeting: paused, artifacts and provenance retained.</li></ul></div>
</div>
<div class="take">Scaling and communication-layout tuning now show limited remaining headroom. Compiler architecture targeting successfully introduced SIMD, but runtime profiling indicates substantial memory-hierarchy stalls &#8212; so further ICC architecture targeting is not the current priority.</div>
</div>
{foot(6,'Evidence: /scratch/pm78/kj7183/openfoam_cpu &#183; commit b6272eae')}
</section>''')

JS='''<div class="nav"><button id="p" aria-label="Previous slide">&larr;</button><span id="c">1 / 6</span><button id="n" aria-label="Next slide">&rarr;</button></div>
<script>
var s=[].slice.call(document.querySelectorAll('.slide')),i=0;
function go(k){i=Math.max(0,Math.min(s.length-1,k));
 s.forEach(function(e,j){if(j===i){e.setAttribute('data-on','')}else{e.removeAttribute('data-on')}});
 document.getElementById('c').textContent=(i+1)+' / '+s.length;}
document.addEventListener('keydown',function(e){
 if(e.key==='ArrowRight'||e.key==='PageDown'||e.key===' '){e.preventDefault();go(i+1)}
 else if(e.key==='ArrowLeft'||e.key==='PageUp'){e.preventDefault();go(i-1)}
 else if(e.key==='Home'){go(0)}else if(e.key==='End'){go(s.length-1)}});
document.getElementById('n').onclick=function(){go(i+1)};
document.getElementById('p').onclick=function(){go(i-1)};
go(0);
</script>'''

open('slides.html','w').write(HEAD+'\n<div class="deck">\n'+'\n'.join(S)+'\n'+JS+'\n</div>\n')
print('slides.html written,', len(open('slides.html').read()), 'bytes')
