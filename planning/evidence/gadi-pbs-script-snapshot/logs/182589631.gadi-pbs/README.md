# 182589631.gadi-pbs — ICX core/default BA screen

Raw local logs: complete and SHA-256 verified. [sources.tsv](sources.tsv)
records every original remote path and local file digest; [SHA256SUMS](SHA256SUMS)
covers the 465 original files plus separately captured qstat-xf.txt.

Script implementation commit: 2b71932034f54ad9c6007aecb81c37f49a7200f2.
Submission record: cd670f754297692c98ba97dabc058a3876b50365.
PBS SHA256: fa7a5218b1e691e058274a3b5309da5252caecde5d9684ce825d3ba28b707871.
Helper SHA256: e678b840d7be8a43df7a884f259f5a542106b145378b36458373c6a8dc218022.

Remote evidence: /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010-of2512/binding-pair-1n-v1/ba/182589631.gadi-pbs/evidence/

PBS stdout: /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010/submit-logs/run_binding_pair_1n_v1_ba.pbs.out

Key originals: [core solver](core/simpleFoam.log), [default solver](default/simpleFoam.log),
[core Cd](core/coefficient.dat), [default Cd](default/coefficient.dat),
[pair summary](pair-summary.json), [run log](run.log), [PBS status](qstat-xf.txt).

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
