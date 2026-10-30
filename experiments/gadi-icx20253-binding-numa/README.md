# ICX 2025 binding and NUMA first batch

User approved P0 + AB + BA, total requested ceiling 312 SU, on 2026-10-30 after reviewing full script diffs. Each job may be submitted once; failure stops subsequent submissions. No four-node solve or extra retry is included.

## Configuration

ICX 2025.3.2; private Open MPI 5.0.10 with GCC 16.2 runtime; OpenFOAM v2512 from build 181392981; ucx/1.18.1 and ucc/1.4.4 modules; UCX PML, no injected UCX preload or collective override. Actual runtime selection is recorded by the preflight, and is not inferred from module names.

Single normalsr SPR node, 104 ranks. P0: 104 CPU/16 GB/20 GB JOBFS/10 minutes. AB and BA: each 104 CPU/190 GB/100 GB JOBFS/40 minutes; two fresh 40-step Scotch cases. Fixed science copied only into private JOBFS from the existing source master. Binary and archive SHA gates are in the PBS files.

## Execution gates

See ../../planning/gadi-icx20253-binding-numa-plan.md and the review package. P0 must pass PBS, runtime and map checks. Identical binding masks skip solves. A per-rank core outside its default allowed mask stops progression. AB must validate before BA submission. Explicit distinct stdout overrides are mandatory for AB/BA. Keep original evidence and independent output names; no unknown-qsub resubmission.

## Evidence and outputs

Remote evidence roots: ICX OF root/binding-numa-preflight-v1/<job>/evidence and ICX OF root/binding-pair-1n-v1/<ab|ba>/<job>/evidence. Remote stdout is the established ICX submit-logs directory. Local raw PBS receipts belong in outputs/<job>/; all original evidence is also archived under planning/evidence/gadi-pbs-script-snapshot/logs/<job>/. Each solver arm has its own default/ or core/ directory. Require Exit 0, PASS, full preparation End, exactly 40 Time entries, End, Cd comparison, identical partition and input, actual placement, and actual SU. Diagnostic screen is not a 150-step score.

## Attempts and error handling

No PBS submission yet. Any error retains first failure, job ID and receipts; no retry authorized. Local syntactic/parser checks passed before deployment, including archived real GCC default/core evidence and negative placement cases.

## P0 submitted — 182588070.gadi-pbs

Approved script commit 2b71932034f54ad9c6007aecb81c37f49a7200f2. The user approved all three gated jobs, maximum 312 SU, after full diff review. Submitted only P0 once using `/opt/pbs/default/bin/qsub experiments/gadi-icx20253-binding-numa/preflight_binding_numa_1n_v1.pbs` from `/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20262-ompi5010/control-repo`.

The initial generic `git pull --ff-only` attempted the checkout's GitHub origin and failed authentication before qsub; no job was submitted in that command. No credentials/configuration were changed. The verified local Gadi transport was used explicitly: `git pull --ff-only /scratch/pm78/kj7183/openfoam_cpu/control-repo codex/gadi-gcc162-build`. HEAD and all three file hashes matched; remote bash -n passed; independent stdout was absent. The single qsub returned 182588070.gadi-pbs.

stdout: `/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010/submit-logs/preflight_binding_numa_1n_v1.pbs.out`.
Evidence: `/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010-of2512/binding-numa-preflight-v1/182588070.gadi-pbs/evidence/`.

P0 requests 104 cores/16 GB/20 GB JOBFS/10 minutes (34.67 SU max). AB and BA remain unsubmitted and must pass the documented gates. Pre-submission pm78 had 8.76 KSU available, scratch 527.80 GiB and 161.33K inodes. No historical evidence or unrelated files altered.

## P0 validated — 182588070.gadi-pbs

PBS F / Exit0; script_exit_rc0 and unique PASS. SPR host0381,104CPU,23seconds walltime,actual1.33SU. Default104 ranks each allowed13 physicalcores in one NUMA domain; core104 distinct physicalcores, each within the same rank's default CPU mask. Independent local helper validation passes; can_run_binding=true. Optional fill/span104-rank placement launches pass too.

Both MPI runtime ranks report UCP /usr/lib64/libucp.so.0 version1.21.0 with Allreduce sum1. HCOLL selected in dual-rank collective receipt; UCC unavailable/disqualified. These observations do not establish actual104-rank solver collective selection or memory-page placement. Modules remain ucx1.18.1/ucc1.4.4; module names alone do not identify the loaded library.

Archived444 original files with remote/local SHA agreement plus captured qstat-xf.txt in planning/evidence/gadi-pbs-script-snapshot/logs/182588070.gadi-pbs/. First short SCP pull hit a90second local transfer timeout while making progress; existing partial files were preserved and checked. Independent folder pulls into fresh staging directories with bounded420second transfer deadlines completed; this was not an authentication or PBS failure, and no job was retried. No raw file overwritten. No OpenFOAM solve, Cd or seconds/step in this preflight.

Next authorized action: once archive/result commit is synchronized and remote script hashes and absent unique AB stdout checked, submit AB once with BIND_ORDER=ab,BIND_PREFLIGHT_JOB=182588070.gadi-pbs and explicit _ab stdout. BA remains gated on AB results. Script unchanged from reviewed commit2b71932.

## AB submitted — 182588604.gadi-pbs

P0 fully validated and raw archive committed as46b9f53626d0e0e590e91877f5c7566a3b8767a8, synchronized GitHub/Gadi. Remote ff-only, HEAD, pair/helper SHA and bash -n passed; independent AB stdout absent. Submitted once:
`qsub -v BIND_ORDER=ab,BIND_PREFLIGHT_JOB=182588070.gadi-pbs -o /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010/submit-logs/run_binding_pair_1n_v1_ab.pbs.out experiments/gadi-icx20253-binding-numa/run_binding_pair_1n_v1.pbs`.

Returned182588604.gadi-pbs. OneSPR104CPU/190GB/100GBJOBFS/40minutes,138.67SU ceiling. ICX2025.3.2/OpenMPI5.0.10/Scotch,default then core,104ranks and40steps each. Job evidence:
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010-of2512/binding-pair-1n-v1/ab/182588604.gadi-pbs/evidence/`.
BA has NOT been submitted. Never resubmit AB; monitor this ID. Advance to one BA only after complete PBS/solver/Cd/geometry/placement validation and archival. User approval remains312SU maximum and no extra jobs or failure retry.

## AB validated — 182588604.gadi-pbs

PBS F / Exit0, script_exit_rc0 and pair/arm PASS markers. One normalsr Sapphire Rapids8470Q host gadi-cpu-spr-0201,104 allocated CPUs,190GB memory,100GBJOBFS,40minute request. ICX2025.3.2/private OpenMPI5.0.10/OpenFOAMv2512/Scotch; fixed65,334,765cell scientific input. Modules ucx1.18.1/ucc1.4.4 declared; no UCX preload or collective override. Actual solver UCP version/collective selection remains unmeasured; P0 two-rank results cannot establish it.

Default then core,104 ranks and40steps each. Default8.25222384897436s/step,core8.248214656871795s/step,core lower by0.0485832%. Both final Cd0.43806006706848277; entire retained Cd trajectories identical. Complete preparation/solver End,exactTime1..40,finite positive coded timing,matching input and partition vectors pass independent local checks. Placement and solver-wrapper receipts contain104 ranks on the same host;core104 unique physicalcores stay within corresponding default masks. Pre-exec masks do not prove memory-page placement or post-MPI-init affinity.

Walltime22:56,actual79.50SU for the whole pair (not per arm),posted PBS receipt. Peak memory receipt190GB,JOBFS38.94GB. All465 remote originals (464 evidence files plus stdout) SHA matched; captured qstat is separate. Source paths/fileSHA in job archive sources.tsv/SHA256SUMS,default/core subdirectories preserved. No source/input or run-script change; no retry. Tiny one-pair timing difference is not a demonstrated binding benefit;40steps is screening,not a150step score.

BA remains conditional and unsubmitted at this validation record. After synchronization,quota check,hash checks and absent BAstdout,submit the already approved BA once;record returned ID immediately. Total cost so far P0+AB=80.83SU.

## BA submitted once — 182589631.gadi-pbs

AB full evidence/result commit eaeb2d85e47cae2c8125b3bd99d755db7447baad pushed to existing GitHub/Gadi isolated branch; remote ff-only, script/helper and pair-result SHA verified. No script changes. Prior BA stdout absent; submitted exactly once with `qsub -v BIND_ORDER=ba,BIND_PREFLIGHT_JOB=182588070.gadi-pbs -o /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010/submit-logs/run_binding_pair_1n_v1_ba.pbs.out experiments/gadi-icx20253-binding-numa/run_binding_pair_1n_v1.pbs`. Returned182589631.gadi-pbs; initial Q.

Same approved single-SPR104CPU/190GB/100GBJOBFS/40minute request,138.67SU maximum; core then default,104ranks/40steps each,ICX2025.3.2/OpenMPI5.0.10/OpenFOAMv2512/Scotch. Remote evidence root: /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010-of2512/binding-pair-1n-v1/ba/182589631.gadi-pbs/evidence/. Do not resubmit P0,AB or BA.

Pre-submit account check:8.06KSU available,624SU reserved; scratch558.49GiB/1TiB,164.40K/202Kinodes. Other approved work uses the shared allocation. Control connection restored; prior missing socket did not imply any PBS failure. Original raw whitespace preserved despite git diff whitespace warnings.

Next: monitor this BA ID,verify both arms and archive with per-file SHA; compare AB/BA paired ratios and order effects. No extra retry,four-node or NUMA solve authorized. Stop/delete binding automation after final records,or upon failure.

## BA validated and first batch complete — 182589631.gadi-pbs

PBS F / Exit0, script_exit_rc0 and both arm PASS plus pair_ba_PASS. One Gadi
normalsr Sapphire Rapids 8470Q host gadi-cpu-spr-0388, 104 allocated CPUs,
190 GB memory, 100 GB JOBFS, 40-minute request. ICX 2025.3.2 + private Open MPI
5.0.10 (GCC16.2 runtime), OpenFOAM v2512, Scotch, fixed 65,334,765-cell input.
UCX1.18.1/UCC1.4.4 are declared modules; solver runtime UCP and collective
selection remain unmeasured. The P0 UCP1.21.0/HCOLL evidence is probe-only.

Core then default, each 104 ranks and 40 SIMPLE steps. Core 8.260328297461541
s/step; default 8.274169132589744 s/step; core lower by 0.1672776433%.
Both final Cd = 0.43806006706848277, full Cd trajectories identical.
Independent local checks passed: all preparation End markers, exact Time1..40
and solver End/finalization, finite positive timing, identical input manifests
and 104-partition geometry, same host, 104 unique core assignments within each
rank's default mask, 104 solver-wrapper receipts per arm, recomputed pair-summary.
The coded average covers 39 measured steps after the first step, consistently
in all four arms; each solver still completed 40 steps.

Walltime 22:42 (1362 s), actual whole-pair 78.69 SU. All 465 original remote
files (464 evidence plus PBS stdout) matched remote SHA-256; qstat-xf.txt is
separately captured scheduler output. Original bytes and core/default directories
are preserved with sources.tsv, SHA256SUMS and README. Missing retained files:
none against completed remote inventory. No run scripts changed or jobs retried.

AB (host0201, default then core) showed 0.0485832% lower core time; BA (host0388,
core then default) showed 0.1672776%. Both signs agree despite reverse order,
but two small effects do not establish a reproducible or practically material
speedup, nor isolate every order/host effect. Geometric mean of the two paired
core/default ratios gives a descriptive 0.1079480% reduction, not a confidence
interval. These are 40-step single-node screening runs, not 150-step scores.
Pre-exec allowed CPU masks do not prove post-MPI_Init affinity or memory-page
residency. A single-node near-null result cannot rule out a four-node benefit.
A separate subsequent user instruction explicitly approved preparing and submitting
one four-node default/core binding pair; it is outside this completed first batch.

All three approved jobs are complete: P0 1.33 + AB 79.50 + BA 78.69 = 159.52 SU,
within the 312 SU request ceiling. No further job may be submitted under this
batch. Monitoring will be updated for the separately approved four-node pair.

Retrieval note: the first completed-job SHA inventory command exceeded a
40-second local timeout; the control connection remained healthy. A bounded
180-second read completed before transfer. This was not PBS failure or an
authentication retry; no remote evidence was changed.

## Separately approved four-node follow-up

One default/core416-rank150-step pair prepared;see planning/reviews/gadi-icx20253-binding-4n/README.md and progress/2026-10-30-gadi-icx20253-binding-4n.md.832SU ceiling,no retry.

## Result inspected — 182590339.gadi-pbs: incomplete pair, JOBFS limit

PBS F / Exit_status271,SIGTERM,walltime00:17:27 (1047s),posted actual241.97SU
for the entire job. One normalsr allocation,4 Sapphire Rapids8470Q hosts
0514,0515,0516,0526;each104 CPUs/ranks,total416. ICX2025.3.2/private
OpenMPI5.0.10/OpenFOAMv2512/Scotch,unchanged65,334,765-cell occDrivAerStaticMesh.
UCX1.18.1/UCC1.4.4 are declared modules only;actual solver UCP version,
UCC/HCOLL selection remain unmeasured. No UCX preload or collective override.

Default arm completed all four preparation stages and Time1..150/End/finalization.
Coded149-step mean1.985561463114094s/step (first step excluded),Cd at150
0.29187617440389690,ExecutionTime302.06s/ClockTime308s.416rank mapping,
source/actualmesh checks,archive/binary checks and default PASS present.
Pre-exec solver masks allow13physicalcores perrank;not post-MPI affinity or
memory residency. The separate416rank core probe had unique cores within
corresponding default masks. Core arm stopped during runtime staging after
its node0 receipt;no decomposition or solver log,Cd,step-time,corePASS or
pairPASS/summary. Therefore this is not a valid completed binding comparison.
Default completed-arm data are retained as partial-job evidence,not a successful
paired result or a core-binding benefit.

Authoritative PBS stdout: `Job 182590339.gadi-pbs killed due to exceeding jobfs quota. Quota: 25.0GB, Used: 26.53GB, Host: gadi-cpu-spr-0514`.
PBS select gives4nodes eachjobfs26843545600bytes:100GB total is25GB/node.
The first arm's JOBFS files remained while the second unpacked a separate runtime.
The pre-submit capacity estimate failed to budget simultaneous per-node peak;
this is a workflow resource-planning error,not a demonstrated MPI/solver defect.
Retained pair_exit_rc=0 and core script_exit_rc=0 contradict PBS termination and
must never override it. Signal-aware failure reporting needs review separately.

1256 original evidence/stdout files retrieved with remote/local SHA agreement;
44 remaining rank receipts are listed in missing-files.tsv. qstat -xf was
read remotely and showed F/271,but its full raw stdout was not captured locally
before SSH expired;the archived PBS stdout independently records Exit271 andSU.
Original names/bytes and evidence/default/core paths
preserved;README,SHA256SUMS,sources.tsv and remote inventory retained. Missing
expected outputs were never produced:core solve/preparation,core coefficients,
pair-summary and pairPASS. The first bulk SCP pull reached its600-second local transfer bound;1091 verified originals were recovered from preserved staging and a remaining-only pull recovered165 more files before the master connection broke.
Stopped remote operations at SSH failure,no automatic authentication retry.
Full independent affinity validation is deferred until the44 missing receipts arrive.
No archived originals overwritten;no remote file
modified,no repair/retry/newPBS submission ormonitor restart.

Next proposed remedy requires a new reviewed diff and approval:calculate per-node
peak from both arms,then choose adequate per-node JOBFS or reuse the immutable
runtime across arms while preserving independent cases and all evidence;correct
signal status capture. Do not delete existing evidence or reuse this job ID.

## v2 repair authorized

Seeplanning/reviews/gadi-icx20253-binding-4n-v2/README.md. One retry,400GBtotalJOBFS,signalguards;unchangedICX/OpenMPI/Scotch/default-core150steps;832SUceiling. Notyet submitted.
