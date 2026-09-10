# Next-generation toolchain candidates — prepared, not yet built

Zero-SU preparation. **Nothing here has been run.** Each stack definition is a
few lines of environment on top of the already-validated shared build script
`../common/build_openfoam_v2512_openmpi.sh`.

## Why these four

The site build we have been benchmarking uses **GCC 8.5.0**. Gadi carries GCC
up to **15.1.0**, ICX up to **2025.3.2**, and Intel MPI up to **2021.17.2**.

| Stack | Compiler | MPI | Targeting | Tests |
| --- | --- | --- | --- | --- |
| `D1-gcc15-openmpi417` | GCC 15.1.0 | OpenMPI 4.1.7 | none (`Opt`) | 7 major GCC releases of optimiser work, everything else held |
| `D2-icx2025-openmpi417` | ICX 2025.3.2 | OpenMPI 4.1.7 | none (`Opt`) | ICX against ICC generic at matched `-O3` |
| `D3-icx2025-avx512-openmpi417` | ICX 2025.3.2 | OpenMPI 4.1.7 | `OptAVX512` | the AVX-512 question ICC could not answer |
| `D4-icx2025-intelmpi` | ICX 2025.3.2 | Intel MPI 2021.17.2 | none (`Opt`) | MPI implementation, compiler held at D2 |

Only one variable moves per stack, so each result is attributable.

## The finding that makes D3 worth doing

`wmake/rules/linux64Icc/c++` and `wmake/rules/linux64Icx/c++` differ in one
flag, and it is the flag that blocked the ICC branch:

```
Icc: c++ARCH := -pthread -fp-trap=common -fp-model=precise
Icx: c++ARCH := -pthread -fp-model=precise
```

`178663697` died with SIGFPE because ICC vectorised `GAMGSolver::scale()` into
an **unmasked** `vdivpd` over zero-filled tail lanes — `0.0/0.0` raises
`FE_INVALID`, and `-fp-trap=common` turns that into a fatal signal. **ICX's
OpenFOAM rules do not enable FP trapping at all**, so the same code generation
would not raise the signal.

That is a claim about the trap, not about correctness or speed: an unmasked
divide over zero-filled lanes is still being executed, and whether ICX emits
the same shape of loop is unknown until we look at its binary.

## Known hazards, already characterised

**Intel MPI + OpenFOAM (D4).** `WM_MPLIB` must be passed **as an argument to
`etc/bashrc`**, never pre-exported: `etc/bashrc` resets a pre-exported
`WM_MPLIB=INTELMPI` back to `SYSTEMOPENMPI`, after which
`etc/config.sh/mpi` sends `mpicc --showme:link` to Intel MPI's wrapper, which
forwards it to the compiler and fails. Job `178138805` lost 17.87 SU to exactly
this. The shared script has always passed `WM_MPLIB` as an argument.

Layout checks done for Intel MPI 2021.17.2: `I_MPI_ROOT` is
`/apps/intel-tools/intel-mpi/2021.17.2`, there is **no** `intel64`
subdirectory, so wmake's `mplib-x86_64-INTELMPI` rule resolves to
`-L$(MPI_ARCH_PATH)/lib/release -lmpi`, and `lib/release/libmpi.so.12` exists.
NCI presets `I_MPI_HYDRA_BOOTSTRAP=rsh` with `pbs_tmrsh`, so PBS integration is
already in place.

**Contamination gates invert for D4.** Every existing harness treats
`libmpi.so.12` as evidence of Intel MPI contamination. For the Intel MPI stack
that library is the *expected* one; the OpenMPI string becomes the contaminant.
`EXPECT_LDD_MPI` carries this.

**New compiler, new source incompatibilities.** ICC 2021.10 needed two reviewed
workarounds against v2512 (`__cpp_aligned_new`, `CircularBuffer::toGlobal`).
GCC 15 and ICX 2025 are seven and four years newer than the compilers this
source was most tested against; expect some, and budget a failed build.

## What is NOT prepared

`linux64Gcc` ships **no** `c++OptAVX512` rule — GCC has only `c++Opt`. GCC
architecture targeting would need either a new rule file or
`FOAM_EXTRA_CXXFLAGS`, and neither is written here, because the profile
evidence does not yet justify spending a build on GCC arch targeting.
