# Gadi GCC 16.2 relocation passed; Open MPI 5.0.10 submitted — 2026-10-16 SGT

## Scope and state

This report records the completed GCC build and relocation gate and the single
approved Open MPI build submission. It does not claim Open MPI, OpenFOAM, or a
416-rank benchmark result. The original local `main` checkout and Gadi's
pre-existing untracked experiment files were preserved. The isolated branch
`codex/gadi-gcc162-build` contains the reviewed build scripts.

| Stage | PBS job | Evidence-backed result | SU |
| --- | --- | --- | ---: |
| GCC 16.2.0 build | `181342083.gadi-pbs` | `F`, `Exit_status=0`, GCC/G++ 16.2.0, `GCC162_BUILD_ARCHIVE_PASS`; archive SHA-256 verified | 38.42 |
| Relocation smoke v1 | `181344115.gadi-pbs` | `F`, `Exit_status=1` before extraction: truncated hard-coded SHA-256; original PBS output retained | 0.00 in PBS receipt |
| Relocation smoke v2 | `181344224.gadi-pbs` | `F`, `Exit_status=0`, `GCC162_RELOCATION_PASS`, 17 s; C and C++17 compile/run and relocated `libstdc++` linkage verified | 0.02 |
| Open MPI 5.0.10 build | `181344373.gadi-pbs` | Submitted once on `normalsr`, 32 CPUs, 128 GB, 30 GB jobfs, 2 h; `Q` at first check | TBD |

The validated GCC archive is
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/runtime-archive/gcc-16.2.0.181342083.gadi-pbs.tar.gz`.
Its SHA-256 is
`1149c0d97412ae3741cc18d60f233cdd3dd5e33bc92c55c59db2dd8cf535b714`.
The relocation evidence is under
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/evidence/181344224.gadi-pbs/`.

## Open MPI build inputs and controls

- Official `openmpi-5.0.10.tar.gz` source SHA-256:
  `5692cc80554a7117c99eaa725d35100edd8bbf73423a5e265ff867979192df7d`.
  The local source and downloaded Gadi source both matched this value.
- Gadi source path:
  `/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/source/openmpi-5.0.10.tar.gz`.
- Site module paths were read from `module show`: `ucx/1.18.1` at
  `/apps/ucx/1.18.1` and `ucc/1.4.4` at `/apps/ucc/1.4.4`. PBS TM header and
  library were observed under `/opt/pbs/default`.
- The PBS script and shell script are
  `builds/build-scripts/gadi-gcc162-ompi5010/build_ompi5010.pbs` and
  `builds/build-scripts/gadi-gcc162-ompi5010/build_ompi5010.sh`. Both passed
  local and remote `bash -n`. Commit `d7649c96b8df03ff23cd1dba78731ee949664238`
  was pushed to GitHub and Gadi; the Gadi control checkout fast-forwarded to
  that commit before submission.
- Expanded GCC, source, build tree and install tree remain in `$PBS_JOBFS`.
  Only the eventual Open MPI archive and evidence logs are written to scratch.
  The script checks UCX, UCC, PBS TM, a two-rank UCX MPI program, and the
  archive hash before printing `OMPI5010_BUILD_ARCHIVE_PASS`.

## Exact remote and scheduler commands for the Open MPI submission

All commands used the existing `gadi-comp` control connection and
`ssh -o BatchMode=yes`. Read-only inspection included `git status`,
`git rev-parse HEAD`, `module show`, `ls` for PBS TM files, `curl -sSIL`,
`sha256sum`, `bash -n`, `nci_account -P pm78`, and `qstat -f`.
The remote changes were:

```sh
git push gadi codex/gadi-gcc162-build
ssh -o BatchMode=yes gadi-comp 'git -C /scratch/pm78/kj7183/openfoam_cpu/control-repo pull --ff-only . codex/gadi-gcc162-build'
ssh -o BatchMode=yes gadi-comp 'curl -fL --retry 2 --max-time 900 -o /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/source/openmpi-5.0.10.tar.gz.part https://download.open-mpi.org/release/open-mpi/v5.0/openmpi-5.0.10.tar.gz'
ssh -o BatchMode=yes gadi-comp 'test ! -e /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/source/openmpi-5.0.10.tar.gz && mv /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/source/openmpi-5.0.10.tar.gz.part /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/source/openmpi-5.0.10.tar.gz'
ssh -o BatchMode=yes gadi-comp 'cd /scratch/pm78/kj7183/openfoam_cpu/control-repo && /opt/pbs/default/bin/qsub builds/build-scripts/gadi-gcc162-ompi5010/build_ompi5010.pbs'
```

The `.part` file was renamed only after its SHA-256 matched the official
release. `qsub` returned `181344373.gadi-pbs`; it was not repeated.
Before submission `nci_account -P pm78` showed 38.44 SU used, 0 reserved,
about 5.96 KSU available, and 195.25K of 202K scratch inodes used.

## Next gates

Monitor `181344373.gadi-pbs` to terminal state. Success requires PBS
`Exit_status=0`, `OMPI5010_BUILD_ARCHIVE_PASS`, expected GCC, UCX/UCC/TM
components, successful two-rank MPI smoke, an archive and matching `.sha256`,
and actual SU. Preserve the first failure and do not resubmit an uncertain
job. After success, test MPI relocation in a fresh PBS job before using the
archive for OpenFOAM v2512. The four-node benchmark requires a separate
script review against current build instructions and successful Gadi runs.
