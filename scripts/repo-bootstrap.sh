#/bin/bash

header() {
    echo
    echo ====== $1
    echo
}

rm -rf repo
repo_path=$(pwd)/repo
sw_repo=${repo_path}/software
pip_repo=${repo_path}/pip
spack_repo=${repo_path}/spack

etc_path=$(pwd)/pip

penv_path=$(pwd)/.pyenv-bootstrap
rm -rf ${penv_path}

header "creating python virtual environment in .pyenv-download"
python3 -m venv ${penv_path}
source ${penv_path}/bin/activate

pip --quiet install pip --upgrade

mkdir -p ${sw_repo}
header "cloning stackinator"
git clone --quiet --depth=1 --branch "v3.0" git@github.com:eth-cscs/stackinator.git ${sw_repo}/stackinator
header "cloning spack"
git clone --quiet --depth=1 --branch "v0.20.2" git@github.com:spack/spack.git ${sw_repo}/spack
header "cloning uenv"
git clone --quiet --depth=1 git@github.com:eth-cscs/uenv.git ${sw_repo}/uenv

header "downloading the bootstrap python dependencies"
pip --quiet download --destination-directory ${pip_repo}/bootstrap -r etc/bootstrap-requirements.txt

header "downloaded python packages"
ls ${pip_repo}/bootstrap

wget --quiet https://bootstrap.pypa.io/get-pip.py
mv get-pip.py ${pip_repo}

spack="${sw_repo}/spack/bin/spack"
header "setting up the spack bootstrap mirror"
${spack} bootstrap mirror --binary-packages ${spack_repo}/bootstrap

header "setting up the spack mirror"
${spack} spack mirror create -D -d ${spack_repo}/mirror -f ${etc_path}/spack-mirror-specs.txt
