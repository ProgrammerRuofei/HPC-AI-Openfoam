#!/bin/bash
# Extract official 2026 APAC OpenFOAM metrics from one run's evidence directory.
#
# Primary metric   : "Average wall-clock time per time step" (simpleFoam log line).
# Secondary metrics: ExecutionTime, ClockTime, final Time, prep-chain completion.
# Sanity check     : final Cd from postProcessing/forceCoeffsAll/*/coefficient.dat.
#
# Usage: extract_official_metrics.sh <evidence-dir> [expected-endTime]
# The evidence dir is expected to hold run.log, simpleFoam.log and coefficient.dat.
set -uo pipefail

EV=${1:?usage: extract_official_metrics.sh <evidence-dir> [expected-endTime]}
WANT_END=${2:-}

RUNLOG="$EV/run.log"
SOLVERLOG="$EV/simpleFoam.log"
COEFF="$EV/coefficient.dat"

fail=0
note() { printf '%-42s %s\n' "$1" "$2"; }
check() { # check <label> <ok:0|1> <detail-shown-only-on-failure>
  if [ "$2" -eq 0 ]; then note "$1" "PASS"; else note "$1" "FAIL  $3"; fail=1; fi
}

echo "=== evidence: $EV ==="
[ -f "$SOLVERLOG" ] || { echo "FATAL: missing $SOLVERLOG"; exit 2; }

# ---- 1. Official preparation chain -----------------------------------------
# Each step must show OpenFOAM's normal "End" completion in the captured run log.
echo
echo "-- preparation chain --"
# Each parallel/serial utility writes its own log; completion is OpenFOAM's "End".
for step in 10_decomposePar 20_renumberMesh 30_potentialFoam 40_applyBoundaryLayer; do
  f="$EV/$step.log"
  if [ ! -f "$f" ]; then
    check "$step completed" 1 "log missing"
  elif grep -qa '^End' "$f"; then
    check "$step completed" 0 ""
  else
    check "$step completed" 1 "log present but no End marker"
  fi
done
# restore0Dir is a shell function with no log of its own; it announces itself
# into run.log and must have resolved as a function rather than a command.
if [ -f "$RUNLOG" ]; then
  grep -qa 'Restore 0/ from 0.orig/' "$RUNLOG"
  check "restore0Dir completed" $? "no restore marker in run.log"
  grep -qa 'command not found' "$RUNLOG" && { check "no unresolved commands" 1 "run.log reports command not found"; } || check "no unresolved commands" 0 ""
else
  note "run.log" "MISSING - cannot verify restore0Dir"
  fail=1
fi

# ---- 2. Solver completion ---------------------------------------------------
echo
echo "-- solver completion --"
final_time=$(grep -a '^Time = ' "$SOLVERLOG" | tail -n 1 | awk '{print $3}')
note "final Time reached" "${final_time:-<none>}"
if [ -n "$WANT_END" ]; then
  [ "$final_time" = "$WANT_END" ]
  check "final Time == $WANT_END" $? "got ${final_time:-<none>}"
fi

grep -qa '^End' "$SOLVERLOG"
check "solver printed End" $? ""
grep -qa 'Finalising parallel run' "$SOLVERLOG"
check "parallel run finalised" $? ""

# ---- 3. PRIMARY official metric --------------------------------------------
echo
echo "-- PRIMARY METRIC --"
avg_line=$(grep -a 'Average wall-clock time per time step' "$SOLVERLOG" | tail -n 1)
if [ -n "$avg_line" ]; then
  # Anchor on the '=' or ':' separator so trailing qualifier text on the line
  # (e.g. "(from step 2)") can never be mistaken for the value itself.
  avg=$(printf '%s\n' "$avg_line" | sed -nE 's/.*[=:][[:space:]]*([0-9]+\.?[0-9]*([eE][-+]?[0-9]+)?).*/\1/p')
  note "Average wall-clock time per step" "$avg   (raw: $avg_line)"
else
  note "Average wall-clock time per step" "NOT FOUND - metric line absent"
  fail=1
fi

# ---- 4. Secondary metrics ---------------------------------------------------
echo
echo "-- secondary metrics --"
tail_time=$(grep -a 'ExecutionTime = ' "$SOLVERLOG" | tail -n 1)
exec_t=$(printf '%s\n' "$tail_time" | sed -nE 's/.*ExecutionTime = ([0-9.]+).*/\1/p')
clock_t=$(printf '%s\n' "$tail_time" | sed -nE 's/.*ClockTime = ([0-9.]+).*/\1/p')
note "ExecutionTime (s)" "${exec_t:-<none>}"
note "ClockTime (s)"     "${clock_t:-<none>}"

# ---- 5. Cd sanity check -----------------------------------------------------
# Official expectation: 40 steps ~0.43, 80 steps ~0.34, 150 steps ~0.28-0.29.
echo
echo "-- Cd sanity --"
if [ -f "$COEFF" ]; then
  # Locate the Cd column from the last '#'-prefixed header line rather than
  # assuming a fixed column order across OpenFOAM versions.
  cd_val=$(awk '
    /^#/ { for (i = 2; i <= NF; i++) if ($i == "Cd") col = i - 1; next }
    NF && col { last = $col }
    END { if (col) print last }
  ' "$COEFF")
  if [ -n "$cd_val" ]; then
    note "final Cd" "$cd_val"
    case "$WANT_END" in
      40)  lo=0.40; hi=0.46 ;;
      80)  lo=0.31; hi=0.37 ;;
      150) lo=0.27; hi=0.30 ;;
      *)   lo=""; hi="" ;;
    esac
    if [ -n "$lo" ]; then
      awk -v v="$cd_val" -v lo="$lo" -v hi="$hi" 'BEGIN { exit !(v >= lo && v <= hi) }'
      check "Cd within [$lo, $hi] for endTime=$WANT_END" $? "got $cd_val"
    fi
  else
    note "final Cd" "NOT PARSED - no Cd column in header"
    fail=1
  fi
else
  note "coefficient.dat" "MISSING"
  fail=1
fi

echo
if [ "$fail" -eq 0 ]; then
  echo "RESULT: OFFICIAL_RUN_VALID"
else
  echo "RESULT: OFFICIAL_RUN_SUSPECT - do not record as a valid official baseline"
fi
exit "$fail"
