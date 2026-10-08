# Gadi / NCI Cluster Adapter

**Configuration status:** VERIFIED ACCESS — baseline reconstructed from raw evidence  
**Last reviewed:** 2026-09-02  
**Purpose:** independent, auditable configuration for future Gadi OpenFOAM
performance-engineering work.

This file is separate from the ASPIRE2A adapter. No ASPIRE2A path, Cray MPICH
setting, PALS launcher setting, or 128-CPU-node assumption is used as a Gadi
fact.

## Adapter fields

| Field | Value | Evidence | Status |
|---|---|---|---|
| Cluster | Gadi / NCI | User-provided target platform | CONFIRMED |
| SSH alias | `gadi-comp` | User-provided manual access bootstrap | CONFIRMED |
| SSH target | `gadi.nci.org.au` | User-provided manual access bootstrap | CONFIRMED |
| Remote user | `kj7183` | User-provided manual access bootstrap | CONFIRMED |
| Remote home | `/home/397/kj7183` | User-provided manual access bootstrap | CONFIRMED |
| Project/account | `pm78` | User-provided manual access bootstrap | CONFIRMED |
| Remote project root | `/scratch/pm78/kj7183/openfoam_cpu` | User-provided manual access bootstrap | CONFIRMED |
| Scratch path | `/scratch/pm78/kj7183` | User-provided manual access bootstrap | CONFIRMED |
| Scheduler | PBS Pro | `/opt/pbs/default/bin/qsub`, `/opt/pbs/default/bin/qstat`, `/opt/pbs/default/bin/qdel` on Gadi | CONFIRMED |
| Submission | `/opt/pbs/default/bin/qsub` | Successful command discovery on `gadi-comp` | CONFIRMED |
| Status | `/opt/pbs/default/bin/qstat` | Successful command discovery on `gadi-comp` | CONFIRMED |
| Cancellation | `/opt/pbs/default/bin/qdel` | Successful command discovery on `gadi-comp`; explicit approval remains required | CONFIRMED |
| CPU model | Intel Xeon Platinum 8274 @ 3.20 GHz | Phase 0 PBS output from allocated compute nodes, job `178063948.gadi-pbs` | DISCOVERED AND VERIFIED |
| Cores / topology per compute node | 2 sockets × 24 physical cores = 48 physical cores; SMT = 2 | Phase 0 PBS output from allocated compute nodes, job `178063948.gadi-pbs` | DISCOVERED AND VERIFIED |
| Known-good OpenFOAM | OpenFOAM.com v2512 | `APPLICATION.md` and local Gadi PBS example (`module load OpenFOAM/2512`) | DISCOVERED AND VERIFIED locally |
| Known-good baseline | 1 node/48 ranks; 2 nodes/96 ranks; 4 nodes/192 ranks; 150 SIMPLE iterations for scored 4-node reference | `APPLICATION.md`, `planning/PLANS.md`, user-provided current context | DISCOVERED AND VERIFIED from project evidence |
| 4-node reference time (pre-rule, Cascade Lake) | `ClockTime ≈ 787 s`, job `177602742.gadi-pbs` | `APPLICATION.md`, `planning/PLANS.md`, raw solver log below | DISCOVERED AND VERIFIED from project evidence. **SUPERSEDED as a reference (2026-09-09):** the scored reference is the official `normalsr` Sapphire Rapids result, 2.139565 s/step at 4N/416 ranks (job `178149002.gadi-pbs`); the controlled Cascade Lake reference is the Phase 0 four-run median, 797.5 s. This row remains valid as historical evidence. |
| MPI implementation/version | System Open MPI 4.1.7 | `module load OpenFOAM/2512`; `WM_MPLIB=SYSTEMOPENMPI`; `mpirun --version`; `ldd simpleFoam` | CONFIRMED |
| Compiler/version | **GCC 8.5.0 20210514 (Red Hat 8.5.0-26 / -28)** | `strings $(which simpleFoam) \| grep "^GCC:"` read from the shipped binary; node `gcc --version` agrees | DISCOVERED AND VERIFIED |
| Site-build target ISA | Generic x86-64: **zero AVX-512** anywhere in the hot path | `objdump -d`: `simpleFoam` zmm=0/ymm=0/xmm=3027; `libOpenFOAM` zmm=0/ymm=19162; `libfiniteVolume` zmm=0/ymm=92169 | DISCOVERED AND VERIFIED |
| Launcher | `mpirun -np "$PBS_NCPUS" simpleFoam -parallel` | `/scratch/pm78/kj7183/openfoam_cpu/case/occDrivAerStaticMesh/Allrun.gadi` | CONFIRMED |
| Binding/placement | No explicit binding flags in baseline; Open MPI/PBS allocation placement | `Allrun.gadi` and raw solver `Hosts`/`Pstream` sections | CONFIRMED for baseline script; detailed CPU binding map TBD |
| Decomposition | `hierarchical`; 48 `(8 3 2)`, 96 `(16 3 2)`, 192 `(16 6 2)` | `caseDefinition`, PBS preflight checks, and `40_decomposePar.log` files | CONFIRMED |
| Login-node policy | Lightweight inspection only | Project workflow policy and user request | PROVISIONAL; confirm with NCI |
| Compute-node policy | OpenFOAM runs, profiling, large builds only on compute nodes | Project workflow policy and user request | PROVISIONAL; confirm with NCI |
| Persistent SSH | `ControlMaster auto`, `ControlPath ~/.ssh/agent/%C`, `ControlPersist 4h` in `~/.ssh/config` | Read from the live config; master observed running, then observed expiring mid-session on 2026-09-03 | DISCOVERED AND VERIFIED |
| Persistent SSH check | `ssh -O check gadi-comp` | Returns `Master running (pid=...)`, or `Control socket connect(...): No such file or directory` once expired | DISCOVERED AND VERIFIED |
| Persistent SSH restore | `ssh -MNf gadi-comp` (user-run; may prompt for a passphrase) | Required after the 4 h `ControlPersist` window lapses | DISCOVERED AND VERIFIED |
| Behaviour once expired | Non-interactive `ssh -o BatchMode=yes` fails with `Permission denied (publickey,...)` | Observed 2026-09-03 while monitoring job `178149002` | DISCOVERED AND VERIFIED |
| Off-campus/VPN/jump host | `TBD` | Not discovered | TBD |

## Local evidence reviewed

### OpenFOAM baseline context

The repository records the following current Gadi reference:

```text
1 node / 48 MPI ranks
2 nodes / 96 MPI ranks
4 nodes / 192 MPI ranks
150 SIMPLE iterations
4-node ClockTime approximately 787 s
```

These are performance-engineering evidence, now cross-checked against the
remote scripts and raw logs listed below.

## Reconstructed baseline evidence

| Run | Nodes | MPI ranks | SIMPLE iterations | `ClockTime` | Raw solver log |
|---|---:|---:|---:|---:|---|
| 1-node baseline | 1 | 48 | 40 | 822 s | `/scratch/pm78/kj7183/openfoam_cpu/results/gadi_1n_baseline/50_simpleFoam.177590568.gadi-pbs.log` |
| 2-node baseline | 2 | 96 | 80 | 831 s | `/scratch/pm78/kj7183/openfoam_cpu/results/gadi_2n_baseline/50_simpleFoam.177597315.gadi-pbs.log` |
| 4-node baseline | 4 | 192 | 150 | 787 s | `/scratch/pm78/kj7183/openfoam_cpu/case/occDrivAerStaticMesh/logFiles/50_simpleFoam.177602742.gadi-pbs.log` |
| Phase 0 independent repeat | 4 | 192 | 150 | 802 s | `/scratch/pm78/kj7183/openfoam_cpu/phase0-baseline-repeat-20260902/case/logFiles/50_simpleFoam.178063948.gadi-pbs.log` |

The exact final 4-node line is:

```text
Time = 150
ExecutionTime = 776.52 s  ClockTime = 787 s
```

The solver logs report OpenFOAM build:

```text
Build  : _87ed40d256-20251219 OPENFOAM=2512 version=v2512
Arch   : "LSB;label=32;scalar=64"
```

The baseline PBS scripts are:

```text
/scratch/pm78/kj7183/openfoam_cpu/scripts/drivaer_1n.pbs
/scratch/pm78/kj7183/openfoam_cpu/scripts/drivaer_2n.pbs
/scratch/pm78/kj7183/openfoam_cpu/scripts/drivaer_4n.pbs
```

They use `module purge; module load OpenFOAM/2512`, `OMP_NUM_THREADS=1`,
`ulimit -s unlimited`, PBS working directory mode, and invoke
`bash ./Allrun.gadi`. `Allrun.gadi` performs `decomposePar -force`, then
launches `simpleFoam` with `mpirun -np "$PBS_NCPUS"`.

Raw decomposition logs:

```text
/scratch/pm78/kj7183/openfoam_cpu/results/gadi_1n_baseline/40_decomposePar.log
/scratch/pm78/kj7183/openfoam_cpu/results/gadi_2n_baseline/40_decomposePar.log
/scratch/pm78/kj7183/openfoam_cpu/case/occDrivAerStaticMesh/logFiles/40_decomposePar.log
```

PBS resource requests and decomposition checks:

| Script | PBS resources | `nCores` | `nHierarchical` | `endTime` |
|---|---|---:|---|---:|
| `drivaer_1n.pbs` | `ncpus=48`, `mem=190GB`, `storage=scratch/pm78` | 48 | `(8 3 2)` | 40 |
| `drivaer_2n.pbs` | `ncpus=96`, `mem=380GB`, `storage=scratch/pm78` | 96 | `(16 3 2)` | 80 |
| `drivaer_4n.pbs` | `ncpus=192`, `mem=760GB`, `storage=scratch/pm78` | 192 | `(16 6 2)` | 150 |

The baseline scripts contain no explicit `--bind-to`, `--map-by`, or
`--cpu-bind` option. Placement is therefore delegated to PBS/Open MPI defaults
for this baseline; the exact binding map remains a TBD diagnostic detail.

### Legacy local PBS example (not active configuration)

`/Users/sofia/Downloads/gadi_openfoam_benchmark.txt` is retained only as
historical local evidence. Its `vr32` account/path is obsolete for this
project and must not be used. It contains:

```text
#PBS -P vr32                 # obsolete; do not use
#PBS -q normal
#PBS -l ncpus=48
#PBS -l mem=190GB
#PBS -l storage=scratch/vr32 # obsolete; do not use
module load OpenFOAM/2512
```

The example is not evidence for the current `pm78` account, paths, CPU
topology, compiler, MPI, or launcher configuration.

A separate local build note contains:

```text
module load gcc/11.2.0
module load openmpi/4.1.2-hpe
```

That note concerns a Neko build, not the OpenFOAM Gadi baseline. It therefore
does **not** establish the OpenFOAM MPI version. The suspected OpenMPI 4.1.7
value remains TBD until confirmed from an OpenFOAM raw log or remote module
inspection.

## SSH and scheduler policy

### Approved discovery form

Once a working alias is confirmed, use a non-interactive, read-only form such
as:

```bash
ssh <gadi-alias> 'hostname; whoami; pwd; command -v qsub; command -v qstat; command -v qdel; command -v mpirun'
```

Discovery may include `module list`, `module avail`, `module show`, `lscpu`,
read-only `ls`/`find`/`stat`/`grep`/`cat`, and read-only account/project
inspection. Do not read passwords, private keys, tokens, or authentication
configuration.

### Scheduler use

Expected PBS syntax is:

```bash
qsub <script.pbs>
qstat <jobid>
qstat -xf <jobid>
qdel <jobid>   # explicit approval required
```

Submitting a benchmark, cancelling a job, modifying remote files, compiling,
or running OpenFOAM requires explicit authorization for that action. `qstat`
monitoring must be bounded and should preserve the final `qstat -xf` record.

### Login node versus compute node

Login-node activity is limited to lightweight inspection, module discovery,
Git metadata, file transfer, scheduler queries, and syntax checks. OpenFOAM
production runs, large `decomposePar`, `simpleFoam`, profiling, and large
compilations belong on allocated compute nodes.

## Separation from ASPIRE2A

| Dimension | ASPIRE2A | Gadi |
|---|---|---|
| Scheduler | PBS | PBS Pro expected; remote verification pending |
| MPI | Cray MPICH 8.1.15 | TBD; do not copy Cray MPICH |
| Launcher | PALS `mpirun` 1.1.6 | `mpirun` expected, exact form TBD |
| Node shape | 128 CPUs/node in ASPIRE2A diagnostics | 48-rank baseline allocation; hardware topology TBD |
| OpenFOAM module | `openfoam/2512` | `OpenFOAM/2512` in local example; remote verification pending |
| Project path | `/home/project/59000020/openfoam-isc26` | `/scratch/vr32/$USER/openfoam_cpu` appears in local example; remote verification pending |
| Binding | `--cpu-bind depth -d 1` in ASPIRE2A diagnostics | TBD |

No ASPIRE2A path or runtime setting should be used in a Gadi script unless it
is independently discovered and verified.

## Readiness assessment

**READY FOR DOCUMENTED PHASE 0 REPEATABILITY RUNS: YES**

Job `178063948.gadi-pbs` independently validated the access path, account,
compute-node topology, OpenFOAM module, compiler, MPI, launcher, PBS request,
fresh-case isolation, and solver completion. Each future submission remains
subject to separate explicit approval. No compiler, MPI, binding,
decomposition, or numerical optimisation is authorised by this readiness
statement.

## Persistent-connection expiry (2026-09-03)

`ControlPersist 4h` means the shared master connection lapses silently mid-session.
Once it does, every non-interactive `ssh -o BatchMode=yes` returns
`Permission denied (publickey,gssapi-keyex,gssapi-with-mic,password,hostbased)`,
because re-authentication needs a credential only the user can supply. Restoring
it is a user action:

```bash
ssh -MNf gadi-comp     # rebuild the background master
ssh -O check gadi-comp # expect: Master running (pid=...)
```

**Monitoring scripts must not treat an ssh failure as a job result.** The first
watcher used here reported `STATE=FINAL` when the connection dropped, because a
dead transport and a finished job both produced empty output - it would have
recorded a running job as complete. Any watcher must check the ssh exit status
separately from the scheduler's answer, and report an unreachable cluster as
**unknown**, never as an outcome.

## Project storage and inode quota — observation 2026-09-09

Planning observation only. **No cleanup action has been taken.**

| Resource | Observed | Limit | Utilisation |
| --- | --- | --- | --- |
| `pm78` scratch storage | 165.05 GiB | 1.00 TiB | **16.1%** — healthy |
| `pm78` scratch inodes | 184,906 | 202,000 (normal quota) | **91.54%** — high |
| `pm78` scratch inodes | 184,906 | 212,100 (hard limit) | 87.18% |

Headroom: **17,094** inodes to the normal quota, **27,194** to the hard limit.

**Interpretation.** Storage capacity is not a constraint; inode count is. The
binding resource is the *number of files*, not their size.

**Why this matters here specifically.** A staged OpenFOAM v2512 source tree is
192,042 regular files plus 10,976 symlinks — **203,018 inodes**, recorded by
`SOURCE_ID_V2` in
[`../results/s1-autonomous-debug-summary.md`](../results/s1-autonomous-debug-summary.md).
That is roughly **12x the remaining scratch headroom**. A single source
extraction onto `/scratch` would breach the quota outright.

This is why the build and benchmark workflows stage into node-local
`$PBS_JOBFS` rather than `/scratch`, and it is an argument for keeping that
design rather than a convenience.

**Practical rules until the quota position changes:**

- Do not extract OpenFOAM source or ThirdParty trees onto `/scratch`; use
  `$PBS_JOBFS`, which is node-local and not charged against this quota.
- Do not create Python virtual environments or Conda prefixes on `/scratch` —
  each is tens of thousands of small files.
- Prefer archives (`.tar.gz`) to unpacked trees for anything retained between
  jobs. The C1 runtime is already kept this way.
- Case `processor*` directories are the other large inode consumer: a 416-way
  decomposition creates 416 directories each holding several files. Remove old
  run cases once their evidence has been extracted.
- Check with `nci_account` / `lquota` before any workflow expected to create
  many small files.

No files have been deleted and no quota cleanup has been performed. Deciding
what to reclaim is a separate, reviewed action.
