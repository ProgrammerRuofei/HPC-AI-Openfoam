# Gadi SPR GCC 16.2.0 build submitted — 2026-10-16 SGT

## Scope and current status

User approved the reviewed three-file GCC build diff, Git synchronization,
official source staging, remote directory creation, and one build submission.
The PBS job is `181342083.gadi-pbs`, `normalsr-exec`, 104 CPUs, six-hour
walltime. It started on `gadi-cpu-spr-0138` at Gadi-local 03:10:52 and was `R`
at the last bounded check. The build log was in `configure` feature checks;
no build result exists yet.
A thread heartbeat automation `gadi-gcc-16-2` monitors it every ten minutes and
must not resubmit, cancel, clean up, or advance to Open MPI automatically.

## Local files and Git

The original checkout had unrelated tracked and untracked changes. They were
preserved. An isolated managed worktree based on prior Gadi `main` commit
`0e17db7f831e1693a625f24980e3c242a16fbf27` received only:

- `builds/build-scripts/gadi-gcc162-ompi5010/README.md` — scope, inputs, quota
  policy, and subsequent gates;
- `builds/build-scripts/gadi-gcc162-ompi5010/build_gcc162.pbs` — one SPR-node
  scheduler request;
- `builds/build-scripts/gadi-gcc162-ompi5010/build_gcc162.sh` — verified-source,
  JOBFS-only C/C++ compiler build and archived output.

`bash -n` and `git diff --cached --check` passed. Commit
`45618f91b1e8596da6dca090140cb7efab16afcb` on
`codex/gadi-gcc162-build` contains only these three files and was pushed to
GitHub and to the Gadi repository. The Gadi control checkout fast-forwarded
from `0e17db7` to `45618f9`; its pre-existing untracked files under
`experiments/gadi-4n-decomp/` and `experiments/gadi-scaling-decomp/` remain.

## Evidence-backed facts

| Fact | Evidence | Status |
| --- | --- | --- |
| Gadi SSH control connection available | `ssh -O check gadi-comp` returned `Master running` | DISCOVERED AND VERIFIED |
| GCC source is the publisher's `gcc-16.2.0.tar.xz` | Local and remote SHA-512 both `c51c30ca7422d0cbecf504b2e0f33c3aca31e0f90a76b65217f465163fa6fa17b3f5de39e145c47e5bab90ac0ce7fff3b03c8d553ae36e01faaea5a50f8648d1` | DISCOVERED AND VERIFIED |
| Remote source path | `/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/source/gcc-16.2.0.tar.xz` | DISCOVERED AND VERIFIED |
| Remote script commit and hashes | `git rev-parse HEAD` was `45618f9`; PBS SHA-256 `14f6f0c87c19969f2480f3778d4144ca6557344a419dd3ffe3a485cbc2b94e01`; shell SHA-256 `3b041ceb4eff28c1e055db5f3e98a9e158d9b63fc45747da7c6073bba3b37c00` | DISCOVERED AND VERIFIED |
| PBS submission and start | `qsub` returned `181342083.gadi-pbs`; `qstat -f` later showed `R` on SPR node `gadi-cpu-spr-0138`, 104 CPUs, 06:00:00 walltime | DISCOVERED AND VERIFIED |
| Project allocation at preflight | `nci_account -P pm78`: 6.00 KSU available, 0 used, 0 reserved; scratch 195.21K / 202K inodes | DISCOVERED AND VERIFIED at submission time |

## Exact remote and scheduler commands

All SSH commands used the existing non-interactive alias; no interactive login
or credential material was accessed. The meaningful commands, in order, were:

```sh
ssh -O check gadi-comp
ssh -o BatchMode=yes gadi-comp 'cd /scratch/pm78/kj7183/openfoam_cpu/control-repo && git status --short --branch && git rev-parse HEAD && git log -1 --oneline && nci_account -P pm78'
git push gadi codex/gadi-gcc162-build
ssh -o BatchMode=yes gadi-comp 'git -C /scratch/pm78/kj7183/openfoam_cpu/control-repo pull --ff-only . codex/gadi-gcc162-build'
ssh -o BatchMode=yes gadi-comp 'git -C /scratch/pm78/kj7183/openfoam_cpu/control-repo status --short --branch; git -C /scratch/pm78/kj7183/openfoam_cpu/control-repo rev-parse HEAD; sha256sum /scratch/pm78/kj7183/openfoam_cpu/control-repo/builds/build-scripts/gadi-gcc162-ompi5010/build_gcc162.pbs /scratch/pm78/kj7183/openfoam_cpu/control-repo/builds/build-scripts/gadi-gcc162-ompi5010/build_gcc162.sh; bash -n /scratch/pm78/kj7183/openfoam_cpu/control-repo/builds/build-scripts/gadi-gcc162-ompi5010/build_gcc162.pbs /scratch/pm78/kj7183/openfoam_cpu/control-repo/builds/build-scripts/gadi-gcc162-ompi5010/build_gcc162.sh'
ssh -o BatchMode=yes gadi-comp 'test ! -e /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/source/gcc-16.2.0.tar.xz; test ! -e /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010; curl -sSIL --max-time 15 https://sourceware.org/pub/gcc/releases/gcc-16.2.0/gcc-16.2.0.tar.xz | head -n 12'
ssh -o BatchMode=yes gadi-comp 'mkdir -p /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/evidence /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/runtime-archive'
ssh -o BatchMode=yes gadi-comp 'curl -fL --retry 2 --max-time 900 -o /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/source/gcc-16.2.0.tar.xz.part https://sourceware.org/pub/gcc/releases/gcc-16.2.0/gcc-16.2.0.tar.xz'
ssh -o BatchMode=yes gadi-comp 'sha512sum /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/source/gcc-16.2.0.tar.xz.part; ls -lh /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/source/gcc-16.2.0.tar.xz.part'
ssh -o BatchMode=yes gadi-comp 'test ! -e /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/source/gcc-16.2.0.tar.xz && mv /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/source/gcc-16.2.0.tar.xz.part /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/source/gcc-16.2.0.tar.xz'
ssh -o BatchMode=yes gadi-comp 'test ! -e /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/build_gcc162.pbs.out && test ! -e /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/runtime-archive/gcc-16.2.0.*.tar.gz && git -C /scratch/pm78/kj7183/openfoam_cpu/control-repo rev-parse HEAD && sha512sum /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/source/gcc-16.2.0.tar.xz && nci_account -P pm78'
ssh -o BatchMode=yes gadi-comp 'cd /scratch/pm78/kj7183/openfoam_cpu/control-repo && /opt/pbs/default/bin/qsub builds/build-scripts/gadi-gcc162-ompi5010/build_gcc162.pbs'
ssh -o BatchMode=yes gadi-comp '/opt/pbs/default/bin/qstat -f 181342083.gadi-pbs | grep -E "Job Id:|job_state =|queue =|stime =|resources_used.walltime =|Exit_status =|comment =|Resource_List.walltime =|Resource_List.ncpus ="; nci_account -P pm78'
ssh -o BatchMode=yes gadi-comp '/opt/pbs/default/bin/qstat -f 181342083.gadi-pbs | grep -E "Job Id:|job_state =|queue =|stime =|resources_used.walltime =|Exit_status =|comment ="'
ssh -o BatchMode=yes gadi-comp 'tail -n 35 /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/build_gcc162.pbs.out 2>/dev/null; find /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/evidence -maxdepth 2 -name build.log -print'
ssh -o BatchMode=yes gadi-comp 'tail -n 32 /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/evidence/181342083.gadi-pbs/build.log'
```

Read-only local `git ls-remote`, Gadi `qstat` follow-up, and local source hash
checks were also performed; no other remote mutation occurred.

## Remaining unknowns and next step

Job result, elapsed time, actual SU, output archive path, archive
hash, and compiler relocation across distinct PBS jobfs paths are **TBD**.
Open MPI 5.0.10, OpenFOAM v2512 with this stack, and the scored 416-rank Scotch
run remain unprepared/unexecuted. Monitor this job to terminal state, preserve
the first failure if any, and validate the archive before preparing the next
reviewed remote-affecting diff.
