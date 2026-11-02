#!/bin/bash
# One arm of the authorized four-node rank/NUMA pair; invoked only by wrapper PBS.
# Processor data stays in node-local JOBFS to preserve pm78 scratch inodes.
set -euo pipefail

STACK_ROOT=/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010
OF_ROOT=/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010-of2512
SOURCE_CASE=/scratch/pm78/kj7183/openfoam_cpu/case/occDrivAerStaticMesh
GCC_ARCHIVE="$STACK_ROOT/runtime-archive/gcc-16.2.0.181342083.gadi-pbs.tar.gz"
MPI_ARCHIVE="$STACK_ROOT/runtime-archive/openmpi-5.0.10.181346004.gadi-pbs.tar.gz"
OF_ARCHIVE="$OF_ROOT/runtime-archive/gadi-icx20253-ompi5010-of2512.181392981.gadi-pbs.tar.gz"
GCC_SHA=1149c0d97412ae3741cc18d60f233cdd3dd5e33bc92c55c59db2dd8cf535b714
MPI_SHA=8ac121e4f64eb329dc33cd2cc8229dc9f655064a757cbcaa36af962b21619fc6
OF_SHA=a832416d47a1a26cc2a02ef0c69eb09dbf142043d619ed22ece37d96b029dfcd
BIN_SHA=7cc4af8c576eba1e97ba16a767fca5843293c391b71a3904a596b3981d2913e4
case "${NUMA_ARM:?wrapper must set control or candidate}" in control|candidate) ;; *) exit 2;; esac
NRANKS=416
PAIR_ROOT="$OF_ROOT/rank-numa-pair-4n-v1/${PBS_JOBID:?}"
HELPER="$PBS_O_WORKDIR/experiments/gadi-icx20253-rank-numa/rank_numa_4n.py"
MAP="$PBS_O_WORKDIR/experiments/gadi-icx20253-rank-numa/candidate-map-v1.csv"
PROBE_SOURCE="$PBS_O_WORKDIR/experiments/gadi-icx20253-rank-numa/rank_numa_probe_4n.c"
RUN_ROOT="$PAIR_ROOT/$NUMA_ARM"
EVIDENCE="$RUN_ROOT/evidence"
SHARED_CASE="$RUN_ROOT/case"
LOCAL_ROOT="${PBS_JOBFS:?}/of2512-icx20253-ranknuma4n-v1-${PBS_JOBID}-${NUMA_ARM}"
LOCAL_CASE="$LOCAL_ROOT/case"
GCC_PREFIX="$LOCAL_ROOT/gcc-16.2.0"
MPI_PREFIX="$LOCAL_ROOT/openmpi-5.0.10"
FOAM_ROOT="$LOCAL_ROOT/OpenFOAM-v2512"
STAGE_RUNTIME="$PBS_O_WORKDIR/builds/build-scripts/gadi-icx20253-ompi5010/stage_4n_runtime_node.sh"
STAGE_PROCESSORS="$PBS_O_WORKDIR/builds/build-scripts/gadi-icx20253-ompi5010/stage_4n_processors_node.sh"

test -f "$HELPER"
for key in LD_PRELOAD OMPI_MCA_coll OMPI_MCA_pml OMPI_MCA_coll_hcoll_enable OMPI_MCA_coll_ucc_enable; do test -z "${!key:-}"; done
test "${PBS_NNODES:?}" -eq 4; test "${PBS_NCPUS:?}" -eq "$NRANKS"
test ! -e "$RUN_ROOT"; test -f "$STAGE_RUNTIME"; test -f "$STAGE_PROCESSORS"
mkdir -p "$EVIDENCE" "$SHARED_CASE" "$RUN_ROOT/stage"
exec > >(tee "$EVIDENCE/run.log") 2>&1
ARM_COMPLETE=0
preserve() {
    rc=$?; trap - EXIT; set +e
    if (( rc == 0 && ARM_COMPLETE != 1 )); then rc=1; fi
    c=$(find "$SHARED_CASE/postProcessing/forceCoeffsAll" -name coefficient.dat -type f 2>/dev/null | head -n 1)
    test -n "$c" && cp -p "$c" "$EVIDENCE/coefficient.dat"
    printf 'script_exit_rc=%s\n' "$rc" > "$EVIDENCE/exit-status.txt"
    exit "$rc"
}
trap preserve EXIT
trap 'exit 143' TERM
trap 'exit 130' INT
trap 'exit 129' HUP

printf 'pbs_jobid=%s\nperformance_screen=uninstrumented_rank_numa_pair\nverification=rank_numa_pair_150step\nstack=icx2025.3.2-ompi5.0.10-openfoamv2512\ndecomposition=scotch\n' "$PBS_JOBID" | tee "$EVIDENCE/provenance.txt"
sort -u "$PBS_NODEFILE" | tee "$EVIDENCE/nodes.txt"
test "$(sort -u "$PBS_NODEFILE" | wc -l)" -eq 4
test "$(awk '{c[$0]++} END {for (h in c) print c[h]}' "$PBS_NODEFILE" | sort -u)" = 104
mapfile -t HOSTS < <(sed -n '1p;105p;209p;313p' "$PBS_NODEFILE")
test "${#HOSTS[@]}" -eq 4
test "$(printf '%s\n' "${HOSTS[@]}" | sort -u | wc -l)" -eq 4
lscpu | grep -E 'Model name|Socket|Core|Thread|NUMA' | tee "$EVIDENCE/lscpu.txt"
grep -Fq 'Xeon(R) Platinum 8470Q' "$EVIDENCE/lscpu.txt"
module purge; module load intel-compiler-llvm/2025.3.2 ucx/1.18.1 ucc/1.4.4
module list 2>&1 | tee "$EVIDENCE/modules.txt"
test "${UCX_ROOT:?}" = /apps/ucx/1.18.1
test "${UCC_ROOT:?}" = /apps/ucc/1.4.4

cat > "$EVIDENCE/expected-source.sha256" <<EOF
2a02ec456ce880b2242d566da6c5b28fae1aa99218169260030cd53f5a662ec3  $SOURCE_CASE/Allrun.gadi
1da44731f5f723c1b8471bee6c6186c6f402f63154f84cacd26bf27e30e6a6c6  $SOURCE_CASE/system/include/caseDefinition
ce4ec0f52bcc88eea8402b454940dc5aad1f31dea6441e7d98413b651427ef06  $SOURCE_CASE/system/controlDict.noWrite
064bb50455d37a7edd2c0fb24bbe30baaf851623f0250d550450c10e407889b3  $SOURCE_CASE/system/fvSchemes
5e1db8548ee82c44f8fa3377a80971af2b5aabb95b3ee7efcd8b723c5dcab1ba  $SOURCE_CASE/system/fvSolution
5e1db8548ee82c44f8fa3377a80971af2b5aabb95b3ee7efcd8b723c5dcab1ba  $SOURCE_CASE/system/fvSolution.fixedIter
0a0e5d072527bc1e67e5bc505da30bec0abebc67262aa47ecaece4d13b2ece08  $SOURCE_CASE/system/FOwallClockTimeStatistics
EOF
sha256sum -c "$EVIDENCE/expected-source.sha256"
printf '%s  %s\n' "$GCC_SHA" "$GCC_ARCHIVE" | sha256sum -c -
printf '%s  %s\n' "$MPI_SHA" "$MPI_ARCHIVE" | sha256sum -c -
printf '%s  %s\n' "$OF_SHA" "$OF_ARCHIVE" | sha256sum -c -

# pbsdsh task indices 0,104,208,312 select one task on each SPR node.
for idx in 0 104 208 312; do
    marker="$EVIDENCE/stage-runtime-$idx.txt"
    /opt/pbs/default/bin/pbsdsh -n "$idx" -s -- /bin/bash "$STAGE_RUNTIME" "$LOCAL_ROOT" "$GCC_ARCHIVE" "$MPI_ARCHIVE" "$OF_ARCHIVE" "$GCC_SHA" "$MPI_SHA" "$OF_SHA" "$marker"
    grep -Fq "STAGE_4N_RUNTIME_PASS host=${HOSTS[$((idx / 104))]} " "$marker"
done
test "$(grep -h STAGE_4N_RUNTIME_PASS "$EVIDENCE"/stage-runtime-*.txt | wc -l)" -eq 4
export OPAL_PREFIX="$MPI_PREFIX" PMIX_PREFIX="$MPI_PREFIX" PRTE_PREFIX="$MPI_PREFIX"
export OMPI_CC=icx OMPI_CXX=icpx
export PATH="$MPI_PREFIX/bin:$GCC_PREFIX/bin:$PATH"
export LD_LIBRARY_PATH="$MPI_PREFIX/lib:$GCC_PREFIX/lib64:/opt/pbs/default/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
icx --version | head -n 1 | grep -F '2025.3.2'
mpirun --version | head -n 1 | grep -Fx 'mpirun (Open MPI) 5.0.10'
mpicc --showme:command | grep -Fx icx
mpicxx --showme:command | grep -Fx icpx
BIN="$FOAM_ROOT/platforms/linux64IcxDPInt32Opt/bin/simpleFoam"
printf '%s  %s\n' "$BIN_SHA" "$BIN" | sha256sum -c -
set +u; . "$FOAM_ROOT/etc/bashrc" WM_COMPILER=Icx WM_MPLIB=SYSTEMOPENMPI WM_COMPILE_OPTION=Opt; set -u
test "$WM_PROJECT_DIR" = "$FOAM_ROOT"; test "$WM_OPTIONS" = linux64IcxDPInt32Opt
ldd "$BIN" | tee "$EVIDENCE/simpleFoam.ldd"
! grep -Fq 'not found' "$EVIDENCE/simpleFoam.ldd"
grep -F "libmpi.so.40 => $MPI_PREFIX/lib/" "$EVIDENCE/simpleFoam.ldd"

# Measure every node's topology and current logical-core mapping before decomposition.
for idx in 0 104 208 312; do
    /opt/pbs/default/bin/pbsdsh -n "$idx" -s -- /usr/bin/lscpu > "$EVIDENCE/lscpu-$idx.txt"
    grep -Fq 'Xeon(R) Platinum 8470Q' "$EVIDENCE/lscpu-$idx.txt"
done
mkdir "$EVIDENCE/baseline"
timeout -k 10s 180s mpirun --prefix "$MPI_PREFIX" --map-by ppr:104:node --bind-to core --report-bindings --mca pml ucx -np 416 python3 "$HELPER" record "$EVIDENCE/baseline" > "$EVIDENCE/baseline.stdout" 2> "$EVIDENCE/baseline.bindings.txt"
python3 "$HELPER" prepare "$EVIDENCE/baseline" "$MAP" "$EVIDENCE/baseline.bindings.txt" > "$EVIDENCE/rankfile-preparation.json"
PAREX=(mpirun --prefix "$MPI_PREFIX" --map-by "rankfile:file=$EVIDENCE/$NUMA_ARM.rankfile" --bind-to core --mca pml ucx -np 416)
mkdir "$EVIDENCE/placement"
timeout -k 10s 180s "${PAREX[@]}" --report-bindings python3 "$HELPER" record "$EVIDENCE/placement" > "$EVIDENCE/placement.stdout" 2> "$EVIDENCE/placement.bindings.txt"
python3 "$HELPER" check "$EVIDENCE/baseline" "$EVIDENCE/placement" "$MAP" "$NUMA_ARM" > "$EVIDENCE/placement-summary.json"
# Dedicated pre-solver MPI probe; never preload instrumentation into simpleFoam.
# Keep executable in shared job evidence so all four nodes see the same file.
timeout -k 5s 60s mpicc "$PROBE_SOURCE" -ldl -o "$EVIDENCE/mpi-placement-probe"
ldd "$EVIDENCE/mpi-placement-probe" > "$EVIDENCE/probe.ldd"
grep -F "libmpi.so.40 => $MPI_PREFIX/lib/" "$EVIDENCE/probe.ldd"
! grep -Fq 'not found' "$EVIDENCE/probe.ldd"
mkdir "$EVIDENCE/mpi-runtime"
timeout -k 10s 180s "${PAREX[@]}" --mca coll_base_verbose 30 "$EVIDENCE/mpi-placement-probe" "$EVIDENCE/mpi-runtime" > "$EVIDENCE/mpi-runtime.stdout" 2> "$EVIDENCE/mpi-runtime.collectives.txt"
python3 "$HELPER" mpi "$EVIDENCE/placement" "$EVIDENCE/mpi-runtime" > "$EVIDENCE/mpi-runtime-summary.json"
(cd "$SOURCE_CASE" && sha256sum constant/polyMesh/{faces,owner,neighbour,points,boundary}) > "$EVIDENCE/source-mesh.sha256"
printf 'arm=%s\nsteps=150\nranks=416\n' "$NUMA_ARM" >> "$EVIDENCE/provenance.txt"
mkdir "$LOCAL_CASE"
cp -a "$SOURCE_CASE/0.orig" "$SOURCE_CASE/constant" "$SOURCE_CASE/system" "$LOCAL_CASE/"
for part in faces owner neighbour points boundary; do
    cmp -s "$SOURCE_CASE/constant/polyMesh/$part" "$LOCAL_CASE/constant/polyMesh/$part"
done
cd "$LOCAL_CASE"
sha256sum -c "$EVIDENCE/source-mesh.sha256" > "$EVIDENCE/mesh-check.txt"
cp system/controlDict.noWrite system/controlDict
cp system/fvSolution.fixedIter system/fvSolution
sed -i -E 's/^([[:space:]]*nCores[[:space:]]+)[0-9]+;/\1416;/' system/include/caseDefinition
sed -i -E 's/^([[:space:]]*decompositionMethod[[:space:]]+)[a-z]+;/\1scotch;/' system/include/caseDefinition
grep -Eq '^[[:space:]]*nCores[[:space:]]+416;' system/include/caseDefinition
grep -Eq '^[[:space:]]*decompositionMethod[[:space:]]+scotch;' system/include/caseDefinition
grep -Eq '^[[:space:]]*endTime[[:space:]]+150;' system/controlDict
cmp -s system/fvSolution system/fvSolution.fixedIter
sha256sum system/fvSchemes system/fvSolution system/controlDict.noWrite | tee "$EVIDENCE/case-inputs.sha256"
set +u; . "$FOAM_ROOT/bin/tools/RunFunctions"; set -u
type restore0Dir | head -n 1
decomposePar -constant > "$EVIDENCE/10_decomposePar.log" 2>&1
grep -Fq 'Decomposition method scotch' "$EVIDENCE/10_decomposePar.log"
grep -Eq '^End$' "$EVIDENCE/10_decomposePar.log"
python3 - "$EVIDENCE/10_decomposePar.log" "$EVIDENCE/partition-identity.txt" <<'PYGEOMETRY'
import re,sys,hashlib,json
from pathlib import Path
keep=[s.strip() for s in Path(sys.argv[1]).read_text().splitlines() if re.match(r'^Processor \d+$',s) or re.match(r'\s+Number of (cells|points|faces shared with processor|processor patches|processor faces|boundary faces)',s)]
h=hashlib.sha256(json.dumps(keep,separators=(',',':')).encode()).hexdigest()
Path(sys.argv[2]).write_text(h+'\n')
assert h=='6c3d197ff7f601a68ed937fe736b99f9e2c280392cd802a3895a250b46c724b5', 'partition no longer matches candidate design graph'
PYGEOMETRY
restore0Dir -processor
test "$(find . -mindepth 1 -maxdepth 1 -type d -name 'processor*' | wc -l)" -eq 416

# Pack four node ranges as tar files: scratch gains four inodes instead of
# thousands of uncollated processor files. Each node sees the same JOBFS path.
for first in 0 104 208 312; do
    last=$((first + 103))
    dirs=(); for n in $(seq "$first" "$last"); do dirs+=("processor$n"); done
    tar -cf "$RUN_ROOT/stage/processors-$first-$last.tar" "${dirs[@]}"
done
for first in 104 208 312; do
    last=$((first + 103)); idx=$first
    marker="$EVIDENCE/stage-processors-$idx.txt"
    /opt/pbs/default/bin/pbsdsh -n "$idx" -s -- /bin/bash "$STAGE_PROCESSORS" "$LOCAL_CASE" "$RUN_ROOT/stage/processors-$first-$last.tar" "$first" "$last" "$marker"
    grep -Fq "STAGE_4N_PROCESSORS_PASS host=${HOSTS[$((idx / 104))]} " "$marker"
done

# Shared dictionaries and dynamicCode live on scratch; processor symlinks
# resolve to each node's local JOBFS. No source or earlier case is modified.
cp -a "$SOURCE_CASE/0.orig" "$LOCAL_CASE/system" "$SHARED_CASE/"
# Global constant is read-only in the parallel chain; reference the existing master.
# Mutable processor meshes are independent node-local copies.
ln -s "$SOURCE_CASE/constant" "$SHARED_CASE/constant"
for part in faces owner neighbour points boundary; do
    cmp -s "$SOURCE_CASE/constant/polyMesh/$part" "$SHARED_CASE/constant/polyMesh/$part"
done
for n in $(seq 0 415); do ln -s "$LOCAL_CASE/processor$n" "$SHARED_CASE/processor$n"; done
test "$(find "$SHARED_CASE" -mindepth 1 -maxdepth 1 -type l -name 'processor*' | wc -l)" -eq 416
cmp -s "$SHARED_CASE/system/fvSchemes" "$SOURCE_CASE/system/fvSchemes"
cmp -s "$SHARED_CASE/system/fvSolution" "$SOURCE_CASE/system/fvSolution.fixedIter"

PAREX=(mpirun --prefix "$MPI_PREFIX" --map-by "rankfile:file=$EVIDENCE/$NUMA_ARM.rankfile" --bind-to core --mca pml ucx -np 416)
"${PAREX[@]}" /bin/bash -c 'printf "%s %s\n" "${OMPI_COMM_WORLD_RANK:?}" "$(hostname)"' > "$EVIDENCE/rank-host-map.txt"
awk -v a="${HOSTS[0]}" -v b="${HOSTS[1]}" -v c="${HOSTS[2]}" -v d="${HOSTS[3]}" '
    { expected=($1<104?a:($1<208?b:($1<312?c:d))); if ($2!=expected || seen[$1]++) bad=1 }
    END { if (NR!=416 || bad) exit 1 }
' "$EVIDENCE/rank-host-map.txt"
cd "$SHARED_CASE"
"${PAREX[@]}" renumberMesh -constant -overwrite -parallel > "$EVIDENCE/20_renumberMesh.log" 2>&1
"${PAREX[@]}" potentialFoam -initialiseUBCs -parallel > "$EVIDENCE/30_potentialFoam.log" 2>&1
"${PAREX[@]}" applyBoundaryLayer -ybl 0.0450244 -parallel > "$EVIDENCE/40_applyBoundaryLayer.log" 2>&1
mkdir "$EVIDENCE/solver-affinity"
"${PAREX[@]}" --report-bindings python3 "$HELPER" record "$EVIDENCE/solver-affinity" "$BIN" -parallel > "$EVIDENCE/simpleFoam.log" 2>&1
python3 "$HELPER" check "$EVIDENCE/baseline" "$EVIDENCE/solver-affinity" "$MAP" "$NUMA_ARM" > "$EVIDENCE/solver-affinity-summary.json"
for step in 10_decomposePar 20_renumberMesh 30_potentialFoam 40_applyBoundaryLayer; do
    grep -aEq '^End$' "$EVIDENCE/$step.log"
done
grep -aEq '^Time = 150[[:space:]]*$' "$EVIDENCE/simpleFoam.log"
grep -aFq 'Finalising parallel run' "$EVIDENCE/simpleFoam.log"
grep -aEq '^End$' "$EVIDENCE/simpleFoam.log"
grep -a 'Average wall-clock time per time step' "$EVIDENCE/simpleFoam.log" | tail -n 1 | tee "$EVIDENCE/avg-step-time.txt"
grep -aE 'ExecutionTime|ClockTime' "$EVIDENCE/simpleFoam.log" | tail -n 1 | tee "$EVIDENCE/clocktime.txt"
coefficient=$(find "$SHARED_CASE/postProcessing/forceCoeffsAll" -name coefficient.dat -type f | head -n 1)
test -s "$coefficient"
cp -p "$coefficient" "$EVIDENCE/coefficient.dat"
cd_value=$(awk '/^#/ { for (i=2;i<=NF;i++) if ($i=="Cd") col=i-1; next } NF && col { last=$col } END { if (col) print last }' "$EVIDENCE/coefficient.dat")
test -n "$cd_value"
awk -v v="$cd_value" 'BEGIN { exit !(v>=0.27 && v<=0.30) }'
printf 'final_Cd=%s\n' "$cd_value" | tee "$EVIDENCE/final-Cd.txt"
python3 - "$EVIDENCE/simpleFoam.log" <<'PYARM'
import re,sys,math
s=open(sys.argv[1]).read()
assert [float(x) for x in re.findall(r'^Time = ([0-9.]+)\s*$',s,re.M)] == list(range(1,151))
t=float(re.findall(r'Average wall-clock time per time step\s*=\s*([0-9.eE+-]+)',s)[-1])
assert math.isfinite(t) and t>0
PYARM
(cd "$SOURCE_CASE" && sha256sum -c "$EVIDENCE/source-mesh.sha256") > "$EVIDENCE/master-mesh-after.txt"
echo "ICX20253_OMPI5010_RANK_NUMA_4N_150STEP_${NUMA_ARM}_V1_PASS"
ARM_COMPLETE=1
