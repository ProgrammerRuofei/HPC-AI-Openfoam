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

## Second failure and targeted v3 repair

The first patched retry, `181344546.gadi-pbs`, completed `F`,
`Exit_status=2`, walltime 00:10:39, and 11.36 SU. It passed the prior
`part/persist` failure and reached OpenSHMEM, where GCC 16 rejected
`mca_memheap_base_map = {{{{0}}}}` in
`oshmem/mca/memheap/base/memheap_base_frame.c:38` with
`braces around scalar initializer`. Original logs remain at
`submit-logs/build_ompi5010_v2.pbs.out` and
`evidence/181344546.gadi-pbs/build_ompi5010.log`; no archive was produced.

OpenSHMEM is not required by this OpenFOAM MPI workload. The v3 retry adds
only Open MPI's documented `--disable-oshmem` configure option, retaining
the upstream `part/persist` fix, UCX, UCC, PBS TM, GCC 16.2, and all
checksum gates. [Open MPI's configure documentation](https://docs.open-mpi.org/en/v5.0.5/installing-open-mpi/configure-cli-options/oshmem.html)
describes this option. The v3 PBS stdout path is unique, and eventual evidence
and archive names include the new job ID. The v2 files and logs remain intact.

## v3 submission

Commit `67bc71e903bd8db7d3cb9de8441f15ba21566a73` was pushed to GitHub
and Gadi. The Gadi control checkout fast-forwarded to it; both v3 scripts
passed remote `bash -n`, and the script SHA-256 matched local values
`b798890cacb36e9d3497f2d89b4dbf1a1c334a7a9ac560db63b03ea6d82c630e`
and `8ac7af7957d95f0d7c06cd86c7aff5ab4937f5e15b75663161383d88d833dfc7`.
Existing untracked remote experiment files were preserved. The exact command:

```sh
ssh -o BatchMode=yes gadi-comp 'test ! -e /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/build_ompi5010_v3.pbs.out && cd /scratch/pm78/kj7183/openfoam_cpu/control-repo && /opt/pbs/default/bin/qsub builds/build-scripts/gadi-gcc162-ompi5010/build_ompi5010_v3.pbs'
```

`qsub` returned `181345046.gadi-pbs` once; first status was `Q`, 32 CPUs,
2-hour walltime. `nci_account -P pm78` showed 61.26 SU used, 0 reserved,
5.94 KSU available, scratch inodes 195.30K/202K.
