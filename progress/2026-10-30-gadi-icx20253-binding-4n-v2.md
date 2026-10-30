# ICX four-node binding pair v2 — JOBFS and status repair

User authorized correction and one retry after job182590339 failed at25GiB/node.
Diff shown locally before remote use;no additional optimization or repeat.
Full diff: [proposed-scripts.patch](proposed-scripts.patch).

Changes:100GB totalJOBFS ->400GB total (100GiB/node);all other requests unchanged:
4normalsrSPR8470Q nodes/416CPUs,760GB,1hour;832SU maximum,approximately450–500SU
expected for two complete arms. Original completed default arm fit25GiB but the
second independent runtime exceeded26.53GiB on the lead node. Rough two-arm budget
is<50GiB/node using the observed first-arm scale;100GiB/node leaves substantial
margin,not a measured future peak. Before each arm,the script records local
job JOBFS usage on allfour nodes and requires50GiB quota headroom;after each arm
records usage again. The guard uses the requested per-node quota,not disk df.
PBS_NCI_JOBFS must report400gb. Both cases/runtimes remain independent;no files
deleted,no scientific/source/compiler/MPI/collective changes,no reuse of old run.

Explicit TERM143/INT130/HUP129 handlers and completion flags prevent unfinished
work from reporting exit0. HardSIGKILL cannot run shell traps:still require
PBSExit0,all arm/pair PASS and output checks before accepting any future result.
New v2 stdout,job root,node-local root and uniquePASS;v1 unchanged.

Local tests executed actual shell trap blocks for success/earlyexit/error and
three signals;tested node-headroom accept/reject with mockdu;bash-n and embedded
Python parse;hash checks;exact equality of scientific/launcher and paired-parser
blocks withv1.416rankaffinity helper and runtime-stage helpers unchanged.

Primary NCI reference checked2026-10-30:
https://opus.nci.org.au/spaces/Help/pages/90308823/Queue%2BLimits
normalsr400GB/jobfs/node maximum,2SU/resource-hour;CPU/memory charge formula.
The100GiB/node request is within this limit and leavesCPU/memory charge832SU/h.
Remote quota read:6.99KSU available,0reserved;scratch628.18GiB/1TiB,
170.43K/202Kinodes. Expected additional retainedstage/evidence<=20GiB/<5000inodes;
originalfixedmeshreferenced withSHAchecks,not permanently recopied;old evidence retained.

No monitor recreation. No automatic retry after this one. Beforeqsub verify
GitHub/Gadi synchronization,remoteHEAD,scriptSHA,bash-n,clean tracked state and
absent independentstdout. Unknownqsub result must not be repeated.

## SHA256

- `run_binding_arm_4n_v2.sh`: `cbac993b3cf07e2a51f05c9a9177917289a6cf9227e487c7e3bd6fbe73bd17d5`
- `run_binding_pair_4n_v2.pbs`: `7d731f0d916654bd0287c0dc2ed9159b16b437d4006c5b62ceab5a4ee5098347`

Local preparation/validation complete;not yet submitted.

## Submitted once — 182637290.gadi-pbs

2026-10-30 Singapore session:after user's explicit repair/retry approval,local
validation,GitHub/Gadi synchronization,remoteff-only/cleantrackedstate,hash and
bash-n checks,uniquev2stdoutabsence,submitted exactlyonce:
`qsub experiments/gadi-icx20253-binding-numa/run_binding_pair_4n_v2.pbs`
Returned182637290.gadi-pbs. Scriptcommitcb0574194273355bbac72df25f79f39cc6cd00fa.
PBS SHA7d731f0d916654bd0287c0dc2ed9159b16b437d4006c5b62ceab5a4ee5098347;
armSHAcbac993b3cf07e2a51f05c9a9177917289a6cf9227e487c7e3bd6fbe73bd17d5.
4normalsrSPR nodes/416ranks,760GBmemory,400GBtotalJOBFS (100GB/node),1hour832SU
ceiling. ICX2025.3.2/OpenMPI5.0.10/Scotch/OpenFOAMv2512,fixed65M scientificinputs;
default then core,150steps each,noCPU/PMPIprofiling. ModuleUCX1.18.1/UCC1.4.4
stilldoesnotproveactualloadedsolvercommunicationlibraries/collectiveselection.

Stdout:/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010/submit-logs/run_binding_pair_4n_v2.pbs.out
Pairroot:/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010-of2512/binding-pair-4n-v2/182637290.gadi-pbs/
Evidence:pairroot/evidence,default/evidence,core/evidence.

Monitoring remainsOFF peruserrequest. Do notresubmit thisID orautomaticallyretry.
Nextuser-requestedcheck:readPBS/stdout/per-nodeJOBFSreceipts;oncompletionrequire
Exit0,uniqueV2arm/pairPASS,150steps/End,Cdtrajectory,identicalpartition/inputhash,
4hosts104ranks,affinityandpairsummary;archiveoriginals/SHA/actualSU. PBSrecord
remainsauthoritativeforSIGKILL/anyuntrappablesignals. No resultyet atsubmission.

InitialPBScheck:Q;select=4:ncpus104:mpiprocs104:mem204010946560:jobfs107374182400;totalJOBFS429496729600bytes,PBS_NCI_JOBFS=400gb. Correct100GiB/nodeallocationconfirmed.
