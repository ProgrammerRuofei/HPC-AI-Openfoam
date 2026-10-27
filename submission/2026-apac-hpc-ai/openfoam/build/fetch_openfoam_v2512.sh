#!/bin/bash
# Fetch ESI OpenFOAM-v2512 and ThirdParty onto scratch (contest version).
# Working directory: any; uses $FOAM_INST_DIR or $HOME/scratch/openfoam-v2512.
# Inputs: network access to dl.openfoam.com.
# Outputs: OpenFOAM-v2512 and ThirdParty-v2512 under that scratch path.
# Assumptions: login node only; do not compile here. Do not fetch the
# occDrivAerStaticMesh competition mesh on the personal account.
# Note: the vendor ships ThirdParty as ThirdParty-v2512.tar.gz (not .tgz).

set -euo pipefail

SRC="${FOAM_INST_DIR:-${HOME}/scratch/openfoam-v2512}"
URL_BASE="https://dl.openfoam.com/source/v2512"
OF_MD5="8a1abe3864851902bb77809efa94ba3e"
TP_MD5="1035605a0a00a47ff4352d03f241db95"

mkdir -p "${SRC}"
cd "${SRC}"

if [[ -d OpenFOAM-v2512 && -d ThirdParty-v2512 ]]; then
    echo "Source already present in ${SRC}"
    exit 0
fi

if [[ ! -f OpenFOAM-v2512.tgz ]]; then
    wget -c "${URL_BASE}/OpenFOAM-v2512.tgz"
fi
echo "${OF_MD5}  OpenFOAM-v2512.tgz" | md5sum -c -

if [[ ! -f ThirdParty-v2512.tar.gz ]]; then
    wget -c "${URL_BASE}/ThirdParty-v2512.tar.gz"
fi
echo "${TP_MD5}  ThirdParty-v2512.tar.gz" | md5sum -c -

if [[ ! -d OpenFOAM-v2512 ]]; then
    tar -xf OpenFOAM-v2512.tgz
fi
if [[ ! -d ThirdParty-v2512 ]]; then
    tar -xf ThirdParty-v2512.tar.gz
fi

test -f OpenFOAM-v2512/Allwmake
test -d ThirdParty-v2512
test -d OpenFOAM-v2512/tutorials/incompressible/simpleFoam/pitzDaily
echo "Fetched OpenFOAM-v2512 into ${SRC}"
