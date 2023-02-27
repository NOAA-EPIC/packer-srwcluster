#!/bin/bash
mkdir -p /opt/build 
mkdir -p /opt/dist
apt-get update 
apt-get -y upgrade
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ca-certificates curl 
rm -rf /var/lib/apt/lists/*
# install cmake
cd /opt/build 
curl -LO https://github.com/Kitware/CMake/releases/download/v3.23.1/cmake-3.23.1-linux-x86_64.sh && /bin/bash cmake-3.23.1-linux-x86_64.sh --prefix=/usr/local --skip-license
apt-get update -yq --allow-unauthenticated
apt-get install -y lmod 
apt-get install -y tzdata 
ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime 
dpkg-reconfigure --frontend noninteractive tzdata 
apt-get -y install build-essential git vim python3 wget libexpat1-dev lmod bc time 
apt-get install -yq libtiff-dev git-lfs python3-distutils python3-pip wget m4 unzip curl
apt-get install -y --no-install-recommends apt-utils
echo "dash dash/sh boolean false" | debconf-set-selections
DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash
ls -l /bin/sh
mkdir -p /opt
cd /opt
git clone -b feature/oneapi --recursive https://github.com/NOAA-EPIC/spack-stack.git
cd /opt/spack-stack
pwd
ls -l /bin/sh
sed -i 's/source/./g' ./setup.sh
. ./setup.sh
spack install intel-oneapi-compilers 
ls -l /bin/sh  
pwd 
ls -l 
. ./setup.sh 
spack install intel-oneapi-compilers 
spack install intel-oneapi-mpi && spack compiler list && spack find 
spack compiler add `spack location -i intel-oneapi-compilers`/compiler/latest/linux/bin/intel64 && spack compiler list 
spack compiler rm gcc@9.4.0
ENV PATH="${PATH}:/usr/local"
#this module.yaml file sets the format for tcl modules built by spack to have no extra hashes
wget -O /tmp/modules.yaml https://noaa-epic-dev-pcluster.s3.amazonaws.com/scripts/modules.yml
cp /tmp/modules.yaml /opt/spack-stack/spack/etc/spack/defaults
#Add the intel compiler to spack and find externals, then install any general packages (cmake) that don't need to be 
#part of the concretization
. ./setup.sh 
spack compiler add 
spack external find wget 
spack external find m4 
spack external find git 
spack external find curl 
spack external find git-lfs 
spack external find openssl 
spack external find libjpeg-turbo 
spack external find perl 
spack external find python 
spack install zlib@1.2.12 
spack install cmake@3.22.1 
spack install curl@7.49.1 
spack module tcl refresh -y --delete-tree && source /usr/share/lmod/lmod/init/bash && module avail
#set up modules to be loaded automatically when shelling into the container
. ./setup.sh
echo "source /usr/share/lmod/lmod/init/bash" >> /root/.bashenv
echo "module use module use /opt/spack-stack/spack/share/spack/modules/linux-*" >> /root/.bashenv
echo "module load cmake/3.22.1 intel-oneapi-compilers/2022.1.0 intel-oneapi-mpi/2021.6.0 " >> /root/.bashenv
echo "[[ -s ~/.bashenv ]] && source ~/.bashenv" >> /root/.bash_profile
echo "[[ -s ~/.bashenv ]] && source ~/.bashenv" >> /root/.bashrc
## Intel Spack Stack Install ##
echo "Starting spack stack install"
cd /opt/spack-stack
mkdir -p /opt/spack-stack/configs/sites/ubuntu-intel
cp /root/.spack/linux/compilers.yaml /opt/spack-stack/configs/sites/ubuntu-intel
ls -l /opt/spack-stack/configs/sites/ubuntu-intel
find /opt/spack-stack/spack/opt/spack/ -iname intel-oneapi-mpi*
loc=`find /opt/spack-stack/spack/opt/spack/ -iname intel-oneapi-mpi* | head -n 1`
echo $loc
echo "config:" > /opt/spack-stack/configs/sites/ubuntu-intel/config.yaml
echo "  build_jobs: 8" >> /opt/spack-stack/configs/sites/ubuntu-intel/config.yaml
echo "modules:" > /opt/spack-stack/configs/sites/ubuntu-intel/modules.yaml
echo "  default:" >> /opt/spack-stack/configs/sites/ubuntu-intel/modules.yaml
echo "    enable::" >> /opt/spack-stack/configs/sites/ubuntu-intel/modules.yaml
echo "    - lmod" >> /opt/spack-stack/configs/sites/ubuntu-intel/modules.yaml
echo "packages:" > /opt/spack-stack/configs/sites/ubuntu-intel/packages.yaml
echo "  all:" >> /opt/spack-stack/configs/sites/ubuntu-intel/packages.yaml
echo "    compiler:: [intel@2021.6.0]" >> /opt/spack-stack/configs/sites/ubuntu-intel/packages.yaml
echo "    providers:" >> /opt/spack-stack/configs/sites/ubuntu-intel/packages.yaml
echo "      mpi:: [intel-oneapi-mpi@2021.6.0]" >> /opt/spack-stack/configs/sites/ubuntu-intel/packages.yaml
echo "  mpi:" >> /opt/spack-stack/configs/sites/ubuntu-intel/packages.yaml
echo "    buildable: False" >> /opt/spack-stack/configs/sites/ubuntu-intel/packages.yaml
echo "  intel-oneapi-mpi:" >> /opt/spack-stack/configs/sites/ubuntu-intel/packages.yaml
echo "    externals:" >> /opt/spack-stack/configs/sites/ubuntu-intel/packages.yaml
echo "    - spec: intel-oneapi-mpi@2021.6.0" >> /opt/spack-stack/configs/sites/ubuntu-intel/packages.yaml
echo "      modules:" >> /opt/spack-stack/configs/sites/ubuntu-intel/packages.yaml
echo "      - impi/2021.6.0" >> /opt/spack-stack/configs/sites/ubuntu-intel/packages.yaml
echo "      prefix: $loc" >> /opt/spack-stack/configs/sites/ubuntu-intel/packages.yaml
branch=$"release/public-v2.1.0"
echo "branch is " $branch
git clone -b $branch https://github.com/ufs-community/ufs-srweather-app.git
wget -O /tmp/srw.specs https://noaa-epic-dev-pcluster.s3.amazonaws.com/scripts/srw.specs
cp /tmp/srw.specs /opt/spack-stack
. ./setup.sh
spack stack create env --site ubuntu-intel --template empty --name $branch
echo $branch
sed -i 's/\[\]//g' envs/$branch/spack.yaml
cat srw.specs >> envs/$branch/spack.yaml
spack env activate envs/$branch
spack add curl@7.49.1
spack concretize
spack install
SHELL=/bin/bash
. ./setup.sh && source /usr/share/lmod/lmod/init/bash
spack env activate envs/$branch
ln -s /usr/bin/python3 /usr/bin/python
spack stack setup-meta-modules
spack module lmod refresh -y
module use /opt/spack-stack/envs/$branch/install/modulefiles/Core
ls -l /opt/spack-stack/envs/$branch/install/modulefiles/Core
sed -i 's/impi/intel-oneapi-mpi/g' /opt/spack-stack/envs/$branch/install/modulefiles/intel/2021.6.0/stack-intel-oneapi-mpi/2021.6.0.lua
find /opt/spack-stack/envs/$branch/install/modulefiles -iname "*.lua" | xargs grep -l depends_on | xargs sed -i 's/depends_on/-- depends_on/g'
echo "module use /opt/spack-stack/envs/$branch/install/modulefiles/Core" >> /root/.bashenv
echo "module load stack-intel stack-intel-oneapi-mpi" >> /root/.bashenv
source /root/.bashenv
module spider >& mods && grep ": " mods | awk -F ":" '{print "module load " $2}' | grep -v intel >> /root/.bashenv
sed -i '/An Environment Module System/d' /root/.bashenv
echo "Spack Stack Install Completed!"
### UFS SRW Install ###
echo "Beginning UFS SRW Install"
source /root/.bashenv
module unload curl/7.49.1
module use /opt/spack-stack/spack/share/spack/modules/linux-ubuntu20.04-skylake_avx512
module load curl/7.49.1
cd /opt
mv /opt/spack-stack/ufs-srweather-app .
mkdir /opt/ufs-srweather-app/build
cd /opt/ufs-srweather-app
./manage_externals/checkout_externals
cd /opt/ufs-srweather-app/build
cmake -DCMAKE_CXX_COMPILER=mpiicpc -DCMAKE_C_COMPILER=mpiicc -DCMAKE_FC_COMPILER=mpiifort -DCMAKE_INSTALL_PREFIX=.. ..
make -j 8
echo "UFS SRW App build completed!"
