# 182588604.gadi-pbs — ICX default/core AB screen

Original remote files fetched read-only using verified BatchMode SCP. Original filenames/subdirectories and bytes retained. All465 remote files matched the completed-job SHA inventory; qstat-xf.txt is captured scheduler output. [sources.tsv](sources.tsv) gives every original path and hash; [SHA256SUMS](SHA256SUMS) covers each raw local file including qstat.

Script implementation commit2b71932034f54ad9c6007aecb81c37f49a7200f2; submission record4551903. Pair PBS SHA256 fa7a5218b1e691e058274a3b5309da5252caecde5d9684ce825d3ba28b707871;helper SHA256 e678b840d7be8a43df7a884f259f5a542106b145378b36458373c6a8dc218022.

Remote root: /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010-of2512/binding-pair-1n-v1/ab/182588604.gadi-pbs/evidence/
PBS stdout: /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010/submit-logs/run_binding_pair_1n_v1_ab.pbs.out

Missing retained raw files: none versus completed remote inventory. Actual solver UCP version/collective selection,post-MPI-init affinity and memory-page residency were not measured.

## AB validated — 182588604.gadi-pbs

PBS F / Exit0, script_exit_rc0 and pair/arm PASS markers. One normalsr Sapphire Rapids8470Q host gadi-cpu-spr-0201,104 allocated CPUs,190GB memory,100GBJOBFS,40minute request. ICX2025.3.2/private OpenMPI5.0.10/OpenFOAMv2512/Scotch; fixed65,334,765cell scientific input. Modules ucx1.18.1/ucc1.4.4 declared; no UCX preload or collective override. Actual solver UCP version/collective selection remains unmeasured; P0 two-rank results cannot establish it.

Default then core,104 ranks and40steps each. Default8.25222384897436s/step,core8.248214656871795s/step,core lower by0.0485832%. Both final Cd0.43806006706848277; entire retained Cd trajectories identical. Complete preparation/solver End,exactTime1..40,finite positive coded timing,matching input and partition vectors pass independent local checks. Placement and solver-wrapper receipts contain104 ranks on the same host;core104 unique physicalcores stay within corresponding default masks. Pre-exec masks do not prove memory-page placement or post-MPI-init affinity.

Walltime22:56,actual79.50SU for the whole pair (not per arm),posted PBS receipt. Peak memory receipt190GB,JOBFS38.94GB. All465 remote originals (464 evidence files plus stdout) SHA matched; captured qstat is separate. Source paths/fileSHA in job archive sources.tsv/SHA256SUMS,default/core subdirectories preserved. No source/input or run-script change; no retry. Tiny one-pair timing difference is not a demonstrated binding benefit;40steps is screening,not a150step score.

BA remains conditional and unsubmitted at this validation record. After synchronization,quota check,hash checks and absent BAstdout,submit the already approved BA once;record returned ID immediately. Total cost so far P0+AB=80.83SU.
