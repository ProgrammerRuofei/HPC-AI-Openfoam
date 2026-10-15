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

## Next check

After syncing the reviewed commit to Gadi, submit the v2 PBS script once.
Record the returned job ID, terminal PBS status and SU, MPI components,
two-rank smoke, archive SHA-256, and a separate fresh-job relocation test.
