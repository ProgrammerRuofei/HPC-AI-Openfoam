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
