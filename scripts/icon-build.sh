#!/bin/bash

# make sure that the following has been run first
#       uenv view nvidia
# or alternatively at the top of this script
#       source /user-environment/env/nvidia/activate.sh

spack_prefix() {
    path=$(spack -C /user-environment/config find --format '{prefix}' "$1")
    echo $path
}

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
export etc_path=${base_path}/etc
export repo_path=$(pwd)/repo/
export build_path=$(pwd)/build/icon
export sources_path=${repo_path}/icon
export spack_path=${repo_path}/software/spack
export uenv_view_path=/user-environment/env/nvidia

source ${uenv_view_path}/activate.sh
export PATH=${spack_path}/bin:$PATH

rm -rf ${build_path}
mkdir ${build_path}

cd $build_path

spack --version

echo == unpacking everything in ${build_path}

echo "==       ...  icon4py"
tar xzf ${sources_path}/icon4py.tar.gz
echo "==       ...  gt4py"
tar xzf ${sources_path}/gt4py.tar.gz
echo "==       ...  gridtools4py"
tar xzf ${sources_path}/gridtools.tar.gz
echo "==       ...  icon-exclaim"
tar xzf ${sources_path}/icon-exclaim.tar.gz
echo "==       ...  nlohmann json"
tar xzf ${sources_path}/json-v3.10.5.tar.gz
mv json-3.10.5  icon-exclaim/

venv_path=$build_path/.venv

echo == venv at $venv_path
echo "==       ...  create venv"
python3 -m venv $venv_path

echo "==       ...  activate venv"
source .venv/bin/activate
echo "==       ...  pip install"

# This env var is referred to inside the requirements.txt file used below
export ICON4PY_SOURCE_PATH="${build_path}/icon4py"
pip --quiet install --no-index --find-links=${repo_path}/pip/icon/ -r ${etc_path}/requirements-icon.txt

export NVHPC_CUDA_HOME=$CUDA_HOME

export NETCDF_FORTRAN=${uenv_view_path}
export XML2=${uenv_view_path}
export NETCDFMINFORTRAN=${uenv_view_path}
export NETCDF=${uenv_view_path}

pushd icon-exclaim
    # Build production/performance version
    echo "=="
    echo "== production build: $(pwd)/build"
    echo "=="
    mkdir build
    pushd build
        cp ${etc_path}/icon-configure .

        NETCDFMINFORTRAN=${uenv_view_path} \
        NETCDF=${uenv_view_path} \
        XML2_ROOT=${uenv_view_path} \
        ECCODES_ROOT=${uenv_view_path} \
        LOC_GT4PY=${build_path}/gt4py/ \
        LOC_ICON4PY_ATM_DYN_ICONAM=${build_path}/icon4py/model/atmosphere/dycore/src/icon4py/model/atmosphere/dycore/ \
        LOC_ICON4PY_ADVECTION=${build_path}/icon4py/model/atmosphere/advection/src/icon4py/model/atmosphere/advection/ \
        LOC_ICON4PY_DIFFUSION=${build_path}/icon4py/model/atmosphere/diffusion/src/icon4py/model/atmosphere/diffusion/stencils \
        LOC_ICON4PY_INTERPOLATION=${build_path}/icon4py/model/common/src/icon4py/model/common/interpolation/stencils \
        LOC_ICON4PY_TOOLS=${build_path}/icon4py/tools/src/icon4pytools/ \
        LOC_ICON4PY_BIN=${venv_path} \
        LOC_GRIDTOOLS=${build_path}/gridtools/ \
        ./icon-configure --enable-dsl-local --disable-rte-rrtmgp --enable-liskov=substitute --disable-liskov-fused

        #./../config/cscs/balfrin_nospack.gpu.nvidia --enable-dsl-local --disable-rte-rrtmgp --enable-liskov=substitute --disable-liskov-fused

        build_log="$(pwd)/log-build"
        runscripts_log="$(pwd)/log-runscripts"
        echo "== make icon in $(pwd)"
        echo "==      log: ${build_log}"
        make -j20 --output-sync > "${build_log}" 2>&1
        echo "== make runscripts $(pwd)"
        echo "==      log: ${runscripts_log}"
        ./make_runscripts --all  > "${runscripts_log}" 2>&1

        # TODO: split this into a run job
        #pushd run
        #    sbatch exp.mch_ch_r04b09_dsl.run
        #popd
    popd

    # Build version for debugging
    #echo "=="
    #echo "== debug build: $(PWD)/build_debug"
    #echo "=="
    #mkdir build_debug
    #pushd build_debug
        #NETCDFMINFORTRAN=${uenv_view_path} \
        #NETCDF=${uenv_view_path} \
        #XML2_ROOT=${XML2} \
        #ECCODES_ROOT=${uenv_view_path} \
        #LOC_GT4PY=${build_path}/gt4py/ \
        #LOC_ICON4PY_ATM_DYN_ICONAM=${build_path}/icon4py/model/atmosphere/dycore/src/icon4py/model/atmosphere/dycore/ \
        #LOC_ICON4PY_ADVECTION=${build_path}/icon4py/model/atmosphere/advection/src/icon4py/model/atmosphere/advection/ \
        #LOC_ICON4PY_DIFFUSION=${build_path}/icon4py/model/atmosphere/diffusion/src/icon4py/model/atmosphere/diffusion/stencils \
        #LOC_ICON4PY_INTERPOLATION=${build_path}/icon4py/model/common/src/icon4py/model/common/interpolation/stencils \
        #LOC_ICON4PY_TOOLS=${build_path}/icon4py/tools/src/icon4pytools/ \
        #LOC_ICON4PY_BIN=${build_path}/icon4py/.venv/ \
        #LOC_GRIDTOOLS=${build_path}/gridtools/ \
        #./../config/cscs/balfrin_nospack.gpu.nvidia --enable-dsl-local --disable-rte-rrtmgp --enable-liskov=verify --disable-liskov-fused

        #make -j20
        #./make_runscripts --all

        # TODO: split this into a run job
        #pushd run
        #    sbatch exp.mch_ch_r04b09_dsl.run
        #popd
    #popd

popd
