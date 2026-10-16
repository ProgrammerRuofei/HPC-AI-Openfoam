# Gadi ICX screening after the GCC baseline

## Confirmed starting point

The GCC 16.2.0 + Open MPI 5.0.10 + UCX 1.18.1 + UCC 1.4.4 OpenFOAM
v2512 build completed two identical `normalsr` Sapphire Rapids four-node
Scotch runs: 416 ranks, 150 steps, 1.991194389 and 1.988625920 s/step,
with final Cd 0.291875949 in both. Details and evidence are in
`results/gadi-gcc162-ompi5010-scotch/run-registry.md`.

Read-only Gadi module inspection found no `intel-compiler-llvm/2026.1`.
The newest available module was `intel-compiler-llvm/2025.3.2`; loading it
reported ICX/ICPX 2025.3.2 (2025.3.2.20260112). The other team's ICX
2026.1 timing is therefore context, not a directly reproducible toolchain
version on this Gadi installation. NCI reported pm78 6.00 KSU grant,
732.53 SU used, zero reserved, and 5.27 KSU available before screening.

## Step 1: compiler / MPI compatibility probe

The first experiment checks whether ICX 2025.3.2 can compile and run a
C++ MPI program with the existing private Open MPI 5.0.10 archive. It
reuses the verified GCC runtime archive only to satisfy dependencies of
that MPI build. It loads Gadi's UCX 1.18.1 and UCC 1.4.4 modules. The
probe requests one `normalsr` SPR node, four CPUs, 16 GB memory, 8 GB
JOBFS, and 20 minutes maximum. It verifies archive hashes, versions,
wrapper compilers, private libmpi linkage, and two UCX MPI ranks.

Script: `builds/build-scripts/gadi-icx20253-ompi5010/smoke_icx_ompi_1n.pbs`.
It passed local and Gadi `bash -n`; commit `eda1ebf` was pushed to GitHub
and Gadi, and the remote checkout fast-forwarded to
`eda1ebfa218e4d2aa867d6d545caf9403720fc11`. Submission command:

```sh
ssh -o BatchMode=yes gadi-comp 'set -e; cd /scratch/pm78/kj7183/openfoam_cpu/control-repo; test "$(git rev-parse HEAD)" = eda1ebfa218e4d2aa867d6d545caf9403720fc11; mkdir -p /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010/submit-logs; test ! -e /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010/submit-logs/smoke_icx_ompi_1n.pbs.out; qsub builds/build-scripts/gadi-icx20253-ompi5010/smoke_icx_ompi_1n.pbs'
```

PBS returned **`181382175.gadi-pbs`**. First status check showed `Q`.
The script preserves job-keyed evidence at
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010/evidence/181382175.gadi-pbs/`.
Next, validate `Exit_status=0`, `ICX20253_OMPI5010_ABI_SMOKE_PASS`,
private MPI linkage, two-rank output and actual SU. A failure should be
diagnosed from the first error before deciding whether a separate ICX MPI
build is needed. Do not rebuild UCX merely because its module is reused.

After this gate, build OpenFOAM v2512 with ICX, confirm real Scotch and
MPI linkage, run a small tutorial, and only then compare the unchanged
four-node 416-rank Scotch 150-step workload with the GCC baseline.

## Probe result and ICX OpenFOAM build preparation

Job `181382175.gadi-pbs` finished with PBS `Exit_status=0`, 20 seconds
walltime, and `ICX20253_OMPI5010_ABI_SMOKE_PASS`. The node was an Intel
Xeon Platinum 8470Q (SPR). The log confirms ICX/ICPX 2025.3.2,
Open MPI 5.0.10, `mpicc` using `icx`, `mpicxx` using `icpx`, linkage to
the job-local private `libmpi.so.40`, no missing dynamic libraries, and
both MPI ranks running with `--mca pml ucx`. The `nci_account` reading
immediately after completion still showed 2.67 SU reserved and 732.53 SU
used; the final posted charge remains to be checked.

The next build keeps the same authoritative OpenFOAM source and source-ID
verification, private MPI archive, UCX/UCC modules, `Opt` setting, and
real Scotch validation. It changes the compiler to the available ICX
2025.3.2, selects `WM_COMPILER=Icx`, and stores output under a distinct
ICX stack ID. The existing GCC build path remains supported by the common
helper. The build script and PBS request are in
`builds/build-scripts/gadi-icx20253-ompi5010/`.
