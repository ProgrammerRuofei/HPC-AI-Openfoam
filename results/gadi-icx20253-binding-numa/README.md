# ICX binding/NUMA results


## P0 validated — 182588070.gadi-pbs

PBS F / Exit0; script_exit_rc0 and unique PASS. SPR host0381,104CPU,23seconds walltime,actual1.33SU. Default104 ranks each allowed13 physicalcores in one NUMA domain; core104 distinct physicalcores, each within the same rank's default CPU mask. Independent local helper validation passes; can_run_binding=true. Optional fill/span104-rank placement launches pass too.

Both MPI runtime ranks report UCP /usr/lib64/libucp.so.0 version1.21.0 with Allreduce sum1. HCOLL selected in dual-rank collective receipt; UCC unavailable/disqualified. These observations do not establish actual104-rank solver collective selection or memory-page placement. Modules remain ucx1.18.1/ucc1.4.4; module names alone do not identify the loaded library.

Archived444 original files with remote/local SHA agreement plus captured qstat-xf.txt in planning/evidence/gadi-pbs-script-snapshot/logs/182588070.gadi-pbs/. First short SCP pull hit a90second local transfer timeout while making progress; existing partial files were preserved and checked. Independent folder pulls into fresh staging directories with bounded420second transfer deadlines completed; this was not an authentication or PBS failure, and no job was retried. No raw file overwritten. No OpenFOAM solve, Cd or seconds/step in this preflight.

Next authorized action: once archive/result commit is synchronized and remote script hashes and absent unique AB stdout checked, submit AB once with BIND_ORDER=ab,BIND_PREFLIGHT_JOB=182588070.gadi-pbs and explicit _ab stdout. BA remains gated on AB results. Script unchanged from reviewed commit2b71932.

Numerical probe outcome is recorded in metrics.csv. Timing and Cd fields remain empty because no solver ran.

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
