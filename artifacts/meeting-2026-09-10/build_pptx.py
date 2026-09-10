"""Native PowerPoint build of the same experiment results report.

Tables are real PowerPoint tables and the scaling chart is a real chart object,
so every number stays editable in PowerPoint. Fonts are Calibri and Consolas
because they resolve on both Windows and Mac Office without substitution.
"""
import json, re
from pptx import Presentation
from pptx.util import Inches as In, Pt, Emu
from pptx.dml.color import RGBColor as C
from pptx.enum.text import PP_ALIGN, MSO_ANCHOR
from pptx.chart.data import CategoryChartData
from pptx.enum.chart import XL_CHART_TYPE, XL_LEGEND_POSITION

d = json.load(open('chart-data.json'))

INK=C(0x12,0x15,0x1C); MUTE=C(0x5B,0x64,0x72); FAINT=C(0x8B,0x95,0xA3)
RULE=C(0xD5,0xDB,0xE4); FILL=C(0xF2,0xF5,0xF8); WHITE=C(0xFF,0xFF,0xFF)
ACC=C(0x0B,0x4F,0x9C); CRIT=C(0x96,0x13,0x1A); GOOD=C(0x12,0x61,0x3A)
SANS='Calibri'; MONO='Consolas'
W, H = In(13.333), In(7.5)
M = In(0.55)                      # side margin

prs = Presentation(); prs.slide_width, prs.slide_height = W, H
BLANK = prs.slide_layouts[6]

def tb(slide, x, y, w, h):
    t = slide.shapes.add_textbox(x, y, w, h); f = t.text_frame
    f.word_wrap = True; f.margin_left = f.margin_right = f.margin_top = f.margin_bottom = 0
    return f

def run(p, text, size=11, bold=False, color=INK, mono=False, caps=False, space=0):
    r = p.add_run(); r.text = text
    r.font.size = Pt(size); r.font.bold = bold; r.font.color.rgb = color
    r.font.name = MONO if mono else SANS
    if caps: r.font._rPr.set('cap', 'all')
    if space: r.font._rPr.set('spc', str(int(space*100)))
    return r

RICH = re.compile(r'(\*\*.+?\*\*|`.+?`)')
def rich(p, text, size=11, color=INK, bold_color=None):
    """Mini markup: **bold** and `mono`."""
    for part in RICH.split(text):
        if not part: continue
        if part.startswith('**'): run(p, part[2:-2], size, True, bold_color or color)
        elif part.startswith('`'): run(p, part[1:-1], size, False, color, mono=True)
        else: run(p, part, size, False, color)

def header(slide, stage, jobs):
    f = tb(slide, M, In(0.34), W-2*M, In(0.24)); p = f.paragraphs[0]
    run(p, stage.upper(), 10, True, INK, mono=True, space=1.4)
    f2 = tb(slide, M, In(0.34), W-2*M, In(0.24)); p2 = f2.paragraphs[0]
    p2.alignment = PP_ALIGN.RIGHT; run(p2, jobs, 8.5, False, FAINT, mono=True)
    ln = slide.shapes.add_connector(1, M, In(0.63), W-M, In(0.63))
    ln.line.color.rgb = INK; ln.line.width = Pt(1.75)

def title(slide, text, size=26):
    f = tb(slide, M, In(0.76), W-2*M, In(0.55)); p = f.paragraphs[0]
    run(p, text, size, True, INK)

def note(slide, y, text, size=9):
    f = tb(slide, M, y, W-2*M, In(0.5)); p = f.paragraphs[0]
    p.line_spacing = 1.25; rich(p, text, size, FAINT)

def footer(slide, left, n):
    ln = slide.shapes.add_connector(1, M, In(6.98), W-M, In(6.98))
    ln.line.color.rgb = RULE; ln.line.width = Pt(0.75)
    f = tb(slide, M, In(7.06), W-2*M, In(0.22)); p = f.paragraphs[0]
    run(p, left, 8, False, FAINT, mono=True)
    f2 = tb(slide, M, In(7.06), W-2*M, In(0.22)); p2 = f2.paragraphs[0]
    p2.alignment = PP_ALIGN.RIGHT; run(p2, f'{n} / 6', 8, False, FAINT, mono=True)

def table(slide, rows, widths, x, y, h, hdr_size=8.5, body_size=10, row_h=None):
    nr, nc = len(rows), len(rows[0])
    g = slide.shapes.add_table(nr, nc, x, y, sum(widths), h).table
    g.first_row = False; g.horz_banding = False
    for i, w in enumerate(widths): g.columns[i].width = w
    if row_h:
        for i, rh in enumerate(row_h): g.rows[i].height = rh
    for ri, rowdata in enumerate(rows):
        for ci, cell in enumerate(rowdata):
            c = g.cell(ri, ci)
            c.fill.solid()
            c.fill.fore_color.rgb = WHITE if (ri == 0 or ri % 2) else FILL
            c.margin_left = c.margin_right = In(0.07)
            c.margin_top = c.margin_bottom = In(0.045)
            c.vertical_anchor = MSO_ANCHOR.TOP
            tf = c.text_frame; tf.word_wrap = True
            lines = cell.split('\n') if isinstance(cell, str) else cell['t'].split('\n')
            meta = cell if isinstance(cell, dict) else {}
            for li, line in enumerate(lines):
                p = tf.paragraphs[0] if li == 0 else tf.add_paragraph()
                p.line_spacing = 1.12
                if ri == 0:
                    run(p, line.upper(), hdr_size, True, MUTE, mono=True, space=1.0)
                else:
                    col = meta.get('color', INK)
                    sz = meta.get('size', body_size)
                    if meta.get('sub') and li > 0:
                        run(p, line, sz-1.5, False, FAINT, mono=True)
                    else:
                        rich(p, line, sz, col, meta.get('color'))
    return g

# ---------------------------------------------------------------- slide 1
s = prs.slides.add_slide(BLANK)
header(s, '2026 APAC HPC-AI  ·  progress review', '2026-09-10')
f = tb(s, M, In(1.35), W-2*M, In(0.9)); run(f.paragraphs[0], 'OpenFOAM HPC Optimization Progress', 40, True, INK)
x = M
for i, step in enumerate(['Scaling','Decomposition','MPI Placement','Compiler','Profiling']):
    bw = In(1.9)
    box = s.shapes.add_shape(5, x, In(2.5), bw, In(0.44))
    box.fill.solid(); box.fill.fore_color.rgb = WHITE
    box.line.color.rgb = RULE; box.line.width = Pt(1)
    tf = box.text_frame; tf.margin_left = tf.margin_right = 0
    p = tf.paragraphs[0]; p.alignment = PP_ALIGN.CENTER
    run(p, step, 12, False, INK, mono=True)
    x += bw
    if i < 4:
        a = tb(s, x, In(2.58), In(0.3), In(0.3)); pa = a.paragraphs[0]
        pa.alignment = PP_ALIGN.CENTER; run(pa, '→', 12, False, FAINT)
        x += In(0.3)
meta = [('Case','occDrivAerStaticMesh'),('Cells','65,334,765'),('Solver','simpleFoam'),('OpenFOAM','v2512'),
        ('MPI','OpenMPI 4.1.7'),('Numerics','fixedIter, endTime 150'),
        ('Platforms','Sapphire Rapids / Cascade Lake'),('Experiments','12 validated')]
for i,(k,v) in enumerate(meta):
    col, rw = i % 2, i // 2
    f = tb(s, M + col*In(5.0), In(3.45) + rw*In(0.36), In(4.8), In(0.32))
    p = f.paragraphs[0]; run(p, k+'   ', 11, False, FAINT, mono=True); run(p, v, 11, True, INK, mono=True)
note(s, In(5.35), 'Every experiment is one variable changed against a stated baseline.')
footer(s, 'NCI Gadi  ·  project pm78', 1)

# ---------------------------------------------------------------- slide 2
s = prs.slides.add_slide(BLANK)
header(s, 'Experiment results summary', 'all validated experiments  ·  2026-09-10')
title(s, 'What we tested, what we measured, what we decided')
rows = [['Experiment','Baseline','Change','Measured result','Improvement','Decision'],
 [{'t':'Scaling\nSPR · GCC 8.5 + OpenMPI 4.1.7','sub':1},'1N / 104 ranks\n**8.824444** s/step','2N / 208 ranks\n4N / 416 ranks',
  '**4.296500** → **2.139565** s/step','**2.053868×**\n**4.124410×**',{'t':'Good — not a priority','color':MUTE}],
 [{'t':'Decomposition\nSPR · 4N / 416 ranks','sub':1},'`(16 13 2)`\n**2.147363** s/step','`(26 8 2)`',
  '**2.127211** s/step\nrepeat **2.118657**','headline **0.94%**\nrobust **0.13–0.22%**',{'t':'STOP TUPLE SEARCH','color':CRIT}],
 [{'t':'MPI placement\nSPR · 416 ranks','sub':1},'site-default OpenMPI placement','audit only, no change',
  '1 rank / physical core, no SMT\n`52/socket · 13/NUMA`','already compact',{'t':'NO BINDING TUNING','color':CRIT}],
 [{'t':'ICC generic\nCLX · 4N / 192 ranks · (16 6 2)','sub':1},'historical CLX GCC reference\n**5.144659** s/step','ICC Classic 2021.10 `Opt` (`-O3`)',
  '**5.281517** s/step','**−2.66%** (slower)',{'t':'NOT A WIN','color':CRIT}],
 [{'t':'Architecture targeting\nCLX · ICC 2021.10','sub':1},'generic ICC: core libs\n`ymm=0 / zmm=0`','`-O3 -xCORE-AVX512`',
  '256-bit YMM across all 3 core libs\nsmoke **SIGFPE**','**Performance not measured**',{'t':'PAUSE — FP-trap issue','color':CRIT}],
 [{'t':'Profiling\nCLX · ICC generic · 25-step','sub':1},'full run **5.281517** s/step','perf counters, 4 representative ranks',
  '**5.246991** s/step (−0.65%)\nIPC **1.03** · stalls **63.12%** · L3 **33.64%**','diagnostic — no runtime change',{'t':'MEMORY HIERARCHY NEXT','color':GOOD}]]
table(s, rows, [In(1.85),In(2.15),In(2.05),In(3.0),In(1.85),In(1.33)], M, In(1.42), In(4.7),
      body_size=9.5, row_h=[In(0.26)]+[In(0.72)]*6)
note(s, In(6.28), 'Official scaling runs use different endTime values (40 / 80 / 150), so efficiency above 100% is not presented as controlled superlinear scaling.  ·  '
                  'Static disassembly counts and runtime SIMD percentages are different kinds of evidence and are never interchanged.', 8.5)
footer(s, '178153587 · 178154724 · 178149002 · 178576776 · 178577482 · 178616881 · 178623596 · 178570241 · 178640018 · 178663697 · 178677055', 2)

# ---------------------------------------------------------------- slide 3
s = prs.slides.add_slide(BLANK)
header(s, 'Scaling and decomposition', '178153587 · 178154724 · 178149002 · 178576776 · 178577482 · 178616881')
title(s, 'Scaling is already good; decomposition headroom is nearly gone', 24)
f = tb(s, M, In(1.4), In(5.4), In(0.2)); run(f.paragraphs[0], 'OBSERVED PER-STEP SCALING · SPR', 8.5, True, FAINT, mono=True, space=1.2)
cd = CategoryChartData(); cd.categories = ['1N / 104 ranks','2N / 208 ranks','4N / 416 ranks']
cd.add_series('avg s/step', (8.824444, 4.296500, 2.139565))
gf = s.shapes.add_chart(XL_CHART_TYPE.LINE_MARKERS, M, In(1.62), In(5.4), In(4.3), cd).chart
gf.has_legend = False
pl = gf.plots[0]; pl.has_data_labels = True
dl = pl.data_labels; dl.number_format = '0.000'; dl.number_format_is_linked = False
dl.font.size = Pt(16); dl.font.bold = True; dl.font.color.rgb = INK; dl.font.name = MONO
ser = gf.series[0]
ser.format.line.color.rgb = ACC; ser.format.line.width = Pt(2.5)
gf.category_axis.tick_labels.font.size = Pt(11); gf.category_axis.tick_labels.font.name = SANS
gf.value_axis.tick_labels.font.size = Pt(10); gf.value_axis.tick_labels.font.name = MONO
gf.value_axis.has_major_gridlines = True
f = tb(s, In(6.55), In(1.4), In(6.2), In(0.2)); run(f.paragraphs[0], 'DECOMPOSITION A/B · SPR 4N / 416 RANKS', 8.5, True, FAINT, mono=True, space=1.2)
kv = [['Metric','Value'],
 ['Baseline `(16 13 2)`','2.147363 s/step'],['Candidate `(26 8 2)`','2.127211 s/step'],['Candidate repeat','2.118657 s/step'],
 ['Headline gain','0.94%'],[{'t':'Robust gain','color':ACC},{'t':'**0.13–0.22%**','color':ACC}],
 [{'t':'Same-tuple scatter','color':CRIT},{'t':'**0.40%**','color':CRIT}],
 ['Interface faces','−4.73%'],['Max interface faces','−12.1%']]
table(s, kv, [In(3.5),In(2.7)], In(6.55), In(1.62), In(3.1), body_size=11, row_h=[In(0.24)]+[In(0.34)]*8)
box = s.shapes.add_shape(5, In(6.55), In(4.95), In(6.2), In(0.85))
box.fill.solid(); box.fill.fore_color.rgb = FILL; box.line.fill.background()
tf = box.text_frame; tf.word_wrap = True; tf.margin_left = In(0.14); tf.margin_top = In(0.09)
p = tf.paragraphs[0]; run(p, 'DECISION', 8.5, True, FAINT, mono=True, space=1.2)
p2 = tf.add_paragraph(); p2.line_spacing = 1.2
run(p2, 'STOP TUPLE SEARCH — the robust gain is smaller than the scatter between two runs of the same tuple.', 12, True, CRIT)
bar = s.shapes.add_shape(1, In(6.55), In(4.95), Pt(3.5), In(0.85))
bar.fill.solid(); bar.fill.fore_color.rgb = CRIT; bar.line.fill.background()
note(s, In(6.1), 'Scaling: official runs use endTime 40 / 80 / 150; >100% efficiency is not a controlled superlinear result.  ·  '
                 'Decomposition arms are matched except for the hierarchical tuple.', 8.5)
footer(s, 'OFFICIAL VALID  ·  CONTROLLED VALID', 3)

# ---------------------------------------------------------------- slide 4
s = prs.slides.add_slide(BLANK)
header(s, 'Compiler screening and architecture targeting', '178570241 · 178640018 · 178663697')
title(s, 'Compiler Results')
rows = [['','GCC reference','ICC generic','ICC targeted'],
 [{'t':'Compiler','color':INK},'GCC 8.5.0 (site module)','ICC Classic 2021.10.0','ICC Classic 2021.10.0'],
 ['Flags','`site build, -O3`','`-O3`','`-O3 -xCORE-AVX512`'],
 ['Platform','`CLX · 4N / 192 ranks · (16 6 2)`','same','same'],
 [{'t':'Runtime','color':INK},'**5.144659** s/step','**5.281517** s/step',{'t':'**not valid — no run**','color':CRIT}],
 ['vs reference','—','**−2.66%**','—'],
 ['SIMD in core libraries','`zmm=0 / ymm=0`','mostly scalar, `ymm=0`',
  '`libfiniteVolume` **31,615**\n`libOpenFOAM` **17,550**\n`libincompTurbModels` **2,465**\n`zmm=0`'],
 ['Correctness','valid','valid · `178570241`',{'t':'**SIGFPE smoke** · `178663697`','color':CRIT}],
 ['Status','`HISTORICAL CLX GCC REFERENCE`','`SCREENING VALID`','`BUILD VALID` / `DIAGNOSTIC FAIL`']]
table(s, rows, [In(2.2),In(3.6),In(3.0),In(3.43)], M, In(1.42), In(3.9), body_size=10,
      row_h=[In(0.26)]+[In(0.32)]*5+[In(0.86)]+[In(0.32)]*2)
box = s.shapes.add_shape(5, M, In(5.5), W-2*M, In(0.82))
box.fill.solid(); box.fill.fore_color.rgb = FILL; box.line.fill.background()
tf = box.text_frame; tf.word_wrap = True; tf.margin_left = In(0.16); tf.margin_top = In(0.09)
p = tf.paragraphs[0]; p.line_spacing = 1.3
for t, col, b in [('masked tail → zero-fill ', INK, False), ('{%k1}{z}', INK, False), (' → ', INK, False),
                  ('unmasked vdivpd', CRIT, True), (' → ', INK, False), ('0.0 / 0.0', CRIT, True), (' → ', INK, False),
                  ('FE_INVALID', CRIT, True), (' → ', INK, False), ('-fp-trap=common', INK, False), (' → ', INK, False),
                  ('SIGFPE', CRIT, True)]:
    run(p, t, 11.5, b, col, mono=True)
p2 = tf.add_paragraph()
run(p2, 'crash PC 0x92d6fe in Foam::GAMGSolver::scale()  ·  a compiler/vectorization and FP-trap compatibility issue, not a physical-model numerical failure', 9.5, False, MUTE, mono=True)
bar = s.shapes.add_shape(1, M, In(5.5), Pt(3.5), In(0.82))
bar.fill.solid(); bar.fill.fore_color.rgb = CRIT; bar.line.fill.background()
note(s, In(6.42), 'GCC reference = median of 4 repeats, one retained slowdown outlier; not a controlled paired compiler baseline. Confidence MEDIUM.  ·  '
                  'GCC `zmm=0 / ymm=0` source: prior shipped-binary disassembly recorded in compiler-screening-summary.md, not a measurement from this session.', 8.5)
footer(s, 'SCREENING VALID  ·  BUILD VALID  ·  DIAGNOSTIC FAIL', 4)

# ---------------------------------------------------------------- slide 5
s = prs.slides.add_slide(BLANK)
header(s, 'Runtime profiling', '178677055 · commit b6272eae · PROFILING VALID')
title(s, 'Runtime Profiling — ICC generic, 25-step diagnostic')
f = tb(s, M, In(1.4), In(6.0), In(0.2)); run(f.paragraphs[0], 'REPRESENTATIVE-RANK COUNTERS', 8.5, True, FAINT, mono=True, space=1.2)
pk = [['Counter','Value'],
 ['IPC — rank 24 / node 0','1.030'],['IPC — rank 120 / node 2','0.989'],
 [{'t':'Total stall fraction — rank 120','color':ACC},{'t':'**63.12%**','color':ACC}],
 [{'t':'L3-miss stalls / cycles — rank 120','color':ACC},{'t':'**33.64%**','color':ACC}],
 ['L3-miss share of stalls — rank 120','53.29%'],
 ['LLC load miss rate — rank 168 / node 3','91.36%'],
 ['Branch misses / instr — rank 168','0.206%']]
table(s, pk, [In(4.1),In(1.9)], M, In(1.62), In(2.9), body_size=11, row_h=[In(0.24)]+[In(0.36)]*7)
f = tb(s, In(6.9), In(1.4), In(5.9), In(0.2))
run(f.paragraphs[0], 'FP ARITHMETIC ELEMENTS BY VECTOR WIDTH · RANK 72 / NODE 1', 8.5, True, FAINT, mono=True, space=1.2)
sm = d['profiling']['simd']['element_share_pct']
x0, tot_w = In(6.9), In(5.9)
segs = [('scalar', sm['scalar'], ACC), ('128-bit', sm['b128'], C(0x4A,0x86,0xC8)),
        ('256-bit', sm['b256'], C(0x9D,0xC2,0xE6)), ('512-bit', sm['b512'], RULE)]
xx = x0
for lab, v, col in segs:
    w = Emu(max(int(tot_w * v / 100), Emu(In(0.05))))
    r = s.shapes.add_shape(1, xx, In(1.68), w, In(0.4))
    r.fill.solid(); r.fill.fore_color.rgb = col; r.line.fill.background()
    xx += w
sk = [['Vector width','Share of FP elements'],
 [{'t':'scalar','color':ACC},{'t':'**87.90%**','color':ACC}],
 ['128-bit packed','10.49%'],['256-bit packed','1.61%'],
 [{'t':'**512-bit packed**','color':INK},{'t':'**0.00%**','color':INK}]]
table(s, sk, [In(3.4),In(2.5)], In(6.9), In(2.25), In(1.7), body_size=11, row_h=[In(0.24)]+[In(0.36)]*4)
f = tb(s, In(6.9), In(4.08), In(5.9), In(0.4)); p = f.paragraphs[0]; p.line_spacing = 1.25
run(p, 'Retired FP arithmetic instruction events weighted by width — not FLOPs; FMA semantics differ.', 9, False, FAINT, mono=True)
box = s.shapes.add_shape(5, M, In(4.75), W-2*M, In(0.62))
box.fill.solid(); box.fill.fore_color.rgb = FILL; box.line.fill.background()
tf = box.text_frame; tf.word_wrap = True; tf.margin_left = In(0.16); tf.margin_top = In(0.08)
p = tf.paragraphs[0]; run(p, 'DECISION', 8.5, True, FAINT, mono=True, space=1.2)
p2 = tf.add_paragraph()
run(p2, 'Representative samples indicate memory-hierarchy stalls are more important than arithmetic width.', 13, True, ACC)
bar = s.shapes.add_shape(1, M, In(4.75), Pt(3.5), In(0.62))
bar.fill.solid(); bar.fill.fore_color.rgb = ACC; bar.line.fill.background()
note(s, In(5.55), 'Solver check: 5.246991 s/step against the full-run reference 5.281517 s/step — difference −0.65%.\n'
                  'Caveat: MPI wall-time fraction not measured; the four sampled ranks all sit at core 24 / socket 1 / NUMA 2, '
                  'so there is no socket 0 or NUMA 0/1 coverage, and counts are never combined across event groups.', 9)
footer(s, 'endTime 25  ·  4 nodes / 192 ranks  ·  45.01 SU', 5)

# ---------------------------------------------------------------- slide 6
s = prs.slides.add_slide(BLANK)
header(s, 'Decision summary', 'next technical area')
title(s, 'Decision Summary')
rows = [['Area','Evidence','Decision'],
 ['Scaling','`8.824 → 4.297 → 2.140` s/step',{'t':'Good; not priority','color':MUTE}],
 ['Decomposition','robust gain only ~0.2%; scatter 0.40%',{'t':'Stop','color':CRIT}],
 ['MPI placement','already 1 rank/core, no SMT',{'t':'Stop','color':CRIT}],
 ['ICC generic','2.66% slower than GCC reference',{'t':'Stop','color':CRIT}],
 ['Architecture targeting','256-bit SIMD generated, but smoke SIGFPE',{'t':'Pause','color':CRIT}],
 [{'t':'**Memory / cache**','color':INK},'**63.12%** stalls; **33.64%** L3 stalls',{'t':'**NEXT**','color':GOOD}],
 ['MPI time fraction','not measured — perf cannot separate it',{'t':'Later profiling','color':MUTE}]]
table(s, rows, [In(3.0),In(6.5),In(2.73)], M, In(1.42), In(3.3), body_size=11.5, row_h=[In(0.26)]+[In(0.42)]*7)
box = s.shapes.add_shape(5, M, In(5.0), W-2*M, In(0.72))
box.fill.solid(); box.fill.fore_color.rgb = FILL; box.line.fill.background()
tf = box.text_frame; tf.word_wrap = True; tf.margin_left = In(0.16); tf.margin_top = In(0.08)
p = tf.paragraphs[0]; run(p, 'MAIN NEXT STEP', 8.5, True, FAINT, mono=True, space=1.2)
p2 = tf.add_paragraph()
run(p2, 'MEMORY / CACHE BEHAVIOUR — before any further compiler tuning.', 15, True, GOOD)
bar = s.shapes.add_shape(1, M, In(5.0), Pt(3.5), In(0.72))
bar.fill.solid(); bar.fill.fore_color.rgb = GOOD; bar.line.fill.background()
note(s, In(5.95), 'Remaining allocation is low, so the practical next action is to preserve evidence and resume runtime profiling after the allocation resets.\n'
                  'ICC architecture targeting is paused, not abandoned: the runtime archive, binary hashes and SIGFPE root-cause analysis are retained.', 9.5)
footer(s, 'evidence: /scratch/pm78/kj7183/openfoam_cpu  ·  commit b6272eae', 6)

out = 'openfoam-optimization-review-2026-09-10.pptx'
prs.save(out); print('wrote', out)
