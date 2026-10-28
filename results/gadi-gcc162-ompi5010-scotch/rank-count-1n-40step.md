# Same-node 104 versus 96 rank Scotch comparison

## Configuration and provenance

- PBS job: `182509859.gadi-pbs`; `pm78/normalsr`; one Sapphire Rapids node
  `gadi-cpu-spr-0002.gadi.nci.org.au`; 104 allocated CPUs, 190 GB memory,
  100 GB JOBFS, 40-minute request.
- GCC 16.2.0, private Open MPI 5.0.10, OpenFOAM.com v2512, real Scotch
  6.1.0. UCX 1.18.1/UCC 1.4.4 modules were loaded; their effective runtime
  versions and UCC collective selection were not established by this job.
- Fixed approximately 65-million-cell `occDrivAerStaticMesh` case,
  unchanged solver/source and scientific dictionaries. Each arm used default
  Open MPI binding and a matching Scotch `nCores`/rank count; the only
  intentional difference was 104 versus 96 ranks. Both ran 40 steps with
  `decomposePar`, `renumberMesh`, `potentialFoam`, `applyBoundaryLayer`,
  then `simpleFoam`.
- Both `case-inputs.sha256` manifests matched byte for byte; in particular
  `fvSchemes` SHA-256 was
  `064bb50455d37a7edd2c0fb24bbe30baaf851623f0250d550450c10e407889b3`,
  `fvSolution` was
  `5e1db8548ee82c44f8fa3377a80971af2b5aabb95b3ee7efcd8b723c5dcab1ba`,
  and `controlDict.noWrite` was
  `ce4ec0f52bcc88eea8402b454940dc5aad1f31dea6441e7d98413b651427ef06`.

## Outcome

PBS finished with `job_state=F`, `Exit_status=0`. Both arm-level PASS
markers and the aggregate `GCC162_OMPI5010_SCOTCH_1N_40STEP_104_96_AB_PASS`
were recorded. Both complete chains reached solver `Time = 40`, `End`,
and `Finalising parallel run`; rank affinity captured 104/96 ranks on the
same host.

| Arm | Mean wall-clock s/step | Final Cd | Processor faces |
| --- | ---: | ---: | ---: |
| 104 ranks | 8.296121226410254 | 0.43806006706848422 | 1,420,042 |
| 96 ranks | 8.978244996461541 | 0.44034575240845725 | 1,358,817 |

The 96-rank arm was 8.22% slower (+0.6821237700512874 s/step), while
its processor-face total was 4.31% lower. Cd differed by 0.002286 and
both values remained in the preset 0.42–0.45 sanity band. A possible
explanation is that less rank-level parallelism outweighed fewer interface
faces; this one run does not establish that mechanism or a four-node result.
The separate 104-rank reference (`182017873.gadi-pbs`) measured
8.373520290307694 s/step and Cd 0.43806006706848422. The current
104-rank arm was about 0.92% faster.

The NCI receipt reported 00:22:48 walltime and **79.04 SPR SU**. The
request ceiling was approximately 138.67 SU; reported JOBFS use was
39.8 GB. The result does not justify a 384-rank four-node submission
without a separate review and authorization.

## Retained remote evidence

- PBS stdout: `/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/run_rankcount_1n_40step_ab_v1.pbs.out`
- Job-keyed evidence: `/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010-of2512/rank-count-1n-40step/182509859.gadi-pbs/evidence/`
- Within each `104/` and `96/` arm: `case-inputs.sha256`,
  `rank-affinity.txt`, `mpi-bindings.txt`, numbered preparation logs,
  `simpleFoam.log`, `avg-step-time.txt`, and `coefficient.dat`.
