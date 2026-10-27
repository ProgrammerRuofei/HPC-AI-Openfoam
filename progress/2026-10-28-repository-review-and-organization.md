# Repository review, organization and local commits

Date: 2026-10-28 (Asia/Singapore). Scope: local inspection, non-destructive
documentation organization and reviewed Git commits, as requested by the user.

## Initial state and review

- Started on `main`, 19 commits ahead of the locally known `origin/main`.
  The index was empty. No fetch/pull was needed for this local-only task;
  remote branch state was not refreshed.
- Nine tracked files were modified. Untracked files included recent analyses,
  evidence, handoffs, Gadi result copies, submission staging, presentation
  artifacts, older scripts and three independent nested reference checkouts.
- Read all numbered workflow files in order, root instructions, application
  overview, latest dated progress and relevant diffs/evidence summaries.
- Did not connect to a cluster, inspect password files, change authentication,
  submit/cancel jobs, contact support, push or alter scientific inputs.

## Findings preserved in the navigation

1. Root README and APPLICATION retained early "ASPIRE2A blocked" and "current
   site baseline" statements. Added clear historical context and current
   cluster-specific entry points without deleting the old failure trail.
2. The latest local ASPIRE2A evidence is the 2026-10-26 weighted Scotch
   PGO/binding stall audit, not the 2026-10-22 queued state. Both PGO/binding
   blocks completed; intermittent long elapsed-time steps prevent a stable
   performance-win claim. Support inquiry text is still an unsent draft.
3. A/B/C repeats do not establish a stable plain-versus-weighted Scotch winner.
   Uniform-weight B has a Cd reference-band issue requiring scientific review.
   The cleanup does not resolve correctness or attribute stalls to the fabric.
4. Submission staging exists with original evidence, but its pending checklist
   and later "previously submitted" wording are inconsistent. No delivery
   receipt or final competition score was established here. Do not relabel
   staging as proof of an official outcome.
5. Imported teammate measurements remain team/teammate evidence. Copied Gadi
   records came from another worktree and refer to some scripts/progress files
   not present in this checkout; retained remote evidence paths are not a
   self-contained reproducibility guarantee.

## Organization and commit groups

- Authentication workflow and the two setup/test handoffs: separate commit;
  only policy, command forms and metadata, never credential values.
- Analysis/history and lightweight evidence: preserve existing content and
  paths; include local parsing tools, tables, supporting logs and job records.
  Parser main functions were not run and historical summaries not regenerated.
- Team submission staging: retain the existing package with its source commit,
  original manifest and Basic/Bonus boundaries. This is archival ingestion,
  not permission to run/transfer/upload its scripts or change the fixed case.
- Navigation/hygiene: current cluster guides, historical labels, reference and
  evidence boundaries, and this handoff. No build/launcher/resource changes.

No existing remote-execution script was moved or edited. Existing untracked
standalone Gadi build scripts and generic compiler-screening scripts are left
outside these documentation/evidence commits pending their own scope/review.

## Git retention policy

Added `.gitignore` for OS/interpreter/tool noise, accidental credential files,
three nested reference checkouts, large raw mpiP reports, the private Career
Fact Sheet, working presentation drafts and raw slide-tool response dumps.
Nothing was deleted, cleaned, reset or overwritten by those ignore rules.

Four local-only raw mpiP reports total 149,822,147 bytes. Their SHA256 values
are recorded in `planning/evidence/RAW-REPORTS.sha256`; supporting logs,
derived tables and parsers remain versioned. A fresh clone needs the reports
restored separately before rerunning their parser. The nested reference
checkouts, presentation assets/decks and private career material are not
silently converted into repository source or personal contributions.

## Validation and completion record

The existing submission manifest checked successfully: all 116 listed files
matched, without regenerating or changing the manifest. The Step 2 manifest
also matched all 85 entries, and all four local-only raw-report hashes match
the new manifest. This task does not claim a new benchmark or profiler result.

- Existing local Python parsers: syntax compilation passed with bytecode sent
  to a new `/private/tmp` cache, not into the repository; no parser main ran.
- Staging shell/PBS syntax: all 16 scripts plus the two compiler-rule wrappers
  passed `bash -n`; none was executed or edited.
- Canonical navigation: checked 13 documents / 135 local links; zero missing
  targets and zero links depending on an unversioned local-only target after
  the prospective navigation commit. This checks paths, not every Markdown
  anchor or historical document's external references.
- High-confidence private-key/API-token pattern checks found no matching
  files in the reviewed text scope. No credential file was opened; this is a
  scoped pattern check, not a guarantee against every possible secret.
- Committed-blob verification: checked `git show HEAD:<path>` bytes against
  all 116 submission and 85 Step 2 manifest entries (201 total), with zero
  mismatches. This also checks that staging/commit did not normalize or alter
  the checksummed evidence relative to the original manifests.
- Newly edited navigation passed the default whitespace check. Archival
  ingestion preserves historical CSV/JSON CRLF, log spacing and Markdown
  two-space hard breaks; full archive `git diff --check` therefore reports
  pre-existing whitespace. Did not format, normalize or re-hash those files
  merely to suppress warnings.
- Added the missing weighted-Scotch PGO/binding README as a status/evidence
  index and an artifacts inventory explaining why local presentation assets
  are not canonical scientific evidence or automatically versioned.

Completed local commits:

| Commit | Scope |
| --- | --- |
| `a45be0b` | Five authentication policy/setup records; no credential values. |
| `9f17a9b` | 260 analysis/history/parsed-evidence files, approximately 10 MB; no large raw mpiP report. |
| `c6d43b9` | 118 files preserving the existing team submission staging and original checksums. |
| This note's navigation/hygiene commit | Cluster guides, current/history labels, local retention rules, inventories and handoff. |

The two parent-level submission command inventories are retained as historical
transfer provenance, not executed in this task. Use Git log to identify the
final navigation commit; no amend, history rewrite, force operation or push
is part of this organization.

## Remaining work / resume boundary

- Final submission/outcome evidence and the ASPIRE2A stall root cause remain
  unresolved; site contact or new experiments need separate authorization.
- Review remaining local presentation/binary assets and standalone scripts
  separately before choosing what to version. They remain on disk. The final
  review found 119 non-ignored untracked files deliberately outside this pass:
  109 artifacts, six standalone build files, three generic screening scripts
  and one spreadsheet under results. No tracked user modification was left
  out of the reviewed commit groups; these untracked files are not "cleaned"
  by deleting them or pretending they were archived.
- Career Hub, resume, LinkedIn and career positioning were not edited.
- No push is included. Local commits need separate authorization before any
  remote synchronization or execution.
