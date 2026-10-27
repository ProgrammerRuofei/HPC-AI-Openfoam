# a2a-comp-aocc-pgo

User (2026-09-15) asked to try Phase 7 PGO even though Phase 6
did not win. Site AOCC 5.0 + OpenMPI. New platforms only:

- `linux64AmdDPInt32PgoGen`
- `linux64AmdDPInt32PgoUse`

Does not overwrite `linux64AmdDPInt32Opt`. Clang PGO via
`wmake/rules/General/common/c++PgoGen` and `c++PgoUse` (Amd includes
`General/Clang/c++`, which `sinclude`s those). Training run is 1-node
kahip occDrivAer with `LLVM_PROFILE_FILE`. Compare is 4-node kahip pin
vs 2.868. 4-node kahip pin `21252868` is **2.868 / 0.2800** (PgoUse;
Opt pin freeze `20092999` is 2.869 / 0.2800). GCC PGO is a separate platform set under
`a2a-comp-gcc-pgo/` (`linux64Gcc/c++Pgo*`).
