#/bin/bash

# TODO
# * use custom repo for CSCS recipe packages (e.g. OpenMPI 4.1.6)

header() {
    echo ====== $1
}

quiet_clone() {
    local account="$1"
    local repo="$2"
    local branch="$3"
    header "cloning $account/$repo"
    if [ -z "$branch" ]; then
        git clone --quiet git@github.com:$account/$repo.git ${sw_repo}/$repo > /dev/null
    else
        git clone --depth=1 --branch "$branch"  --quiet git@github.com:$account/$repo.git ${sw_repo}/$repo > /dev/null
    fi
    tar czf $repo.tar.gz $repo
}

# SHORT CIRCUIT SO THAT WE DON'T BORK anything
header "do nothing - edit the script to proceed with installation"
#exit

repo_path=$(pwd)/repo
sw_repo=${repo_path}/software
pip_repo=${repo_path}/pip
spack_repo=${repo_path}/spack

etc_path=$(pwd)/etc

penv_path=$(pwd)/.pyenv-bootstrap

# LIST OF PATHS TO DELETE
# create a fresh python venv every time
rm -rf ${penv_path}

header "creating python virtual environment in .pyenv-download"
python3 -m venv ${penv_path}
source ${penv_path}/bin/activate

pip --quiet install pip --upgrade

sleep 1
# rm -rf ${sw_repo}/*
mkdir -p ${sw_repo}
pushd ${sw_repo}

   # git config --global advice.detachedHead false
   # quiet_clone "eth-cscs"        "stackinator" "v3.0"
   # quiet_clone "spack"           "spack"       "v0.20.2"
   # quiet_clone "eth-cscs"        "uenv"
   # quiet_clone "eth-cscs"        "squashfs-mount"
   # quiet_clone "eth-cscs"        "ault-gh"
   # quiet_clone "eth-cscs"        "alps-cluster-config"
   # quiet_clone "bcumming"        "node-burn"
   # quiet_clone "simonpintarelli" "stackinator-mpich-pkgs"
   wget https://github.com/libffi/libffi/archive/refs/tags/v3.3.tar.gz && mv v3.3.tar.gz libffi-3.3.tar.gz
   for pv in "3.6.15" "3.10.12"
   do
       wget https://www.python.org/ftp/python/$pv/Python-$pv.tgz
   done
popd

header "downloading the bootstrap python dependencies"
pip --quiet download --destination-directory ${pip_repo}/bootstrap -r ${etc_path}/bootstrap-requirements.txt
pip --quiet download --destination-directory ${pip_repo}/bootstrap wheel cython

#exit
exit

header "downloaded python packages"
ls ${pip_repo}/bootstrap

wget --quiet https://bootstrap.pypa.io/get-pip.py
mv get-pip.py ${pip_repo}

spack_bootstrap=${spack_repo}/bootstrap
# remove the spack bootstrap path
#rm -rf "${spack_bootstrap}"

spack="${sw_repo}/spack/bin/spack"
header "setting up the spack bootstrap mirror in ${spack_bootstrap}"
header "        using spack: ${spack}"
time ${spack} bootstrap mirror --binary-packages ${spack_bootstrap}

header "setting up the spack mirror"
time ${spack} -C /user-environment/config mirror create -d ${spack_repo}/mirror -f ${etc_path}/spack-mirror-specs.txt
