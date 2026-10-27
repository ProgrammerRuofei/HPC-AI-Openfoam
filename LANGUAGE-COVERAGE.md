# English coverage of the repository handoff

Prepared: 2026-10-28. Start with [TEAM-GUIDE.md](TEAM-GUIDE.md) and the
[English project index](PROJECT-INDEX.en.md).

The user requested English pushed content, or an English backup alongside
original material. This handoff uses the latter approach for substantial
Chinese records: preserve their original bytes and add adjacent English
companions covering their sections, tables, proposals and evidence limits.
Historical status warnings are explicit editorial additions, not new results.
Quantitative values remain attributable to the original sources they cite;
translation is not a new benchmark or independent scientific revalidation.

## Companion map

| Original record | English backup | Scope / status |
| --- | --- | --- |
| [Project index](PROJECT-INDEX.md) | [PROJECT-INDEX.en.md](PROJECT-INDEX.en.md) | Cluster-first navigation and reading rules |
| [ASPIRE2A guide](planning/aspire2a-guide.md) | [aspire2a-guide.en.md](planning/aspire2a-guide.en.md) | Results, analysis, later experiments and storyline |
| [Gadi guide](planning/gadi-guide.md) | [gadi-guide.en.md](planning/gadi-guide.en.md) | Stack/scaling/profile records and provenance |
| [Basic readiness](planning/2026-10-08-basic-readiness-and-extra-work.md) | [Basic readiness, English](planning/2026-10-08-basic-readiness-and-extra-work.en.md) | Historical 2026-10-08 evidence, packaging gaps and E1-E4 proposals |
| [Results/storyline](planning/2026-10-08-openfoam-results-and-storyline.md) | [Results/storyline, English](planning/2026-10-08-openfoam-results-and-storyline.en.md) | Historical comparisons, narrative and profiling-loop proposals |
| [Evidence/storyline draft](planning/2026-10-22-openfoam-evidence-storyline-draft.md) | [Evidence/storyline, English](planning/2026-10-22-openfoam-evidence-storyline-draft.en.md) | Source updated 2026-10-25; XYZ, A/B/C, partition counts, MPI calls, METIS and limits |
| [119-file classification](planning/2026-10-28-untracked-file-classification.md) | [Classification, English](planning/2026-10-28-untracked-file-classification.en.md) | Decisions, byte counts, validation and local-only boundaries |
| [Team presentation plan](planning/2026-apac-hpc-ai-presentation-plan.md) | [Presentation plan, English](planning/2026-apac-hpc-ai-presentation-plan.en.md) | Historical OpenFOAM/Qwen slide and speaker plan; Qwen remains unverified teammate-PDF context |
| [Archived design storyline](artifacts/google-redesign-20261022/openfoam-storyline.md) | [Archived storyline, English](artifacts/google-redesign-20261022/openfoam-storyline.en.md) | Frozen 2026-10-22 snapshot; then-pending state intentionally preserved |

Historical wording such as "final", "submitted" or "pending" in an original
does not establish current delivery or scheduler state. Later A/B/C and
PGO/binding audits override outdated proposals or apparent single-run winners.
English PMPI tables call the complement **non-MPI**, not pure compute; the
original tables' "Compute share" wording is not adopted as a scientific claim.

## Other mixed-language items

- Root, planning, results and progress README navigation is now English. Their
  historical experiment narratives are otherwise preserved.
- [Performance methodology](planning/openfoam-performance-methodology.md)
  was already English apart from bilingual headings and one summary sentence.
  Headings have English equivalents on the same line; the sentence is now
  English. No methodology fact or experimental setting was changed.
- [Project artifact manifest](planning/project-artifact-manifest.md) is English;
  the remaining Chinese characters occur only in a verbatim original external
  filename. The same row supplies the English archive name
  `openfoam_gadi_baseline_v2_copy.pptx`. The original filename is provenance,
  not untranslated explanatory content, and was not renamed.
- Existing selected presentation/workbook sources were reviewed during the
  preceding archive pass. They remain historical derived artifacts, not new
  English exports or newly validated final competition materials.
- Git commit history and raw evidence are not translated or rewritten. Large
  ignored reports, local reference checkouts, six unselected PPTX drafts and
  generated/QA exports are not published by a push. See the teammate guide
  and original manifests for the exact clone boundary.

## Original-source fingerprints

These SHA256 values identify the nine source snapshots translated in this
handoff. They are not checksums of solver outputs or a claim that every
external reference is present. Future edits require a new coverage review.

| Source | SHA256 |
| --- | --- |
| `PROJECT-INDEX.md` | `e5d063f18db75448dfe21dc5c8d0b2f017ebf9710aa893e259507184daa200c5` |
| `planning/aspire2a-guide.md` | `68f42667107f7b264cde7ef51752bba5d8f9dd0410efb384367d868fd004b053` |
| `planning/gadi-guide.md` | `86d300960b9aceae47c170cd643dd95f3efdf746d4315b5f20912fa900e44071` |
| `planning/2026-10-08-basic-readiness-and-extra-work.md` | `698f08ab6e55efbdcc21d482234f1555c630d6fbd30db32307f111980cba7f5f` |
| `planning/2026-10-08-openfoam-results-and-storyline.md` | `c69cfd948a0866415e21a29d2dbd18a2548ab13d7b694fa24c73eff9c9173d2b` |
| `planning/2026-10-22-openfoam-evidence-storyline-draft.md` | `2227fa3cb0b195d31c8ccbc92652f76b9ed988c6c39c7be91d621ebabb393408` |
| `planning/2026-10-28-untracked-file-classification.md` | `038970e850dc95fb71d82d3b20498c4bf16255e2a9e4d12600581361fbb322f9` |
| `planning/2026-apac-hpc-ai-presentation-plan.md` | `cc317d8ec52d5997fad179cd1256ec2eedd776cf1b7c6efd109933c5bbd25256` |
| `artifacts/google-redesign-20261022/openfoam-storyline.md` | `d364a98da3e2a5d63ee91f044a28c64de34ce46cc0dfd056af8296b7303e7510` |
