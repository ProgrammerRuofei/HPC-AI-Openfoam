# ASPIRE2A hierarchical `(32 16 1)` stock Opt control — prepared

Current step: Step 2 local experiment preparation. No job submitted.

## Completed

- Read the numbered workflow instructions, `AGENTS.md`, `APPLICATION.md`,
  the latest prior progress report, and local Git state.
- Confirmed the existing `aspire2a-comp` SSH master and read only the remote
  control checkout, teammate script directory, scheduler state, target-case
  absence, selected template hashes, and the existing stock Opt binary.
- Prepared `experiments/aspire2a-hier32161-opt-4n/` with a guarded, unique
  PBS-ID case path, one unprofiled 4-node/512-rank/150-step run, complete
  Allrun preparation chain, no explicit binding, and fresh 150-row Cd gate.
- `bash -n` passed. No remote write, transfer, commit, push, pull, build,
  `qsub`, `qdel`, or OpenFOAM execution occurred.

## Evidence and outstanding review

- Local HEAD is `0da839c`; the remote control checkout is its parent
  `f6cb2ed`. Existing local modified/untracked files and remote untracked
  PBS outputs were preserved.
- Remote template hashes for `caseDefinition`, `decomposeParDict`,
  `controlDict.noWrite`, `fvSchemes`, and `fvSolution.fixedIter` match the
  prepared script's gates. The existing stock Opt `simpleFoam` path exists;
  its mtime precedes the original weighted Scotch job.
- The run writes a new case under `~/scratch/openfoam-v2512/cases/`, outside
  the adapter's documented approved project root. The project also requires
  presenting the local diff and waiting for approval before remote-affecting
  actions. Those approvals are the current gate.
- Exact read-only remote commands:

```sh
ssh -O check aspire2a-comp
ssh aspire2a-comp 'test -d /home/project/59000020/openfoam-isc26/control-repo && git -C /home/project/59000020/openfoam-isc26/control-repo status --short && git -C /home/project/59000020/openfoam-isc26/control-repo rev-parse HEAD; test -d /home/users/industry/ai-hpc/apacsc20/OpenFoam-HPCAI-26/experiments/occdrivaer-static && echo TEAM_SCRIPT_DIR_OK; test -e /home/users/industry/ai-hpc/apacsc20/scratch/openfoam-v2512/cases/occdrivaer-occdrivaer_4node_aocc_hier32161_opt_v1 && echo TARGET_EXISTS || echo TARGET_ABSENT; qstat -u apacsc20 | tail -n 12'
ssh aspire2a-comp 'p=/home/users/industry/ai-hpc/apacsc20/scratch/openfoam-v2512; t=$(readlink -f "$p/cases/occDrivAerStaticMesh-template"); printf "TEMPLATE=%s\n" "$t"; sha256sum "$t/system/include/caseDefinition" "$t/system/decomposeParDict" "$t/system/controlDict.noWrite" "$t/system/fvSchemes" "$t/system/fvSolution.fixedIter"; stat -c "BINARY=%n size=%s mtime=%y" "$p/OpenFOAM-v2512/platforms/linux64AmdDPInt32Opt/bin/simpleFoam"; test -d "$t/constant/polyMesh" && echo MESH_PRESENT; test -d /home/project/59000020/openfoam-isc26/control-repo/experiments/aspire2a-six-step && echo CONTROL_EXPERIMENTS_PRESENT'
ssh aspire2a-comp 'find /home/users/industry/ai-hpc/apacsc20/scratch/openfoam-v2512/cases -maxdepth 1 -type d -name "hier32161-opt-4n-v1-*" -print'
```

## Resume action

After approval of the presented diff and scratch output path: commit only
the new experiment and this progress note; push to the existing ASPIRE2A
bare Git transport; fast-forward pull the control checkout; verify exact
script hash, output nonexistence and `bash -n`; submit the PBS script once;
then monitor at bounded intervals and validate solver time and fresh Cd.
