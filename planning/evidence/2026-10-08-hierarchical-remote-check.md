# ASPIRE2A hierarchical read-only check — 2026-10-08

Purpose: verify whether hierarchical `(8 8 8)` is the fastest observed 4-node layout. All SSH commands used the documented `aspire2a-comp` alias. No remote writes, transfers, scheduler commands or jobs occurred.

## Exact commands

```sh
ssh -O check aspire2a-comp
ssh aspire2a-comp 'find /home/users/industry/ai-hpc/apacsc20/scratch/openfoam-v2512/cases -maxdepth 1 -type d -iname "*hier*" -print'
ssh aspire2a-comp 'for n in occdrivaer-occdrivaer_4node_aocc_hier888_v1 occdrivaer-occdrivaer_4node_aocc_hier32161_v1 occdrivaer-occdrivaer_4node_aocc_hier1684_v1; do p=/home/users/industry/ai-hpc/apacsc20/scratch/openfoam-v2512/cases/$n; echo CASE=$n; ls "$p"/logFiles/50_simpleFoam*.log "$p"/postProcessing/forceCoeffsAll/0/coefficient.dat 2>/dev/null; grep -E "Average wall-clock time per time step|^Time = 150$|^End$|Finalising parallel run" "$p"/logFiles/50_simpleFoam*.log 2>/dev/null | tail -n 5; tail -n 1 "$p"/postProcessing/forceCoeffsAll/0/coefficient.dat 2>/dev/null; grep -E "nCores|decompositionMethod|nHierarchical" "$p"/system/include/caseDefinition 2>/dev/null | tail -n 5; done'
ssh aspire2a-comp 'find /home/project/59000020/openfoam-isc26 -maxdepth 6 -type f \( -iname "*hier32161*" -o -iname "*hier1684*" \) -print; for n in occdrivaer-occdrivaer_4node_aocc_hier32161_v1 occdrivaer-occdrivaer_4node_aocc_hier1684_v1; do p=/home/users/industry/ai-hpc/apacsc20/scratch/openfoam-v2512/cases/$n; echo CASE=$n; find "$p" -maxdepth 2 -type f \( -name "*.pbs" -o -name "run.log" -o -name "*.txt" \) -print | head -n 15; done'
```

The fourth command traversed too broadly and was interrupted with Ctrl-C; it did not change state.

```sh
ssh aspire2a-comp 'for n in occdrivaer-occdrivaer_4node_aocc_hier32161_v1 occdrivaer-occdrivaer_4node_aocc_hier1684_v1; do p=/home/users/industry/ai-hpc/apacsc20/scratch/openfoam-v2512/cases/$n; echo CASE=$n; ls -1 "$p" | head -n 25; grep -m 6 -E "^Build|^Exec|^Version|^Host|^Case|^nProcs|^I_MPI|^WM_|^MPI" "$p"/logFiles/50_simpleFoam*.log 2>/dev/null; done'
ssh aspire2a-comp 'ls -1 /home/users/industry/ai-hpc/apacsc20/scratch/openfoam-v2512 | head -n 35; for n in occdrivaer-occdrivaer_4node_aocc_hier32161_v1 occdrivaer-occdrivaer_4node_aocc_hier1684_v1; do p=/home/users/industry/ai-hpc/apacsc20/scratch/openfoam-v2512/cases/$n; echo CASE=$n; sed -n "1,22p" "$p"/README.md; done'
ssh aspire2a-comp 'for n in occdrivaer-occdrivaer_4node_aocc_hier888_v1 occdrivaer-occdrivaer_4node_aocc_hier32161_v1 occdrivaer-occdrivaer_4node_aocc_hier1684_v1; do p=/home/users/industry/ai-hpc/apacsc20/scratch/openfoam-v2512/cases/$n; echo CASE=$n; ls -1 "$p"/logFiles | head -n 18; grep -E "^nCores|^decompositionMethod|^nHierarchical" "$p"/system/include/caseDefinition; done'
ssh aspire2a-comp 'ls -1 /home/project/59000020/openfoam-isc26 | head -n 35; ls -1 /home/users/industry/ai-hpc/apacsc20/scratch/openfoam-v2512/pgo | head -n 25'
ssh aspire2a-comp 'ls -1 /home/project/59000020/openfoam-isc26/results | head -n 30; ls -1 /home/project/59000020/openfoam-isc26/scripts | head -n 30'
ssh aspire2a-comp 'for n in occdrivaer-occdrivaer_4node_aocc_hier888_v1 occdrivaer-occdrivaer_4node_aocc_hier32161_v1 occdrivaer-occdrivaer_4node_aocc_hier1684_v1; do p=/home/users/industry/ai-hpc/apacsc20/scratch/openfoam-v2512/cases/$n; echo CASE=$n; sed -n "12,31p" "$p"/logFiles/50_simpleFoam*.log | tail -n 15; done'
```

## Facts and status

| Fact | Value | Evidence | Status |
| --- | --- | --- | --- |
| Connection | `Master running (pid=67280)` | `ssh -O check aspire2a-comp` | DISCOVERED AND VERIFIED |
| `(8 8 8)` | 3.355476165798657 s/step; Cd 0.2984295690 | case solver log, coefficient.dat, caseDefinition | DISCOVERED AND VERIFIED |
| `(16 8 4)` | 3.190876091456376 s/step; Cd 0.2735612542 | same | DISCOVERED AND VERIFIED |
| `(32 16 1)` | 3.007944486610739 s/step; Cd 0.2900220548 | same | DISCOVERED AND VERIFIED |
| All three | 4-node case names, 512 ranks, 150 steps, normal solver end | original case log and caseDefinition | DISCOVERED AND VERIFIED |
| `(32 16 1)` build/binding identity | Prior local analysis says PgoUse tree; current case log alone does not prove exact binary or binding | local analysis vs remote case log | TBD for strict A/B |

Remaining TBD: complete inventory of any other 4-node hierarchical cases outside this scratch case root; exact build and binding provenance for `(32 16 1)` and `(16 8 4)`; full input equivalence; controlled repeatability. Remote state changes: none. Local change: presentation evidence document updated to state `(32 16 1)` is fastest observed hierarchical run and to correct the case description.
