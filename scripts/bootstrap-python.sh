# the steps to bootstrap an ancient python if, heaven forbid, you should ever need it.

echo "== all the libffi nonsense might not be needed on the HPE system... I had to do it to work around Ubuntu's shittyness"

base=$(pwd)
mkdir $base/tmp; cd $base/tmp;
rm -rf $base/tmp/*

install_path=$base/install

tar -xzf ../repo/software/libffi-3.3.tar.gz
pushd libffi-3.3/
    echo "=== autogen ffi"
    ./autogen.sh > $base/tmp/ffilog 2>&1
    echo "=== configure ffi"
    ./configure --disable-docs --prefix=$install_path/libffi >> $base/tmp/ffilog
    echo "=== build ffi"
    make -j install >> $base/tmp/ffilog
popd
export LD_LIBRARY_PATH=$install_path/libffi/lib:$LD_LIBRARY_PATH
export LD_RUN_PATH=$install_path/libffi/lib:$LD_RUN_PATH

sleep 3

pv="3.6.15"

    echo
    echo
    echo "==== BUILDING python$pv"
    echo
    echo
    sleep 2
    mkdir bld$pv
    pushd bld$pv
        #wget https://www.python.org/ftp/python/$pv/Python-$pv.tgz
        #wget https://www.python.org/ftp/python/3.10.12/Python-3.10.12.tgz
        echo "untar python$pv"
        tar xzf $base/repo/software/Python-$pv.tgz
        cd Python-$pv
        echo "configure python$pv"
        ./configure --enable-shared --enable-optimizations --with-system-ffi --prefix=$install_path/python$pv --with-ensurepip=install LDFLAGS="-L$install_path/libffi/lib" CPPFLAGS="-I$install_path/libffi/include" > $base/tmp/python$pv.log
        echo "make install python$pv"
        make -j12 install >> $base/tmp/python$pv.log
    popd

pv="3.10.12"
    echo
    echo
    echo "==== BUILDING python$pv"
    echo
    echo
    sleep 2
    mkdir bld$pv
    pushd bld$pv
        #wget https://www.python.org/ftp/python/$pv/Python-$pv.tgz
        #wget https://www.python.org/ftp/python/3.10.12/Python-3.10.12.tgz
        echo "untar python$pv"
        tar xzf $base/repo/software/Python-$pv.tgz
        cd Python-$pv
        echo "configure python$pv"
        ./configure --enable-shared --enable-optimizations --with-system-ffi=$install_path/libffi --prefix=$install_path/python$pv --with-ensurepip=install LDFLAGS="-L$install_path/libffi/lib" CPPFLAGS="-I$install_path/libffi/include" > $base/tmp/python$pv.log
        echo "make install python$pv"
        make -j12 install >> $base/tmp/python$pv.log
    popd
