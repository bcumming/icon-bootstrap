sw_path=$(pwd)/repo/software
cd $sw_path

pwd

for repo in "stackinator" "spack" "uenv" "squashfs-mount" "ault-gh" "alps-cluster-config" "node-burn" "stackinator-mpich-pkgs"
do
    rm -rf $repo
    tar -xzf $repo.tar.gz
done
