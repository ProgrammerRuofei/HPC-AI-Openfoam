# ASPIRE2A Scotch A/B/C: completed-run evidence check

Date: 2026-10-25 (Asia/Singapore). Scope: read-only status and evidence
inspection for the previously authorized A/B/C study. No job was submitted,
cancelled, retried, or changed; no remote file was written.

## Job state and provenance

The prior 2026-10-22 inspection established PBS `F` / `Exit_status = 0` for
blocks 1 and 2 (`25909583.pbs101`, `25909584.pbs101`). On 2026-10-25,
`qstat -x -f 25909585.pbs101` returned `Unknown Job Id`; this is expired PBS
history, not a failure diagnosis. The retained block-3 scratch tree and PBS
output show `script_exit_rc=0`, `SCOTCH_ABC_PASS`, and an empty PBS stderr.
All three block roots contain `provenance.txt`: AOCC 5.0, Open MPI 5.0.10,
stock Opt, 4 nodes / 512 ranks / 128 per node, `ppr:128:node` without explicit
binding, 150 steps, no profiler. Every block records the same `simpleFoam`
SHA-256 `7846a1250d3b95a80507f907f5a1ed9d2281a75b1bfd18d47af24b5105d2609f`.
Effective-input hash files match across blocks for each respective arm. Each
block used four recorded nodes with 128 ranks per node; the physical node sets
differ across blocks. The recorded rank affinity file has eight distinct CPU
masks in each block; this does not by itself establish equivalent performance.

## Read-only validation of all nine arm runs

Every arm has exactly 150 `Time =` markers ending at 150, exactly one solver
`Average wall-clock time per time step` record, normal `End` and finalization,
a freshly generated 150-row `coefficient.dat` spanning steps 1–150, and an
arm-specific summary. Times below are the solver log's average wall-clock
seconds per step; these are diagnostic repeats, not replacements for the
previously submitted Basic result.

| Block / PBS | Order | A plain | B uniform | C weighted |
| --- | --- | ---: | ---: | ---: |
| 1 / `25909583` | A–B–C | 2.929377395731545 | 3.030054280449665 | 3.201184319610739 |
| 2 / `25909584` | B–C–A | 3.166639338872481 | 2.912308068275168 | 3.086674503355704 |
| 3 / `25909585` | C–A–B | 5.565018760093960 | 4.918194009510067 | 4.113459105483220 |

Cd(150) is reproducible across blocks by arm: A `0.28405059711700609`,
B `0.27400973170318571`, C `0.28855096338109487`. B is below the
approximately 0.28–0.29 reference band used for the 150-step case, so its
scientific acceptability needs a trajectory check; it is not a valid winner
merely because it timed well in block 2. The fastest arm changes A → B → C
across blocks. C versus A is +9.28%, −2.53%, −26.08% in solver time. The
third block is much slower overall. Its nodes span multiple cabinet prefixes,
but no causal explanation has yet been established.

Saved Cd checkpoints at steps 40/80/120/150 are identical across blocks for
each respective arm. B's low final Cd is therefore a reproducible
partition-dependent trajectory, not a one-off output-file mix-up. At step
150, block-3 `ClockTime/ExecutionTime` is A `1072/480.81` s, B
`773/450.18` s, C `960/604.18` s; the gap is much larger than in blocks
1–2. These are diagnostics, not replacements for the official average-per-step
metric. They support investigating stalls and node environment before more
repeats, without establishing a cause.

Decomposition logs from block 1 report total processor faces of A 2,927,022;
B 2,958,587; C 3,033,594 and worst processor-to-processor faces of A 22,214;
B 21,142; C 22,829. Those totals do not alone establish network traffic,
node-level communication, or solver-time causation.

## Evidence paths

For each block `n` and PBS ID below, the root is:

`/home/users/industry/ai-hpc/apacsc20/scratch/openfoam-v2512/cases/scotch-abc-full-b<n>-v1-<id>/`

Use `(n,id)=(1,25909583),(2,25909584),(3,25909585)`. Root evidence includes
`evidence/exit-status.txt`, `run-order.txt`, `provenance.txt`, `nodes.txt`,
`rank-affinity.csv`, and `simpleFoam.sha256`. Each `A_plain`, `B_uniform`,
`C_weighted` subdirectory contains `evidence/logs/50_simpleFoam.log`,
`evidence/coefficient.dat`, `avg-step.txt`, `cd150.txt`,
`effective-inputs.sha256`, and `logs/10_decomposePar.log`. PBS outputs are
`/home/project/59000020/openfoam-isc26/control-repo/experiments/aspire2a-scotch-abc/outputs/scotch_abc_block<n>_v1.o` and `.e`.

## Commands and authorization boundary

The user authorized direct read-only access in this turn. Local metadata-only
checks verified the dedicated password file's owner, type, mode, and nonzero
size, the alias's expected `apacsc20@aspire2antu.nscc.sg` mapping, and a
pre-existing host-key entry. Only local `sshpass -f` consumed the password;
no password contents were inspected. The approved PTY-capable direct SSH form
from `workflow/00-General-SSH-Rules.md` was used, with one prompt, strict
host-key checking, no control socket and no automatic login retry. Remote
read-only commands were:

```sh
qstat -x -f 25909585.pbs101 | grep -E 'Job Id:|job_state =|queue =|Exit_status =|resources_used.walltime =|comment =|stime =|mtime =|obittime ='
bash -s  # read-only: ls/cat/tail/awk/stat for block-3 retained evidence and PBS stdout/stderr
bash -s  # read-only: cat/awk/sha256sum of saved node, affinity, binary and input-hash evidence across blocks 1–3
bash -s  # read-only: grep/tail of saved decomposePar logs for block 1
bash -s  # read-only: awk of saved Cd and ExecutionTime/ClockTime checkpoints across blocks 1–3
```

The two previous blocks' PBS `F`/exit-0 records and their six arm summaries
were inspected on 2026-10-22. The repository has pre-existing unrelated
modified and untracked files; they were preserved. This status note and the
storyline/agent guidance updates are local only and uncommitted.

## Next action, not execution authority

First audit full Cd/residual trajectories, timing progression, rank/node
placement, and partition metrics using existing evidence (zero SU). Treat the
large timing variance and B correctness issue as unresolved. If a new
matched A/C test or Basic PGO/binding experiment is later justified, prepare
a distinct plan/script and obtain the required diff review and explicit
approval before any submission. The scheduler polling limit, transfer forms,
and unrelated personal-account adapter fields remain `TBD` in the cluster
adapter; no new adapter field was inferred here.
