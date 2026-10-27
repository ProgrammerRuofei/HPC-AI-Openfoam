# Historical successful-four-node workbook: provenance notes

The existing [XLSX](gadi-normalsr-successful-4n-runs.xlsx) is a compact derived
report, archived byte-for-byte during the 2026-10-28 repository review. It was
imported/inspected read-only, not edited, recalculated, rendered or exported.
Its original SHA256 is in the
[classification manifest](../planning/repository-audit/2026-10-28-untracked-files.csv).

The worksheet `Successful 4N runs` spans `A1:AF10`, with a table/header at
row 5 and five retained run rows. No formula records were found by the
read-only inspection. Cached/static cells are not a recalculation test.

## Material limitations

- Columns J/K, especially rows 7–9, contain UCX/UCC version labels that must
  not be read as proof of the effective runtime UCX version or active UCC
  collectives. The [run registry](gadi-gcc162-ompi5010-scotch/run-registry.md)
  explains that distinction and the later matching-environment diagnostic.
- The workbook has source/evidence columns pointing partly to another local
  worktree. These are provenance pointers, not files guaranteed in a clone.
- Preserve each row's measured-versus-calculated SU wording and numerical
  precision. A displayed success label does not independently validate the
  scientific inputs, Cd or performance comparison.
- Historical `official`/baseline labels do not establish final competition
  delivery, scoring or outcome, nor original run-operator ownership.

Use the [Gadi evidence guide](../planning/gadi-guide.md), underlying logs and
run registries for current claims. Any workbook correction is a separate
content-edit task; this classification does not silently repair the source.
