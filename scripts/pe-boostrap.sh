#!/bin/bash

header() {
    echo ====== $1
}


pyenv_path="$(pwd)/.pyenv-bootstrap"
rm -rf $pyenv_path
header "creating python environment $pyenv_path"
python3 -m venv $pyenv_path
source $pyenv_path/bin/activate

export stackinator_path="$PWD/software/stackinator"
export spack_path="$PWD/software/spack"
# this is acheived using "export PATH" below
#source "${spack_path}/share/spack/setup-env.sh"

# bootstrap python packages required by stackinator
header "pip installing the python packages in $(pwd)/repos/bootstrap-requirements.txt"
pip --quiet install --no-index --find-links=./repos/bootstrap-python -r ./repos/bootstrap-requirements.txt
pip list

export PATH="$stackinator_path/bin:$PATH"
export PATH="$spack_path/bin:$PATH"

# setting up spack bootstrap
spack --version
spack_bootstrap="$(pwd)/repos/bootstrap-spack"
spack bootstrap add --trust local-sources $spack_bootstrap/metadata/sources
spack bootstrap add --trust local-binaries $spack_bootstrap/metadata/binaries

spack bootstrap status

# setting up spack mirror
#spack mirror create -D -d $(pwd)/mirror -f /home/bcumming/test/spack-env/spack-packages.txt
