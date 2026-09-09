# C1 — ICC 2021.10 + Open MPI 4.1.7

Compiler-screening build for OpenFOAM v2512.  It uses the common JOBFS source
staging and SOURCE_ID_V2 implementation, with `WM_COMPILER=Icc` and
`WM_MPLIB=SYSTEMOPENMPI`; no compiler tuning is introduced.

## Attempt 3 — `178163598.gadi-pbs`

The build passed JOBFS staging, SOURCE_ID_V2, `wmkdepend`, and ThirdParty, then
stopped in OpenFOAM `src` with ICC 2021.10 failing to resolve C++17 aligned
`operator new[]`/`operator delete[]`.  ICC did not define
`__cpp_aligned_new` even under `-std=c++17`; the GCC 8 `libstdc++` declarations
are guarded by that macro.  This is a compiler compatibility failure, not a
source-identity, MPI, or scientific-workload failure.

## Attempt 4 compatibility repair

Only C1 enables `ICC_ALIGNED_NEW_WORKAROUND=1`.  After SOURCE_ID_V2 succeeds,
the build appends `-D__cpp_aligned_new=201606L` to the staged JOBFS copy of
`wmake/rules/linux64Icc/c++`.  `/apps/OpenFOAM/2512` is never modified; the
workaround is recorded in evidence and no numerical, MPI, or runtime setting
changes.

## Attempt 4 result — `178166039.gadi-pbs`

The aligned-allocation repair worked: SOURCE_ID_V2, JOBFS staging, ThirdParty,
and the OpenFOAM `src` build advanced past the prior `ListPolicy.H` failure.
ICC 2021.10 then rejected `CircularBuffer::toGlobal` when instantiating
`OFstreamCollator`: the declaration uses `const label i`, and ICC incorrectly
treated the definition's local value parameter as non-modifiable.  This is a
second ICC front-end compatibility issue, unrelated to the source identity or
runtime configuration.

## Attempt 5 compatibility repair

Only C1 enables `ICC_CIRCULARBUFFER_CONST_WORKAROUND=1`.  After SOURCE_ID_V2
verification, it changes the staged JOBFS declaration to `toGlobal(label i)`.
The out-of-line definition already uses `label i`; `/apps/OpenFOAM/2512` is
not modified.  Attempt 5 is limited to the approved three-hour retry budget.

## Attempt 5 result — `178166771.gadi-pbs` — `BUILD_VALIDATION_PASS`

The `CircularBuffer` repair held and the build completed on Cascade Lake node
`gadi-cpu-clx-1303`: Exit_status 0, PBS walltime 01:26:52, peak memory about
97.5 GiB. Both the authoritative and JOBFS-staged `SOURCE_ID_V2` values matched
`5e43349d5b302beb354e4e0d9842ff8148cfed069fb0f1a224616df6021c18db`. The
produced `simpleFoam` is `73a3260e2dfec970a9b76de990983fffd4ed8a47363aa497a89560f5c684533d`.

The build ran from Gadi commit `cfc6c95`, which is not present in the Mac
history; its `builds/` tree is byte-identical to Mac commit `1765c86`.

A build node produces an artifact, not a timing. This is not a performance
result.

## Runtime validation chain

The two scripts below are runtime **correctness** validation for the artifact
above. Neither produces a performance number.

| Stage | Script | PBS job | Outcome |
| --- | --- | --- | --- |
| Archive closure | `repair_c1_runtime_archive_v2.pbs` | `178252413.gadi-pbs` | `C1_RUNTIME_ARCHIVE_V2_PASS` — added only the authoritative v2512 `bin/` tree and reviewed `META-INFO/api-info`, then re-hashed. No rebuild; the original archive was preserved. |
| Runtime smoke | `smoke_c1_icc2021_openmpi417.pbs` | `178254935.gadi-pbs` | `C1_RUNTIME_SMOKE_PASS` — `gadi-cpu-clx-2372`, 1 node / 5 CPUs / 5 ranks, Exit_status 0, walltime 14 s. `pitzDaily_fused` reached `Time = 200`; `blockMesh`, `decomposePar`, the five-rank MPI probe, and JOBFS runtime/library isolation all passed. |

An earlier smoke attempt (`178249214.gadi-pbs`) failed because the first
archive omitted `bin/foamEtcFile` and `bin/foamCleanPath`; that is what the
archive-closure job above repaired.

> **Provenance gap.** Both jobs were submitted from scripts that were untracked
> in the Gadi clone, so neither run can cite a commit. See lesson L11 in
> [`../../../results/hpc-lessons.md`](../../../results/hpc-lessons.md).

## Pending — 65M screening benchmark

`benchmark_c1_65m_4n.pbs` (with `stage_c1_runtime_node.sh`) is written and
statically verified but **not committed and not submitted**. It targets Gadi
`normal` (Cascade Lake), 4 nodes x 48 ranks = 192, hierarchical `(16 6 2)`, and
emits `C1_65M_SCREEN_PASS`. Its comparison reference is the Phase 0 median
(ClockTime 797.5 s) on identical hardware and rank count.

It is a `SCREENING` run. Official results require Gadi `normalsr` (Sapphire
Rapids) under the official rules; no official C1 run has been attempted.
