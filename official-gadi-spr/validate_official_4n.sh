#!/bin/bash
# Static compliance gate for the first official 4N baseline; no remote write.
set -euo pipefail
pbs=official-gadi-spr/official_baseline_4n.pbs
grep -q '^#PBS -q normalsr$' "$pbs"; grep -q '^#PBS -l ncpus=416$' "$pbs"; grep -q '^#PBS -l mem=760GB$' "$pbs"; ! grep -q '^[[:space:]]*#PBS[[:space:]]\+-l[[:space:]]\+select=' "$pbs"
for x in 'decomposePar -constant' 'restore0Dir -processor' 'renumberMesh -constant -overwrite -parallel' 'potentialFoam -initialiseUBCs -parallel' 'applyBoundaryLayer -ybl 0.0450244 -parallel' 'simpleFoam -parallel'; do grep -Fq "$x" "$pbs"; done
grep -Fq 'controlDict.noWrite' "$pbs"; grep -Fq 'fvSolution.fixedIter' "$pbs"; grep -Fq 'endTime[[:space:]]+150' "$pbs"; grep -Fq 'NRANKS=416' "$pbs"; grep -Fq '(16 13 2)' "$pbs"; grep -Fq 'nCores[[:space:]]+416' "$pbs"
echo OFFICIAL_4N_STATIC_GATE_PASS
