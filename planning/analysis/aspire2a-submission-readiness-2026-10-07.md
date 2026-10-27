# ASPIRE2A submission readiness — 2026-10-07

Scope: read-only audit of the local control repository, retained teammate
results, the approved ASPIRE2A project root, and (after explicit user
authorization) the named OpenFOAM scratch cases. No remote file was changed.

Official sources: [2026 OpenFOAM task rules](https://github.com/hpcac/2026-APAC-HPC-AI/blob/main/2.%20OpenFOAM%20HPC%20Task%20Rules.md),
[2026 competition milestones](https://www.hpcadvisorycouncil.com/events/2026/APAC-AI-HPC/).
The 2026 page says to submit slides and code **before October 9**, without
specifying an hour or time zone. Plan to submit by October 8 Singapore time;
confirm the exact cutoff and delivery mechanism with the organizers.

## Current evidence

### Basic candidate: AOCC 5.0 / Open MPI 5.0.10 / Scotch

All three retained scripts use official OpenFOAM v2512, 128 ranks per node,
`scotch`, and the shared runner's full Allrun preparation chain. The scripts
request 40 / 80 / 150 steps at 1 / 2 / 4 nodes. The local PBS stdout reports
completion and the official average wall-clock metric. Values below are from
the original PBS stdout, not the rounded teammate CSV.

| Nodes | Steps | Job ID | Average s/step | Cd (rounded in teammate CSV) | Source |
| ---: | ---: | --- | ---: | ---: | --- |
| 1 | 40 | `19730481` | 13.35208007676923 | 0.4360 | `references/teammate/OpenFoam-HPCAI-26/experiments/occdrivaer-static/outputs/occdrivaer_1node_aocc_scotch_v1.o` |
| 2 | 80 | `20047559` | 6.378504090810126 | 0.3271 | `references/teammate/OpenFoam-HPCAI-26/experiments/occdrivaer-static/outputs/occdrivaer_2node_aocc_scotch_v1.1.o` |
| 4 | 150 | `20064271` | 2.912440185442953 | 0.2841 | `references/teammate/OpenFoam-HPCAI-26/experiments/occdrivaer-static/outputs/occdrivaer_4node_aocc_scotch_v1.o` |

The original solver logs were found in all three scratch cases, reach the
expected final step, contain the cited average line, and end normally. The
original coefficient files have exactly 40 / 80 / 150 numeric rows and
final Cd 0.43598848994683165 / 0.32713924421645513 /
0.28405059711700609. All three use byte-identical `fvSchemes`, `fvSolution`,
`forceCoeffsAll` and `decomposeParDict` files. A semantic diff against the
shipped template is still needed for submission.

The three PBS scripts point to the same named AOCC build path and Open MPI
library, but these historical runs do not preserve per-run binary hashes or
complete input/mesh hashes. Each scaling point is one run. The computed
speedups from the official metric are 2.0933x at 2 nodes and 4.5845x at
4 nodes; efficiencies above 100% must be presented as observations subject
to run noise, not established superlinear scaling. The 2-node Cd 0.3271
is below the approximate 0.34 reference but has no
official hard pass/fail band.

### Bonus candidate: KaHIP decomposition

`KaHIP fast`, imbalance 0.01, has a retained unbound 4-node / 512-rank
150-step result of **2.875901458550335 s/step**, job `20030922`, Cd(150)
0.280043747. The matched unbound Scotch run is 2.912440185442953 s/step,
making the observed one-run improvement 1.27%. The bound KaHIP run, job
`20092999`, recorded 2.869256832046979 s/step, but binding differs from
the Scotch comparison, so it is a separate result. The original 4-node logs
and coefficient files were checked for step 150, final metric, final Cd and
normal completion. Source:
`planning/analysis/aspire2a-4n512-evidence-qa-2026-09-18.md`.

The September 25 addendum classifies KaHIP as Bonus and explicitly exempts a
decomposition-only change from the extra pre-change baseline; the published
Cd sanity check still applies. Submit a Basic result first. Avoid claiming a
repeatable 1.27% gain from one run per configuration.

### Profiling

Job `25702468.pbs101` (Step 3 mpiP v2) finished 2026-10-07 03:29 SGT,
PBS `Exit_status=0`, four nodes / 512 ranks, 00:23:13 walltime. Its PBS
stdout ends in `STEP3_CLEAN_MPIP_PASS`. A0, P0, A1 completed 40 steps; all
three coefficient files have identical SHA256. The steps-20–40 control means
are 2.843809523810 and 2.834285714286 s/step, a 0.335458% difference.
The profile run's estimated overhead is 10.114056%. These are diagnostics,
not official 150-step competition performance. The full v2 mpiP report and
three per-arm logs exist under the scratch case path. The report has the
expected aggregate section and end footer. It has not been retrieved or
independently parsed by the existing mpiP parser in this audit.

### Build and IEEE flags

The retained AOCC 5.0 build script uses the official v2512 source tree with
`WM_COMPILER=Amd`, `WM_MPLIB=SYSTEMOPENMPI`, `WM_LABEL_SIZE=32` and stock
`Opt`. The remote `wmake/rules/General/common/c++Opt` sets `-O3`; inspection
of the involved Amd/Clang rules found no `-Ofast` or `-ffast-math`. The source
tree is an unpacked release without `.git`, so record its release provenance
and verify any source/build-rule edits before calling it Basic.

## Submission checklist

Official required content, with current status:

| Requirement | Status | Next action |
| --- | --- | --- |
| 4-node Basic run | Original log and Cd checked | Verify full case/input provenance, PBS record, build identity, and script. |
| 1/2/4 scaling | Original logs and Cd checked | Produce a labeled plot/table; verify semantic input differences and explain single-run uncertainty. |
| Decomposition method, ranks, coefficients | Scripts exist | Include Basic Scotch parameters and Bonus KaHIP `config=fast`, `imbalance=0.01` as text. |
| Full preparation chain | Shared runner exists | Include runner, node scripts, and stage logs showing every required command and switch. |
| v2512 and build provenance | Partial | Include AOCC build script, `WM_*`, compiler flags, release source provenance, and any `wmake/rules/*` patch. Confirm no hidden source/build-rule edits. |
| Required case text inputs | Partial | Include actual `decomposeParDict`, `controlDict`, `caseDefinition` for submitted runs. |
| 4-node solver log and `coefficient.dat` | Verified present remotely | Collect into submission package after confirming approved retrieval path and transfer form. |
| Structured result summary | Not consolidated | The control repository's `results/metrics.csv` still contains only historical Phase 0 rows; create a separate, source-linked ASPIRE2A submission table from original logs and Cd files. |
| Presentation slides | Not final | One combined deck for Qwen and OpenFOAM; show Basic, Bonus, scaling, correctness, method and bottleneck. |
| Delivery mechanism and deadline hour | Unknown | Confirm with organizers promptly. |

Do not include mesh, `processor*`, binaries or an OpenFOAM install tree in the
submission. The official suggested directory layout is a guide, not a
requirement. Keep Basic and Bonus results clearly labeled.

## Priority and effort

1. Lock the Basic Scotch 4-node candidate and finish its provenance check.
   Most log/Cd inspection is now done; allow 1–2 person-hours for remaining
   input, build and PBS checks.
2. Assemble a text-only, reproducible OpenFOAM package with build/run scripts,
   inputs, logs, Cd, result summary, and provenance. Allow 3–5 hours after
   evidence is accessible.
3. Create and check the OpenFOAM section of the combined deck. Allow 3–5
   hours. The Qwen section and whole-team review require separate capacity.
4. Treat further optimization experiments as optional. Queue time and
   scientific validation make them unsuitable as a prerequisite for the
   imminent submission.

## Git and remote state observed

Local `main` is 12 commits ahead of `origin/main` and has existing modified
and untracked files. The ASPIRE2A control checkout points to the same HEAD
`f6cb2ed527f867ad67d10c9dbe91dc9db5e38668`; it has existing untracked
PBS outputs. No pull, commit, push, transfer, job or remote write was done.
The approved project root does not contain a finished submission package.
Remaining adapter TBD fields relevant to delivery are the documented SCP and
rsync forms; no transfer was attempted. Other adapter TBD fields are listed
in `workflow/00-General-SSH-Rules.md`. Remote state changes: none.
