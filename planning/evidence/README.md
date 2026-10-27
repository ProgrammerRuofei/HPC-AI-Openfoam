# Evidence retention and Git boundaries

This directory stores supporting evidence, extracted tables and local
postprocessing tools. Interpretation belongs in `planning/analysis/`; job
outcomes and scientific validity remain attached to their original logs.

## Recorded datasets

| Dataset | Tracked material | Raw/provenance boundary |
| --- | --- | --- |
| `aspire2a-mpip-4n512-2026-09-23/` | Existing parser, five extracted CSVs, decomposition/solver logs, coefficient artifacts and command provenance | Three large `*.mpiP` reports remain local and are ignored. Historical coefficient artifacts are stale; see the Step 1 analysis, not a new correctness claim. |
| `aspire2a-step2-repeatability-25523028/` | Existing parser, summaries, checksum manifest, fresh logs/coefficients, affinity and runtime metadata | Same-allocation A/A evidence only; do not generalize its repeatability to all allocations. |
| `aspire2a-submission-readiness-2026-10-07/` | Inspection-command record | Historical readiness inspection, not proof of final delivery. |
| `2026-10-08-hierarchical-remote-check.md` | Dated read-only inspection note | Historical status; later evidence may supersede it. |

The separate Step 3 v1 archive stays at
`experiments/aspire2a-six-step/outputs/step3-v1-25695102/`.
Supporting logs and correctness records are retained; its large raw `*.mpiP`
file is also local-only. The committed result note records its report hash,
byte size and the incomplete A0/P0/A1 outcome.

## Reproduction limits

- `.gitignore` excludes `*.mpiP` but not the scientific `.log`, `.dat`, PBS
  `.o/.e` evidence or extracted tables. No raw report was deleted.
- A fresh clone cannot rerun the mpiP parser without restoring the named raw
  reports at their original paths. Their locations/job provenance are in the
  existing Step 1 analysis and the Step 3 result record.
- [`RAW-REPORTS.sha256`](RAW-REPORTS.sha256) fingerprints the four local-only
  reports. Check from the repository root with
  `shasum -a 256 -c planning/evidence/RAW-REPORTS.sha256` after restoring them.
  It is not an assertion that a fresh clone contains those reports.
- Local parser main functions can overwrite derived summaries. The repository
  organization checks syntax/hashes; it does not rerun those main functions
  against immutable evidence or silently regenerate historical tables.
- A copied runtime module name is not proof of the effective loaded library
  version; preserve the explicit runtime-provenance limits in each dataset.
- Do not store credentials, private keys, tokens or password-file contents
  here. Paths and authentication policy in workflow notes are not credentials.
