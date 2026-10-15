# Gadi Open MPI 5.0.10 GCC 16 build failure and repaired retry — 2026-10-16 SGT

## Failure preserved

PBS `181344373.gadi-pbs` completed `F`, `Exit_status=2`, walltime 00:10:45,
11.47 SU. GCC/G++ 16.2.0 and UCX/UCC modules were loaded; the source and
GCC archive checksums passed. The first material compiler error was
`mca_part_persist_start: inlining failed in call to always_inline: --param
max-inline-insns-single limit reached` in
`ompi/mca/part/persist/part_persist.h`. The original output is retained at
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/build_ompi5010.pbs.out`; the job evidence is under
`.../evidence/181344373.gadi-pbs/build_ompi5010.log`. No Open MPI archive
was produced by this failed job.

## Evidence-backed fix

Open MPI's own [issue 13847](https://github.com/open-mpi/ompi/issues/13847)
records the same failure for v5.0.10 with GCC 16. Its
[upstream commit aa024ac](https://github.com/open-mpi/ompi/commit/aa024ac73d624611cfe3af6f541b5d28dedf07bb)
changes the one declaration from `__opal_attribute_always_inline__ static inline int`
to `static inline int`. The v2 build script applies exactly that one-line
change to the checksum-verified Open MPI source after unpacking in the new
job's `$PBS_JOBFS`, and fails closed if the expected original text is absent.
The original release archive and prior job evidence remain untouched. The
local source tarball was inspected to confirm the exact declaration.

The reviewed retry files are `builds/build-scripts/gadi-gcc162-ompi5010/
build_ompi5010_v2.sh` and `build_ompi5010_v2.pbs`. Both passed `bash -n`.
The PBS stdout has a distinct `build_ompi5010_v2.pbs.out` path; new evidence
and runtime archive paths include the new PBS job ID. This repair is limited
to MPI; the OpenFOAM scientific inputs are unchanged.

## Retry submission and next check

Commit `71dd3c4e2b3c6e1928e1c4930a8232be59a78564` was pushed to GitHub
and Gadi. The Gadi control checkout was fast-forwarded to that commit. Both
remote scripts passed `bash -n`, and their SHA-256 matched the local files:
`9ab00c071ae13f8201c9b03256c587f51a273ab1b40673b1bedb7b5c7b49db21`
for the shell script and
`8ac16999b46a31c89b22034e48f38774d7a04661077ef878e67862a9bfa3682b`
for PBS. Pre-existing untracked remote experiment files were preserved.

The exact submission was:

```sh
ssh -o BatchMode=yes gadi-comp 'test ! -e /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/build_ompi5010_v2.pbs.out && cd /scratch/pm78/kj7183/openfoam_cpu/control-repo && /opt/pbs/default/bin/qsub builds/build-scripts/gadi-gcc162-ompi5010/build_ompi5010_v2.pbs'
```

`qsub` returned `181344546.gadi-pbs` once. Its first `qstat -f` showed `Q`,
32 CPUs and a 2-hour limit. `nci_account -P pm78` showed 49.90 SU used, 0
reserved and 5.95 KSU available; scratch inode usage was 195.28K/202K.
Check terminal PBS status and SU, MPI components, two-rank smoke, archive
SHA-256, and a separate fresh-job relocation test.
