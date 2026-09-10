import json
d=json.load(open('chart-data.json'))
scal=open('chart-scaling.svg').read()

CSS = '''<title>Gadi OpenFOAM Experiment Results</title>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=IBM+Plex+Sans:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600&display=swap">
<style>
:root{
  --sans:"IBM Plex Sans",system-ui,sans-serif; --mono:"IBM Plex Mono",ui-monospace,monospace;
  --ground:#eef1f5; --surface:#ffffff; --ink:#12151c; --mute:#5b6472; --faint:#8b95a3;
  --rule:#d5dbe4; --hair:#e8ecf1; --fill:#f2f5f8;
  --accent:#0b4f9c; --warn:#a1590a; --crit:#96131a; --good:#12613a;
}
@media (prefers-color-scheme:dark){ :root:not([data-theme="light"]){
  --ground:#0b0e13; --surface:#141920; --ink:#e6ebf2; --mute:#9aa5b4; --faint:#6f7b8b;
  --rule:#2a333f; --hair:#1e252e; --fill:#1a2029;
  --accent:#6fadea; --warn:#dd9a44; --crit:#ef7a75; --good:#54b87e;
}}
:root[data-theme="dark"]{
  --ground:#0b0e13; --surface:#141920; --ink:#e6ebf2; --mute:#9aa5b4; --faint:#6f7b8b;
  --rule:#2a333f; --hair:#1e252e; --fill:#1a2029;
  --accent:#6fadea; --warn:#dd9a44; --crit:#ef7a75; --good:#54b87e;
}
*{box-sizing:border-box}
body{margin:0;background:var(--ground);color:var(--ink);font-family:var(--sans);
  height:100vh;overflow:hidden;display:grid;place-items:center}
.deck{width:min(100vw,177.78vh);aspect-ratio:16/9;position:relative;font-size:calc(min(100vw,177.78vh)/68)}
.slide{position:absolute;inset:0;background:var(--surface);display:none;
  grid-template-rows:auto auto 1fr auto;padding:1.25em 1.8em 0.7em;gap:.45em}
.slide[data-on]{display:grid}
.hdr{display:flex;justify-content:space-between;align-items:baseline;
  border-bottom:2px solid var(--ink);padding-bottom:.35em;font-family:var(--mono);font-size:.6em}
.hdr .stage{font-weight:600;letter-spacing:.14em;text-transform:uppercase}
.hdr .jobs{color:var(--faint)}
h1{font-size:1.62em;font-weight:600;line-height:1.1;margin:.1em 0 0;letter-spacing:-.012em;text-wrap:balance}
h1.big{font-size:2.4em}
.body{min-height:0;display:flex;flex-direction:column;gap:.55em;justify-content:flex-start;overflow:hidden}
.body.mid{justify-content:center}
table{width:100%;border-collapse:collapse}
th{text-align:left;font-family:var(--mono);font-size:.56em;letter-spacing:.1em;text-transform:uppercase;
  color:var(--mute);font-weight:600;padding:0 .55em .4em;border-bottom:1.5px solid var(--rule);vertical-align:bottom}
td{padding:.44em .55em;border-bottom:1px solid var(--hair);vertical-align:top;font-size:.65em;line-height:1.35}
tbody tr:last-child td{border-bottom:none}
tbody tr:nth-child(even){background:var(--fill)}
table.dense td{font-size:.5em;padding:.26em .4em;line-height:1.28}
table.dense th{font-size:.5em;padding:0 .45em .35em}
table.dense td.exp{font-size:.53em;width:12%}
table.dense td.dec{width:13%;font-size:.52em}
.n{font-family:var(--mono);font-variant-numeric:tabular-nums}
b.v{font-weight:600}
td.exp{font-weight:600;font-size:.68em;width:15%}
td.exp small{display:block;font-weight:400;font-family:var(--mono);font-size:.72em;color:var(--faint);line-height:1.3;margin-top:.15em}
td.dec{font-weight:600;color:var(--accent);width:15%}
td.dec.stop{color:var(--crit)} td.dec.go{color:var(--good)}
.rowlab{font-family:var(--mono);font-size:.54em;letter-spacing:.12em;text-transform:uppercase;color:var(--faint)}
.two{display:grid;grid-template-columns:1fr 1.25fr;gap:1.4em;min-height:0}
.two>div{min-height:0;display:flex;flex-direction:column;gap:.4em}
svg{width:100%;height:auto;max-height:100%;display:block}
.kv{width:100%;border-collapse:collapse}
.kv td{padding:.24em .45em;border-bottom:1px solid var(--hair);font-size:.6em}
.kv td:last-child{text-align:right;font-family:var(--mono);font-variant-numeric:tabular-nums;font-weight:600}
.kv tr.hi td{background:var(--fill)}
.kv tr.hi td:last-child{color:var(--accent)}
.decbar{border-left:.28em solid var(--accent);background:var(--fill);padding:.45em .75em;font-size:.7em;font-weight:600}
.decbar.stop{border-left-color:var(--crit)}
.decbar em{font-style:normal;font-family:var(--mono);font-size:.72em;letter-spacing:.12em;text-transform:uppercase;color:var(--faint);display:block;font-weight:600}
.chain{font-family:var(--mono);font-size:.56em;line-height:1.75;background:var(--fill);padding:.5em .7em;border-left:.22em solid var(--crit)}
.chain u{text-decoration:none;color:var(--crit);font-weight:600}
.note{font-size:.53em;color:var(--faint);line-height:1.5;font-family:var(--mono)}
.chip{font-family:var(--mono);font-size:.84em;font-weight:600;white-space:nowrap}
.chip.ok{color:var(--good)} .chip.bad{color:var(--crit)} .chip.neu{color:var(--mute)}
.flow{display:flex;gap:.5em;align-items:center;font-family:var(--mono);font-size:.72em;color:var(--ink)}
.flow span{padding:.35em .8em;border:1.5px solid var(--rule);border-radius:.2em}
.flow i{font-style:normal;color:var(--faint)}
.meta{display:grid;grid-template-columns:repeat(4,auto);gap:.4em 2.2em;font-family:var(--mono);font-size:.62em;justify-content:start}
.meta dt{color:var(--faint)} .meta dd{margin:0;font-weight:600}
.foot{display:flex;justify-content:space-between;font-family:var(--mono);font-size:.5em;color:var(--faint);
  border-top:1px solid var(--rule);padding-top:.4em}
.simd{display:flex;height:1.5em;width:100%;overflow:hidden}
.simd i{display:block;font-style:normal}
.nav{position:absolute;bottom:.4em;right:.8em;font-family:var(--mono);font-size:.5em;color:var(--faint);display:flex;gap:.4em;align-items:center}
.nav button{font:inherit;color:inherit;background:var(--fill);border:1px solid var(--rule);border-radius:.2em;cursor:pointer;padding:.1em .45em}
.nav button:focus-visible{outline:2px solid var(--accent);outline-offset:2px}
@media print{
  body{height:auto;overflow:visible;display:block;background:#fff}
  .deck{width:100%;aspect-ratio:auto;font-size:12pt}
  .slide{display:grid!important;position:static;page-break-after:always;height:100vh}
  .nav{display:none}
}
</style>'''

def hdr(stage, jobs): return f'<div class="hdr"><span class="stage">{stage}</span><span class="jobs">{jobs}</span></div>'
def foot(n, left): return f'<div class="foot"><span>{left}</span><span>{n} / 6</span></div>'

S=[]

# ---- 1 ----
S.append(f'''<section class="slide" data-on>
{hdr('2026 APAC HPC-AI &#183; progress review','2026-09-10')}
<h1 class="big">OpenFOAM HPC Optimization Progress</h1>
<div class="body mid">
<div class="flow"><span>Scaling</span><i>&rarr;</i><span>Decomposition</span><i>&rarr;</i><span>MPI Placement</span><i>&rarr;</i><span>Compiler</span><i>&rarr;</i><span>Profiling</span></div>
<dl class="meta">
<dt>Case</dt><dd>occDrivAerStaticMesh</dd><dt>Cells</dt><dd>65,334,765</dd>
<dt>Solver</dt><dd>simpleFoam</dd><dt>OpenFOAM</dt><dd>v2512</dd>
<dt>MPI</dt><dd>OpenMPI 4.1.7</dd><dt>Numerics</dt><dd>fixedIter, endTime 150</dd>
<dt>Platforms</dt><dd>Sapphire Rapids / Cascade Lake</dd><dt>Experiments</dt><dd>12 validated</dd>
</dl>
<div class="note">Every experiment below is one variable changed against a stated baseline.</div>
</div>
{foot(1,'NCI Gadi &#183; project pm78')}
</section>''')

# ---- 2 : THE central table ----
rows=[
 ('Scaling','SPR &#183; GCC 8.5 + OpenMPI 4.1.7',
  '1N / 104 ranks<br><b class="v n">8.824444</b> s/step',
  '2N / 208 ranks<br>4N / 416 ranks',
  '<b class="v n">4.296500</b> &rarr; <b class="v n">2.139565</b> s/step',
  '<b class="v n">2.053868&#215;</b><br><b class="v n">4.124410&#215;</b>',
  'Good &#8212; not a priority','',),
 ('Decomposition','SPR &#183; 4N / 416 ranks',
  '<span class="n">(16 13 2)</span><br><b class="v n">2.147363</b> s/step',
  '<span class="n">(26 8 2)</span>',
  '<b class="v n">2.127211</b> s/step<br>repeat <b class="v n">2.118657</b>',
  'headline <b class="v n">0.94%</b><br>robust <b class="v n">0.13&ndash;0.22%</b>',
  'STOP TUPLE SEARCH','stop'),
 ('MPI placement','SPR &#183; 416 ranks',
  'site-default OpenMPI placement',
  'audit only, no change',
  '1 rank / physical core, no SMT<br><span class="n">52/socket &#183; 13/NUMA</span>',
  'already compact',
  'NO BINDING TUNING','stop'),
 ('ICC generic','CLX &#183; 4N / 192 ranks &#183; (16 6 2)',
  'historical CLX GCC reference<br><b class="v n">5.144659</b> s/step',
  'ICC Classic 2021.10 <span class="n">Opt</span> (<span class="n">-O3</span>)',
  '<b class="v n">5.281517</b> s/step',
  '<b class="v n">&minus;2.66%</b> (slower)',
  'NOT A WIN','stop'),
 ('Architecture targeting','CLX &#183; ICC 2021.10',
  'generic ICC: core libs<br><span class="n">ymm=0 / zmm=0</span>',
  '<span class="n">-O3 -xCORE-AVX512</span>',
  '256-bit YMM across all 3 core libs<br><span class="chip bad">smoke SIGFPE</span>',
  'Performance not measured',
  'PAUSE &#8212; FP-trap issue','stop'),
 ('Profiling','CLX &#183; ICC generic &#183; 25-step',
  'full run <b class="v n">5.281517</b> s/step',
  'perf counters, 4 representative ranks',
  '<b class="v n">5.246991</b> s/step (&minus;0.65%)<br>IPC <b class="v n">1.03</b> &#183; stalls <b class="v n">63.12%</b> &#183; L3 <b class="v n">33.64%</b>',
  'diagnostic &#8212; no runtime change',
  'MEMORY HIERARCHY NEXT','go'),
]
tr=''.join(f'<tr><td class="exp">{a}<small>{b}</small></td><td>{c}</td><td>{dd}</td><td>{e}</td><td>{f}</td><td class="dec {h}">{g}</td></tr>'
           for a,b,c,dd,e,f,g,h in rows)
S.append(f'''<section class="slide">
{hdr('Experiment results summary','all validated experiments &#183; 2026-09-10')}
<h1>What we tested, what we measured, what we decided</h1>
<div class="body"><table class="dense">
<thead><tr><th>Experiment</th><th>Baseline</th><th>Change</th><th>Measured result</th><th>Improvement</th><th>Decision</th></tr></thead>
<tbody>{tr}</tbody></table>
<div class="note">Official scaling runs use different endTime values (40 / 80 / 150), so efficiency above 100% is not presented as controlled superlinear scaling. &#183; Static disassembly counts and runtime SIMD percentages are different kinds of evidence and are never interchanged.</div>
</div>
{foot(2,'178153587 &#183; 178154724 &#183; 178149002 &#183; 178576776 &#183; 178577482 &#183; 178616881 &#183; 178623596 &#183; 178570241 &#183; 178640018 &#183; 178663697 &#183; 178677055')}
</section>''')

# ---- 3 ----
dec=[('Baseline <span class="n">(16 13 2)</span>','2.147363 s/step'),
     ('Candidate <span class="n">(26 8 2)</span>','2.127211 s/step'),
     ('Candidate repeat','2.118657 s/step'),
     ('Headline gain','0.94%'),('Robust gain','0.13&ndash;0.22%'),
     ('Same-tuple scatter','0.40%'),
     ('Interface faces','&minus;4.73%'),('Max interface faces','&minus;12.1%')]
kv=''.join(f'<tr{" class=hi" if l in ("Robust gain","Same-tuple scatter") else ""}><td>{l}</td><td>{v}</td></tr>' for l,v in dec)
S.append(f'''<section class="slide">
{hdr('Scaling and decomposition','178153587 &#183; 178154724 &#183; 178149002 &#183; 178576776 &#183; 178577482 &#183; 178616881')}
<h1>Scaling is already good; decomposition headroom is nearly gone</h1>
<div class="body"><div class="two">
<div><div class="rowlab">Observed per-step scaling &#183; SPR</div>{scal}</div>
<div><div class="rowlab">Decomposition A/B &#183; SPR 4N / 416 ranks</div>
<table class="kv"><tbody>{kv}</tbody></table>
<div class="decbar stop"><em>Decision</em>STOP TUPLE SEARCH &#8212; the robust gain is smaller than the scatter between two runs of the same tuple.</div>
</div></div>
<div class="note">Scaling: official runs use endTime 40 / 80 / 150; &gt;100% efficiency is not a controlled superlinear result. &#183; Decomposition arms are matched except for the hierarchical tuple.</div>
</div>
{foot(3,'OFFICIAL VALID &#183; CONTROLLED VALID')}
</section>''')

# ---- 4 ----
cmp_rows=[('Compiler','GCC 8.5.0 (site module)','ICC Classic 2021.10.0','ICC Classic 2021.10.0'),
 ('Flags','<span class="n">site build, -O3</span>','<span class="n">-O3</span>','<span class="n">-O3 -xCORE-AVX512</span>'),
 ('Platform','<span class="n">CLX &#183; 4N / 192 ranks &#183; (16 6 2)</span>','<span class="n">same</span>','<span class="n">same</span>'),
 ('Runtime','<b class="v n">5.144659</b> s/step','<b class="v n">5.281517</b> s/step','<span class="chip bad">not valid &#8212; no run</span>'),
 ('vs reference','&#8212;','<b class="v n">&minus;2.66%</b>','&#8212;'),
 ('SIMD in core libraries','<span class="n">zmm=0 / ymm=0</span>','mostly scalar<br><span class="n">ymm=0</span>',
  '<span class="n">libfiniteVolume 31,615</span><br><span class="n">libOpenFOAM 17,550</span><br><span class="n">libincompTurbModels 2,465</span><br><span class="n">zmm=0</span>'),
 ('Correctness','<span class="chip ok">valid</span>','<span class="chip ok">valid</span> <span class="n">178570241</span>','<span class="chip bad">SIGFPE smoke</span> <span class="n">178663697</span>'),
 ('Status','<span class="chip neu">HISTORICAL CLX GCC REFERENCE</span>','<span class="chip neu">SCREENING VALID</span>','<span class="chip neu">BUILD VALID / DIAGNOSTIC FAIL</span>')]
ct=''.join(f'<tr><td class="exp">{a}</td><td>{b}</td><td>{c}</td><td>{e}</td></tr>' for a,b,c,e in cmp_rows)
S.append(f'''<section class="slide">
{hdr('Compiler screening and architecture targeting','178570241 &#183; 178640018 &#183; 178663697')}
<h1>Compiler Results</h1>
<div class="body"><table>
<thead><tr><th></th><th>GCC reference</th><th>ICC generic</th><th>ICC targeted</th></tr></thead>
<tbody>{ct}</tbody></table>
<div class="chain">masked tail &rarr; zero-fill <span class="n">{{%k1}}{{z}}</span> &rarr; <u>unmasked vdivpd</u> &rarr; <u>0.0 / 0.0</u> &rarr; <u>FE_INVALID</u> &rarr; <span class="n">-fp-trap=common</span> &rarr; <u>SIGFPE</u><br>crash PC <span class="n">0x92d6fe</span> in <span class="n">Foam::GAMGSolver::scale()</span> &#183; a compiler/vectorization and FP-trap compatibility issue, not a physical-model numerical failure</div>
<div class="note">GCC reference = median of 4 repeats, one retained slowdown outlier; not a controlled paired compiler baseline. Confidence MEDIUM. &#183; GCC <span class="n">zmm=0 / ymm=0</span> source: prior shipped-binary disassembly recorded in compiler-screening-summary.md, not a measurement from this session.</div>
</div>
{foot(4,'SCREENING VALID &#183; BUILD VALID &#183; DIAGNOSTIC FAIL')}
</section>''')

# ---- 5 ----
pr=d['profiling']; sm=pr['simd']['element_share_pct']
prof=[('IPC &#8212; rank 24 / node 0','1.030'),('IPC &#8212; rank 120 / node 2','0.989'),
      ('Total stall fraction &#8212; rank 120','63.12%'),('L3-miss stalls / cycles &#8212; rank 120','33.64%'),
      ('L3-miss share of stalls &#8212; rank 120','53.29%'),('LLC load miss rate &#8212; rank 168 / node 3','91.36%'),
      ('Branch misses / instr &#8212; rank 168','0.206%')]
pk=''.join(f'<tr{" class=hi" if "stall" in l.lower() else ""}><td>{l}</td><td>{v}</td></tr>' for l,v in prof)
segs=[('scalar',sm['scalar'],'var(--accent)'),('128-bit',sm['b128'],'color-mix(in srgb,var(--accent) 55%,var(--surface))'),
      ('256-bit',sm['b256'],'color-mix(in srgb,var(--accent) 25%,var(--surface))'),('512-bit',sm['b512'],'var(--rule)')]
bar=''.join(f'<i style="width:{max(v,0.35)}%;background:{c}"></i>' for _,v,c in segs)
S.append(f'''<section class="slide">
{hdr('Runtime profiling','178677055 &#183; commit b6272eae &#183; PROFILING VALID')}
<h1>Runtime Profiling &#8212; ICC generic, 25-step diagnostic</h1>
<div class="body"><div class="two">
<div><div class="rowlab">Representative-rank counters</div>
<table class="kv"><tbody>{pk}</tbody></table></div>
<div><div class="rowlab">FP arithmetic elements by vector width &#183; rank 72 / node 1</div>
<div class="simd">{bar}</div>
<table class="kv"><tbody>
<tr class="hi"><td>scalar</td><td>{sm['scalar']:.2f}%</td></tr>
<tr><td>128-bit packed</td><td>{sm['b128']:.2f}%</td></tr>
<tr><td>256-bit packed</td><td>{sm['b256']:.2f}%</td></tr>
<tr><td>512-bit packed</td><td>{sm['b512']:.2f}%</td></tr>
</tbody></table>
<div class="note">Retired FP arithmetic instruction events weighted by width &#8212; not FLOPs; FMA semantics differ.</div>
<div class="decbar"><em>Decision</em>Representative samples indicate memory-hierarchy stalls are more important than arithmetic width.</div>
</div></div>
<div class="note">Solver check: 5.246991 s/step against the full-run reference 5.281517 s/step &#8212; difference &minus;0.65%. &#183; Caveat: MPI wall-time fraction not measured; the four sampled ranks all sit at core 24 / socket 1 / NUMA 2, so there is no socket 0 or NUMA 0/1 coverage, and counts are never combined across event groups.</div>
</div>
{foot(5,'endTime 25 &#183; 4 nodes / 192 ranks &#183; 45.01 SU')}
</section>''')

# ---- 6 ----
dr=[('Scaling','<span class="n">8.824 &rarr; 4.297 &rarr; 2.140</span> s/step','Good; not priority','stop'),
 ('Decomposition','robust gain only <span class="n">~0.2%</span>; scatter <span class="n">0.40%</span>','Stop','stop'),
 ('MPI placement','already <span class="n">1 rank/core</span>, no SMT','Stop','stop'),
 ('ICC generic','<span class="n">2.66%</span> slower than GCC reference','Stop','stop'),
 ('Architecture targeting','256-bit SIMD generated, but smoke <span class="n">SIGFPE</span>','Pause','stop'),
 ('Memory / cache','<span class="n">63.12%</span> stalls; <span class="n">33.64%</span> L3 stalls','NEXT','go'),
 ('MPI time fraction','not measured &#8212; perf cannot separate it','Later profiling','')]
dt=''.join(f'<tr><td class="exp">{a}</td><td>{b}</td><td class="dec {c}">{v}</td></tr>' for a,b,v,c in dr)
S.append(f'''<section class="slide">
{hdr('Decision summary','next technical area')}
<h1>Decision Summary</h1>
<div class="body"><table>
<thead><tr><th>Area</th><th>Evidence</th><th>Decision</th></tr></thead>
<tbody>{dt}</tbody></table>
<div class="decbar"><em>Main next step</em>MEMORY / CACHE BEHAVIOUR &#8212; before any further compiler tuning.</div>
<div class="note">Remaining allocation is low, so the practical next action is to preserve evidence and resume runtime profiling after the allocation resets. ICC architecture targeting is paused, not abandoned: the runtime archive, binary hashes and SIGFPE root-cause analysis are retained.</div>
</div>
{foot(6,'evidence: /scratch/pm78/kj7183/openfoam_cpu &#183; commit b6272eae')}
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
open('slides.html','w').write(CSS+'\n<div class="deck">\n'+'\n'.join(S)+'\n'+JS+'\n</div>\n')
print('slides.html rebuilt as an experiment results report:', len(open('slides.html').read()), 'bytes')
