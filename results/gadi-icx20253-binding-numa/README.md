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
