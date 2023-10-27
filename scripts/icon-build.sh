#!/bin/bash

# make sure that the following has been run first
#       uenv view nvidia
# or alternatively at the top of this script
#       source /user-environment/env/nvidia/activate.sh

root_path=$(pwd)
echo == root path ${root_path}

#module use /user-environment/modules

#module load python/3.10.8
#module load nvhpc/23.3
#module load cuda/11.8.0-nvhpc
#module load netcdf-c/4.8.1-nvhpc
#module load netcdf-fortran/4.5.4-nvhpc
#module load cray-mpich-binary/8.1.18.4-nvhpc
#module load eccodes/2.25.0-nvhpc
#module load cmake/3.24.3-gcc

#export BOOST_ROOT=/scratch/e1000/meteoswiss/scratch/bcumming/install/boost

base_path=$(pwd)
etc_path=${base_path}/etc
repo_path=$(pwd)/repo/
build_path=$(pwd)/build/icon
sources_path=${repo_path}/icon

source /user-environment/env/nvidia/activate.sh
source ${repo_path}/software/spack/share/spack/setup-env.sh

rm -rf ${build_path}
mkdir ${build_path}

cd $build_path

spack --version

echo == installing everything in $(pwd)

echo "==       ...  icon4py"
tar xzf ${sources_path}/icon4py.tar.gz
echo "==       ...  gt4py"
tar xzf ${sources_path}/gt4py.tar.gz
echo "==       ...  gridtools4py"
tar xzf ${sources_path}/gridtools.tar.gz

venv_path=$build_path/.venv

echo == venv at $venv_path
echo "==       ...  create venv"
python3 -m venv $venv_path

echo "==       ...  activate venv"
source .venv/bin/activate
echo "==       ...  pip install"
# This env var is referred to inside the requirements.txt file used below
export ICON4PY_SOURCE_PATH="${build_path}/icon4py"
pip install --no-index --find-links=${repo_path}/pip/icon/ -r ${etc_path}/requirements-icon.txt

export NVHPC_CUDA_HOME=$CUDA_HOME

# TODO
export NETCDF_FORTRAN=/mch-environment/v5/linux-sles15-zen3/nvhpc-23.3/netcdf-fortran-4.5.4-npjqpv6kmrzsxgmiypkg6uhnlxqmm3so/
export XML2=/mch-environment/v5/linux-sles15-zen3/gcc-11.3.0/libxml2-2.10.1-b3r4lqh6shko3wnjbzwqlotl6o2kh2jc/

export NETCDFMINFORTRAN=$NETCDF_FORTRAN
export NETCDF=${NETCDF_C_ROOT}

tar xzvf sources/icon-exclaim.tar.gz

tar xzvf sources/json-v3.10.5.tar.gz
mv json-3.10.5  icon-exclaim/

pushd icon-exclaim
    # Build version for debugging
    mkdir build_debug
    pushd build_debug
        NETCDFMINFORTRAN=${NETCDF_FORTRAN} \
        NETCDF=${NETCDF_C_ROOT} \
        XML2_ROOT=${XML2} \
        ECCODES_ROOT=${ECCODES_DIR} \
        LOC_GT4PY=${root_path}/gt4py/ \
        LOC_ICON4PY_ATM_DYN_ICONAM=${root_path}/icon4py/model/atmosphere/dycore/src/icon4py/model/atmosphere/dycore/ \
        LOC_ICON4PY_ADVECTION=${root_path}/icon4py/model/atmosphere/advection/src/icon4py/model/atmosphere/advection/ \
        LOC_ICON4PY_DIFFUSION=${root_path}/icon4py/model/atmosphere/diffusion/src/icon4py/model/atmosphere/diffusion/stencils \
        LOC_ICON4PY_INTERPOLATION=${root_path}/icon4py/model/common/src/icon4py/model/common/interpolation/stencils \
        LOC_ICON4PY_TOOLS=${root_path}/icon4py/tools/src/icon4pytools/ \
        LOC_ICON4PY_BIN=${root_path}/icon4py/.venv/ \
        LOC_GRIDTOOLS=${root_path}/gridtools/ \
        ./../config/cscs/balfrin_nospack.gpu.nvidia --enable-dsl-local --disable-rte-rrtmgp --enable-liskov=verify --disable-liskov-fused

        make -j20
        ./make_runscripts --all
        pushd run
            sbatch exp.mch_ch_r04b09_dsl.run
        popd
    popd

    # Build performant version
    mkdir build
    pushd build
        NETCDFMINFORTRAN=${NETCDF_FORTRAN} \
        NETCDF=${NETCDF_C_ROOT} \
        XML2_ROOT=${XML2} \
        ECCODES_ROOT=${ECCODES_DIR} \
        LOC_GT4PY=${root_path}/gt4py/ \
        LOC_ICON4PY_ATM_DYN_ICONAM=${root_path}/icon4py/model/atmosphere/dycore/src/icon4py/model/atmosphere/dycore/ \
        LOC_ICON4PY_ADVECTION=${root_path}/icon4py/model/atmosphere/advection/src/icon4py/model/atmosphere/advection/ \
        LOC_ICON4PY_DIFFUSION=${root_path}/icon4py/model/atmosphere/diffusion/src/icon4py/model/atmosphere/diffusion/stencils \
        LOC_ICON4PY_INTERPOLATION=${root_path}/icon4py/model/common/src/icon4py/model/common/interpolation/stencils \
        LOC_ICON4PY_TOOLS=${root_path}/icon4py/tools/src/icon4pytools/ \
        LOC_ICON4PY_BIN=${root_path}/icon4py/.venv/ \
        LOC_GRIDTOOLS=${root_path}/gridtools/ \
        ./../config/cscs/balfrin_nospack.gpu.nvidia --enable-dsl-local --disable-rte-rrtmgp --enable-liskov=substitute --disable-liskov-fused

        make -j20 --output-sync
        ./make_runscripts --all
        pushd run
            sbatch exp.mch_ch_r04b09_dsl.run
        popd
    popd
popd

