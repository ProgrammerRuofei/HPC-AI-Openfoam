# Remaining 119 untracked files: review and archival handoff

Date: 2026-10-28 (Asia/Singapore). Scope: user-authorized local classification,
non-destructive organization and Git commits. No push or remote work.

## Initial state and decisions

Started at `59826bd` on `main`, 23 commits ahead of the locally known
`origin/main`; the index and tracked working tree were clean. Exactly 119
non-ignored untracked files remained from the preceding organization pass.
Recorded their original paths, sizes and SHA256 before any changes.

The cohort totals 37,975,948 bytes. Per-file decisions are in
[`planning/repository-audit/2026-10-28-untracked-files.csv`](../planning/repository-audit/2026-10-28-untracked-files.csv);
the readable decision record is
[`planning/2026-10-28-untracked-file-classification.md`](../planning/2026-10-28-untracked-file-classification.md).

- `commit`: 53 original files, 10,067,250 bytes.
- `ignore-generated`: 60 original files, 12,616,786 bytes.
- `local-only-draft`: six original PPTX files, 15,291,912 bytes; also ignored
  by exact filename, not deleted or treated as byte-identical duplicates.

Ignore rules are exact paths for the inspected cohort, not blanket PNG/PPTX
rules. New unique figures/decks will remain visible to Git. Ignored files are
still on disk but are not backed up by a clone/push of this repository.

## Review and verification

- Read all numbered workflow files, current root/application instructions,
  preceding handoff, Git state, eight existing shell/PBS scripts and relevant
  presentation/design sources. No existing file in the 119-file cohort was
  intentionally edited or moved.
- Presentations skill: read-only ZIP/XML/text and version inspection of all
  eight PPTX files. Selected a template and a content-review snapshot for
  historical archival, not final release. No deck edits, export, cloud access
  or PowerPoint visual QA. Text equality across templates did not imply
  equality of media/layout parts.
- Spreadsheets skill: imported/inspected the existing workbook read-only with
  bundled Artifact Tool. No formulas were reported; no recalculate, workbook
  change, export or source normalization. Added separate provenance notes for
  runtime-version labels and external worktree pointers.
- All eight shell/PBS scripts passed `bash -n`. The existing figure generator
  passed syntax compilation with bytecode only under a new `/private/tmp`
  review directory. None of these scripts was executed or parameterized.
- All 60 PNGs passed image integrity checking; all 30 SVGs parsed with no
  script/foreignObject, event handler or external image resource found.
- All eight PPTX and the XLSX passed ZIP/XML integrity checks; no macro parts
  or high-confidence private-key/API-token patterns were found in reviewed
  Office/XML/text content. This is scoped checking, not an all-secrets proof.
- Both figure ZIPs passed CRC checks; all 20 plus six members matched existing
  local files byte-for-byte. Archives were not extracted over or repacked.
- Sampled two existing images visually; did not claim a complete visual or
  scientific revalidation of all historical figures. Historical sharp titles,
  pending states and PMPI/mpiP definitions still require their original
  evidence/context before reuse.

## Documentation and source boundaries

Added archive notes beside Gadi build files and historical presentations,
a README for the legacy screening harness, workbook notes, a readable
classification and the complete original-hash inventory. Updated artifact
and project navigation so committed assets are distinguished from local-only
exports. Prior scientific logs/dictionaries/manifests were not changed.

The preserved build README contains an early pending state; new archive notes
point to later records instead of rewriting it. The generic harness remains
the older Gadi `normal`/192-rank path, not a `normalsr`/416-rank deployment.
No compiler/MPI/resource/scientific setting was chosen or changed. Committing
existing implementation files does not authorize a future build or job.

## Completion and resume

Final original-file hash, committed-blob, link and Git-state checks are
recorded below. No file deletion, cleanup, reset,
history rewrite, credential-file access, SSH configuration change, cluster
connection, scheduler action, installation, cloud edit or push is in scope.
Scientific/competition outcomes remain those of the previous evidence audit.

### Completed verification

- All 119 original files still exist as regular, non-symlink files at their
  original paths and retain their initial sizes/SHA256. No original file was
  removed, moved, edited or re-exported.
- All 53 selected original files are committed; their actual `git show
  HEAD:<path>` blobs match the initial hashes exactly. No normalization of
  archived source or Office files occurred during staging.
- `git check-ignore` matches precisely the other 66 cohort files, all still
  present: 60 generated/QA exports and six local-only drafts. No selected
  source was hidden by a broad ignore rule.
- Checked 11 navigation/notes documents and 104 local links, with no missing
  target. The final check also verifies targets exist in the committed tree,
  not just in a local cache. Markdown anchors and cloud links were not audited.
- Default whitespace checks pass for new/edited documentation. Two preserved
  design catalogs have pre-existing blank EOF lines; archived without changing
  their hashes. Do not claim the entire historical archive was reformatted.

### Commit groups

| Commit | Scope |
| --- | --- |
| `b2afa3e` | Nine original build/screening files, two adjacent archive notes/README files and the complete 119-file hash inventory. |
| `5ffd901` | The other 44 original reporting files and three adjacent source/provenance notes. |
| This handoff's classification-policy commit | Exact ignore rules, readable classification, project navigation and completion record. |

The final policy commit is identifiable with `git log` rather than embedding
its own hash here. No push or remote synchronization was performed. The prior
handoff's count of 119 remaining files is a historical first-pass snapshot;
this follow-up resolves that cohort without deleting or hiding unreviewed
future files.
