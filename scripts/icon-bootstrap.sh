#!/bin/bash

#
# requires that the target uenv has been mounted
#

header() {
    echo ====== $1
}

header "sourcing uenv view"
source /user-environment/env/nvidia/activate.sh

repo_path=$(pwd)/repo
etc_path=$(pwd)/etc
pyenv_path="$(pwd)/.pyenv-icon-bootstrap"

# path where source packages and tar balls used by icon and deps will be downloaded
icon_repo_path=${repo_path}/icon

# path where pip packages used by icon will be downloaded
pip_repo=$repo_path/pip/icon

rm -rf ${pyenv_path}
rm -rf ${pip_repo}
rm -rf ${icon_repo_path}

mkdir -p ${icon_repo_path}
pushd ${icon_repo_path}

    header "cloning and compressing icon-exclaim"
    git clone --quiet -b grace-hopper git@github.com:C2SM/icon-exclaim.git
    (cd icon-exclaim; git submodule update --quiet --init --recursive)
    tar czf icon-exclaim.tar.gz icon-exclaim

    header "cloning and compressing icon4py"
    git clone --quiet git@github.com:C2SM/icon4py.git
    tar czf icon4py.tar.gz icon4py

    header "cloning and compressing gt4py"
    git clone --quiet git@github.com:GridTools/gt4py.git
    tar czf gt4py.tar.gz gt4py

    header "cloning and compressing gridtools"
    git clone --quiet git@github.com:GridTools/gridtools.git
    tar czf gridtools.tar.gz gridtools

    header "downloading nlohmann"
    wget https://github.com/nlohmann/json/archive/refs/tags/v3.10.5.tar.gz -O json-v3.10.5.tar.gz

    header "cleaning up"
    rm -rf icon-exclaim icon4py gt4py gridtools
popd

#
# build repository of PIP artifacts
#

# pick the correct version of pip
header "creating venv in $pyenv_path"
which python3
python3 -m venv $pyenv_path

header "activating venv"
source $pyenv_path/bin/activate
python --version

rm -rf tmp
mkdir -p tmp
header "downloading pip packages"
icon_base_req="${etc_path}/requirements-icon-base.txt"
(
cd tmp;
tar -xzf ${icon_repo_path}/icon4py.tar.gz;
cd icon4py;
header "  dry-run"
pip install --dry-run --ignore-installed -r requirements.txt > pipreport 2>&1
grep ^"Would install" pipreport | cut -d" " -f3- | tr " " "\n" > "requirements-icon-raw.txt"
cat requirements-icon-raw.txt | sed -r 's/(.*)-/\1 == /g' > "${icon_base_req}"
header "  packages..."
cat "${icon_base_req}"
header "  download pip packages by the book"
pip --quiet download --destination-directory ${pip_repo} -r ./requirements.txt
pip --quiet download --destination-directory ${pip_repo} wheel cython
#header "  download pip packages from the inferred requirements"
#pip --quiet download --destination-directory ${pip_repo}/foo -r "${etc_path}/requirements-icon.txt"
)

echo "CHECK THE FILE IN ${etc_path}/requirements-icon-base.txt"
# TODO: editing steps (carry out now, or during installation of ICON?)
#       comment out all lines that start with "^icon4py" with #
#       hard-code full path to the icon4py paths
#
#       ${ICON4PY_SOURCE_PATH}/model/atmosphere/dycore
#       ${ICON4PY_SOURCE_PATH}/model/atmosphere/diffusion
#       ${ICON4PY_SOURCE_PATH}/model/atmosphere/advection
#       ${ICON4PY_SOURCE_PATH}/model/common
#       ${ICON4PY_SOURCE_PATH}/model/driver
#       ${ICON4PY_SOURCE_PATH}/tools
#
#       Good lord, does this work if these include relative backlinks??



