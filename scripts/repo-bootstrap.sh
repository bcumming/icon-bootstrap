#/bin/bash

# TODO
# * use custom repo for CSCS recipe packages (e.g. OpenMPI 4.1.6)

header() {
    echo
    echo ====== $1
    echo
}

# define this if we want a clean build

export dirty

header "dirty install"

repo_path=$(pwd)/repo
sw_repo=${repo_path}/software
pip_repo=${repo_path}/pip
spack_repo=${repo_path}/spack

etc_path=$(pwd)/etc

penv_path=$(pwd)/.pyenv-bootstrap

# LIST OF PATHS TO DELETE
# create a fresh python venv every time
rm -rf ${penv_path}

# nuke all of the software packages
rm -rf ${sw_repo}/*

header "creating python virtual environment in .pyenv-download"
python3 -m venv ${penv_path}
source ${penv_path}/bin/activate

pip --quiet install pip --upgrade

sleep 1
mkdir -p ${sw_repo}
pushd ${sw_repo}
    header "cloning stackinator"
    git clone --quiet --depth=1 --branch "v3.0" git@github.com:eth-cscs/stackinator.git ${sw_repo}/stackinator
    tar czf stackinator.tar.gz stackinator
    header "cloning spack"
    git clone --quiet --depth=1 --branch "v0.20.2" git@github.com:spack/spack.git ${sw_repo}/spack
    tar czf spack.tar.gz spack
    header "cloning uenv"
    git clone --quiet --depth=1 git@github.com:eth-cscs/uenv.git ${sw_repo}/uenv
    tar czf uenv.tar.gz uenv
    header "cloning squashfs-mount"
    git clone --quiet git@github.com/eth-cscs/squashfs-mount.git ${sw_repo}/squashfs-mount
    tar czf squashfs-mount.tar.gz squashfs-mount
popd

header "downloading the bootstrap python dependencies"
pip --quiet download --destination-directory ${pip_repo}/bootstrap -r ${etc_path}/bootstrap-requirements.txt

header "downloaded python packages"
ls ${pip_repo}/bootstrap

wget --quiet https://bootstrap.pypa.io/get-pip.py
mv get-pip.py ${pip_repo}

spack="${sw_repo}/spack/bin/spack"
spack_bootstrap=${spack_repo}/bootstrap
header "setting up the spack bootstrap mirror in ${spack_bootstrap}"
header "        using spack: ${spack}"
rm -rf "${spack_bootstrap}"
${spack} bootstrap mirror --binary-packages ${spack_bootstrap}

header "setting up the spack mirror"
${spack} mirror create -D -d ${spack_repo}/mirror -f ${etc_path}/spack-mirror-specs.txt
