# Remaining 119 untracked files: classification and retention decisions

English companion to [the original decision record](2026-10-28-untracked-file-classification.md).
Date: 2026-10-28. Scope: the 119 files left untracked after the preceding pass,
totaling 37,975,948 bytes. This was not a new experiment analysis, final
competition-configuration decision or slide release. Individual sizes,
original SHA256 values, decisions and reasons are in the
[complete manifest](repository-audit/2026-10-28-untracked-files.csv).

## Classification

| Decision | Files | Bytes | Contents |
| --- | ---: | ---: | --- |
| `commit` | 53 | 10,067,250 | 30 SVGs, five standalone presentation PNGs, six design/content sources, two historical PPTX snapshots, six build files, three screening scripts and one XLSX |
| `ignore-generated` | 60 | 12,616,786 | 30 paired PNGs, two ZIPs, 25 source/preview/QA screenshots and three tool-QA JSONs |
| `local-only-draft` | 6 | 15,291,912 | Historical PPTX drafts not selected for this archive |

The latter categories were added to `.gitignore` by **exact path** and left
in place. They are not worthless and were not deleted; they simply are not
distributed by Git in this pass. Broad rules do not hide future unique files.

## Material worth committing

- **Figure sources:** 30 SVGs are scalable sources for existing figures and
  retain their original bytes; their 30 paired PNGs remain local. The five
  standalone Google-redesign PNGs have no paired SVG, so they and the existing
  `draw_figures.py` were retained. The generator contains hard-coded historical
  values; it was syntax-checked, not executed.
- **Design records:** two `design-system.json` files, two design catalogs, the
  existing `openfoam-storyline.md` and the generator above form six sources.
  They preserve contemporary layout/content snapshots, not current scientific
  conclusions or a complete backup of cloud decks.
- **Representative historical PPTX:** `editable-template-v5` and
  `openfoam-first-review-v2` preserve a later template iteration and a populated
  review snapshot. Selection was historical archival, not a best-design award
  or final-delivery confirmation. Six others remain local. Template-series
  text is equal but image/layout parts differ: not byte-identical duplicates.
- **Run infrastructure:** six Gadi build files (README and five scripts) plus
  three generic screening scripts were archived unchanged at their original
  paths. Compiler/MPI/resources, scientific inputs and runtime behavior were
  not changed. Read adjacent archive notes; a commit does not authorize use.
- **XLSX:** the 7,424-byte Gadi summary was archived unchanged, with separate
  [workbook notes](../results/gadi-successful-4n-workbook-notes.md); no cell
  data were modified.

## Why ignore or retain locally

- **30 PNGs:** every file has a same-name SVG. SVG was selected as the
  versioned source; this does not assert PNG/SVG binary equality. Original
  PNGs retain their paths.
- **Two ZIPs:** CRC checks passed; all 20 and six members matched existing
  files byte-for-byte and added no unique evidence. ZIP originals remain;
  they were not repackaged.
- **25 screenshots:** partial source/preview/QA viewing records, not substitutes
  for the original deck, solver logs or correctness evidence. Not promoted to
  new final deliverables.
- **Three QA JSONs:** zero layout issues does not establish scientific
  correctness or performance validity; local retention suffices.
- **Six deck drafts:** early templates, an unselected review and older
  visualized content remain local. The latter has stronger early "fastest"
  and "binding helps" titles that cannot override later repeat/stall evidence.
  Review-v2 is also not the current final result; consult run registries for
  PGO, decomposition and submission status.

## Content and reproduction limits

1. SVG/PNG/PPT/workbooks are derived presentation material, not raw measurement
   or same-run Cd. Historical workload descriptions, pending states and
   "final" language must not be copied uncritically. Use APPLICATION/official
   inputs for case identity and newer handoffs for status.
2. Some XLSX UCX/UCC fields are module/version labels, not proof of effective
   historical libraries or active collective components; separate notes say so.
3. The build README's early pending snapshot is not live scheduler status.
   Added archive notes point to later records. Generic screening's `normal` /
   192-rank path is not the current `normalsr` / 416-rank baseline.
4. PPT/JSON review was local structure/text/provenance inspection, not
   PowerPoint/cloud rendering or publishing. No file was re-exported for
   archival. Only two existing images were sampled visually, not full visual QA.
5. All 119 originals and paths remain. This classification pass accessed no
   password file, cluster or cloud slides; submitted no job; installed no
   software; changed no SSH configuration or experiment direction; and did not
   push. A subsequent authorized GitHub publication is a separate action.

## Local validation

- Compared all 119 initial/final SHA256 values to check originals were unchanged.
- Eight shell/PBS scripts passed `bash -n`; the existing Python generator
  passed syntax compilation with bytecode only in a temporary directory.
  Script main bodies were not run.
- 60 PNGs passed decode integrity; 30 SVGs parsed with no script,
  foreignObject, event handler or external image resource. Eight PPTX and one
  XLSX passed ZIP/XML integrity checks.
- No high-confidence private-key/API-token pattern or Office macro part was
  found in scoped review. This is not an assurance that every possible secret
  is detectable. Password files outside the repository were never read.
- The Spreadsheets skill's read-only import/inspection checked workbook
  structure and values, without recalculation, modification or export. The
  Presentations skill's read-only boundary guided deck structure/version review.

Completed commits and final state are in the
[classification handoff](../progress/2026-10-28-untracked-file-classification.md).
