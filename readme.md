# Bootstrapping ICON

## High-level overview

* PE building
    * bootstrap the PE
        1. create a python venv
        2. pip install from `repos/bootstrap-python`

    * configure the PE build
        1. stack-config (requires spack and python environment)
        2. make stack (requires spack mirror)

* ICON building
    * create python env using Python from the stack
    * install the Python dependencies from repo
    * load modules
    * configure and build ICON

## Organisation

`repo` is a binary repository
* generated using scripts on a system that has access to the internet.
* physically bought to chippewa or coppied to a HPE artifactory.

```
repo
├─ pip
│  ├─ bootstrap         # pip packages to configure and build PE (system python 3.6)
│  └─ icon              # pip packages to configure and build ICON (PE python 3.10)
├─ spack
│  ├─ bootstrap         # binary cache required to bootstrap Spack
│  └─ mirror            # all the tar balls for all the things we will install with spack
└─ software
   ├─ spack             # clone of spack/spack at releases/v0.20
   ├─ stackinator       # clone of eth-cscs/stackinator at v3.0
   └─ uenv              # clone of eth-cscs/uenv
```


```
chippewa
├─ repo                      # replaces internet: symlink
│  └─ ...
├─ scripts
│  ├─ repo-bootstrap.sh      # generates bootstrap part of repo
│  ├─ repo-pe.sh             # generates spack mirror for pe
│  ├─ repo-icon.sh           # generates icon python requirements
│  ├─ pe-bootstrap.sh
│  ├─ pe-build.sh
│  ├─ icon-bootstrap.sh
│  └─ icon-build.sh
├─ stack
│  ├─ cluster-config    # cluster configuration
│  └─ recipe            # the icon pe recipe - includes hard-coded cray-mpich package.
├─ etc
│  ├─ requirements-bootstrap.txt
│  ├─ requirements-icon.txt
│  └─ spack-specs.txt
└─ work
   ├─ icon-build
   └─ ...
```

## NOTES

Stage findings here before encoding them in a script:

The list of specs in a concretised environment can be queried as follows:
```
spack --color=never -C /user-environment/config find --format '{name}@{version}' | sort | uniq
```

Once we have a list of spack specs to add to the mirror, create the mirror as follows:
```
spack mirror create -D -d $(pwd)/mirror -f /home/bcumming/test/spack-env/spack-packages.txt
```

Installing from a local repo

Other steps that have to be performed on site
* create cluster config
    * libfabric
    * gcc
    * slurm?
* create binary package for cray-mpich
    * unpack RPMs
    * gather, then rebind
    * test building osu-micro-benchmark
        * does this require a separate, simplified stack that builds e.g. gcc 12, cuda 12, osu-microbenchmark?

Required information from HPE
* which version of python 3 on the system ?
* which version of gcc in /usr/bin ?
* can they install spack v0.21 and concretise something?
* which version of cray-mpich?
* which version of slingshot and where installed?
* will there also be CPE (cray-mpich, gcc 12, cuda 12) on the system

Required from HPE
* install `squashfs-mount`
    * download and `sudo make install`
* python 3
* tar balls for
    - cray-mpich
    - cray-gtl
    - cray-pmi
* CPE (cray-mpich, gcc 12, cuda 12) on the system

# other random ideas

* bring a full python installation with me, e.g. 3.10 that I use for everything?
