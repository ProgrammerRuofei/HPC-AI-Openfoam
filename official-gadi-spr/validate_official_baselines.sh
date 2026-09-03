#!/bin/bash
# Static compliance gate for the official 1N/2N/4N normalsr baselines.
# Local-only: parses the PBS scripts, performs no remote access and no writes.
#
# Checks per scaling point: the official queue and resource shape, the complete
# six-step preparation chain, the mandated iteration count, fixedIter/noWrite,
# the untouched -ybl value, and that ranks equal the product of the hierarchical
# decomposition.  Run before every qsub.
set -uo pipefail
cd "$(dirname "$0")/.."

rc=0
report() { printf '  %-46s %s\n' "$1" "$2"; [ "$2" = PASS ] || rc=1; }
has()    { grep -Fq -e "$2" -- "$1" && echo PASS || echo FAIL; }
hasre()  { grep -Eq "$2" "$1" && echo PASS || echo FAIL; }

# check_one <pbs> <nodes> <ncpus> <mem> <endTime> <decomposition>
check_one() {
  pbs=$1; nodes=$2; ncpus=$3; mem=$4; endtime=$5; hier=$6
  echo "== $pbs (${nodes}N, ${ncpus} ranks, endTime=${endtime}, ${hier}) =="
  if [ ! -f "$pbs" ]; then report "file exists" FAIL; return; fi

  # -- official hardware and resource shape -----------------------------------
  report "queue is normalsr"          "$(hasre "$pbs" '^#PBS -q normalsr$')"
  report "ncpus=${ncpus}"             "$(hasre "$pbs" "^#PBS -l ncpus=${ncpus}$")"
  report "mem=${mem}"                 "$(hasre "$pbs" "^#PBS -l mem=${mem}$")"
  report "walltime requested"         "$(hasre "$pbs" '^#PBS -l walltime=[0-9]{2}:[0-9]{2}:[0-9]{2}$')"
  report "storage=scratch/pm78"       "$(hasre "$pbs" '^#PBS -l storage=scratch/pm78$')"
  # Gadi derives select= from the aggregate request; an explicit select= would
  # silently override the reviewed node shape.
  report "no explicit select="        "$(grep -Eq '^[[:space:]]*#PBS[[:space:]]+-l[[:space:]]+select=' "$pbs" && echo FAIL || echo PASS)"
  report "runtime node-count check"   "$(hasre "$pbs" "(NNODES=${nodes}([;[:space:]]|$)|PBS_NNODES\" = \"?${nodes})")"

  # -- official preparation chain, in order ------------------------------------
  prev=0
  for step in 'decomposePar -constant' 'restore0Dir -processor' \
              'renumberMesh -constant -overwrite -parallel' \
              'potentialFoam -initialiseUBCs -parallel' \
              'applyBoundaryLayer -ybl 0.0450244 -parallel' \
              'simpleFoam -parallel'; do
    line=$(grep -Fn "$step" "$pbs" | head -n 1 | cut -d: -f1)
    if [ -z "$line" ]; then
      report "chain: $step" FAIL
    elif [ "$line" -lt "$prev" ]; then
      report "chain order: $step" FAIL
    else
      report "chain: $step" PASS; prev=$line
    fi
  done

  # -- frozen numerics ---------------------------------------------------------
  report "uses controlDict.noWrite"   "$(has "$pbs" 'controlDict.noWrite')"
  report "uses fvSolution.fixedIter"  "$(has "$pbs" 'fvSolution.fixedIter')"
  report "fvSolution verified by cmp" "$(has "$pbs" 'cmp -s system/fvSolution system/fvSolution.fixedIter')"
  report "ybl value untouched"        "$(has "$pbs" '-ybl 0.0450244')"

  # -- scaling point -----------------------------------------------------------
  report "NRANKS=${ncpus}"            "$(hasre "$pbs" "NRANKS=${ncpus}([;[:space:]]|$)")"
  report "ENDTIME=${endtime}"         "$(hasre "$pbs" "(ENDTIME=${endtime}[;[:space:]]|endTime\[\[:space:\]\]\+${endtime};)")"
  report "decomposition ${hier}"      "$(has "$pbs" "$hier")"
  prod=$(printf '%s' "$hier" | tr -d '()' | awk '{print $1*$2*$3}')
  report "ranks == product (${prod})" "$([ "$prod" = "$ncpus" ] && echo PASS || echo FAIL)"

  # -- evidence integrity ------------------------------------------------------
  report "Cd preserved via EXIT trap" "$(has "$pbs" 'trap preserve_evidence EXIT')"
  report "metric grep cannot abort"   "$(has "$pbs" "time per time step' \"\$EVIDENCE/simpleFoam.log\" | tail -n 1 || true")"
  report "fresh-case isolation"       "$(has "$pbs" 'test ! -e "$CASE"')"
  echo
}

check_one official-gadi-spr/official_baseline_1n.pbs 1 104 190GB  40  '(4 13 2)'
check_one official-gadi-spr/official_baseline_2n.pbs 2 208 380GB  80  '(8 13 2)'
check_one official-gadi-spr/official_baseline_4n.pbs 4 416 760GB 150 '(16 13 2)'

if [ "$rc" -eq 0 ]; then
  echo "OFFICIAL_STATIC_GATE_PASS (1N/2N/4N)"
else
  echo "OFFICIAL_STATIC_GATE_FAIL - do not qsub"
fi
exit "$rc"
