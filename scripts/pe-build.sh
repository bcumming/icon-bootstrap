#!/bin/bash

header() {
    echo ====== $1
}

repo_path="$(pwd)/repo"
sw_path="$repo_path/software"
etc_path="$(pwd)/etc"
stack_path="$(pwd)/stack"
work_path="$(pwd)/work"

pyenv_path="$(pwd)/.pyenv-stackinator"

rm -rf $pyenv_path
header "creating python environment $pyenv_path"
python3 -m venv $pyenv_path
source $pyenv_path/bin/activate

export stackinator_path="$sw_path/stackinator"
export spack_path="$sw_path/spack"

# this is acheived using "export PATH" below
#source "${spack_path}/share/spack/setup-env.sh"

# bootstrap python packages required by stackinator
req=$etc_path/bootstrap-requirements.txt
header "pip installing the python packages defined in $req"
pip --quiet install --no-index --find-links=$repo_path/pip/bootstrap -r $req
pip list

export PATH="$stackinator_path/bin:$PATH"
export PATH="$spack_path/bin:$PATH"

header "pip installing the python packages defined in $req"

# setting up spack bootstrap
spack --version
spack_bootstrap="$repo_path/spack/bootstrap"
spack bootstrap add --trust local-sources $spack_bootstrap/metadata/sources
spack bootstrap add --trust local-binaries $spack_bootstrap/metadata/binaries

spack bootstrap status

# stack configure
config_path=$stack_path/ault
recipe_path=$stack_path/recipes/icon
build_path=$work_path/build_icon
cache_path=$work_path/build-cache

header "work path        $work_path"
header "stack build path $build_path"

rm -rf $build_path
mkdir -p $work_path
mkdir -p $cache_path
cp $etc_path/push-key.gpg $cache_path

echo stack-config -b $build_path -r $recipe_path -s $config_path -m /user-environment
stack-config -b $build_path -r $recipe_path -s $config_path -m /user-environment
