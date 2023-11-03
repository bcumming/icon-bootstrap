# the steps to bootstrap an ancient python if, heaven forbid, you should ever need it.

mkdir tmp; cd tmp;
pv=3.6.15
#wget https://www.python.org/ftp/python/$pv/Python-$pv.tgz
tar xzf ${repo_path}/software/Python-$pv.tgz
rm Python-$pv.tgz
cd Python-$pv
./configure --enable-optimizations --prefix=$SCRATCH/python
make -j12 altinstall
