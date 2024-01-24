###install go###
wget https://go.dev/dl/go1.21.6.linux-amd64.tar.gz
tar -xvf go1.21.6.linux-amd64.tar.gz
cd go
export PATH=$PATH:/home/ubuntu/go/bin
export GOPATH=/home/ubuntu/go
export GOBIN=/home/ubuntu/go/bin

###Install singularity###
cd /home/ubuntu
wget https://github.com/sylabs/singularity/releases/download/v3.11.0/singularity-ce-3.11.0.tar.gz
tar -xzf singularity-ce-3.11.0.tar.gz
cd singularity-ce-3.11.0/
sudo apt-get install libseccomp-dev
sudo apt-get update
sudo apt-get install libglib2.0-dev
./mconfig &&     make -C ./builddir &&     sudo make -C ./builddir install

###Build the container image###
cd /home/ubuntu
sudo singularity build --sandbox ubuntu20.04-intel-srwapp docker://noaaepic/ubuntu20.04-intel-srwapp:release-public-v2.2.0

###Upgrade lmod/Lua###
cd /home/ubuntu
sudo apt install lua5.3
sudo apt remove lua5.2
wget https://sourceforge.net/projects/lmod/files/Lmod-8.6.tar.bz2
tar xvfj Lmod-8.6.tar.bz2
cd Lmod-8.6
./configure --prefix=/opt/apps
sudo make install
source /opt/apps/lmod/lmod/init/bash

###Install ruby and ruby-dev###
cd /home/ubuntu
sudo apt-get install ruby
sudo apt-get install ruby-dev

###Install miniconda###
cd /home/ubuntu
git clone -b feature/ufs_srw_public_2.2.0 https://github.com/NOAA-EPIC/miniconda3.git
cd miniconda3/
sed -i "s|lustre|home\/ubuntu|g" miniconda3template.lua
./miniconda3_install.sh /home/ubuntu/miniconda3   4.12.0
./miniconda3_regional_workflow_env.sh   /home/ubuntu/miniconda3  4.12.0
./miniconda3_workflow_tools_env.sh   /home/ubuntu/miniconda3  4.12.0
./miniconda3_regional_workflow_cmaq_env.sh   /home/ubuntu/miniconda3  4.12.0
# Load the module:
module use /home/ubuntu/miniconda3/modulefiles
module load miniconda3/4.12.0
cd /home/ubuntu/miniconda3/4.12.0/lib/
mv libtinfo.so.6 libtinfo.so.6_bac

###Install rocoto###
cd /home/ubuntu
PREFIX="/home/ubuntu/rocoto"
mkdir -p $PREFIX && cd $PREFIX
git clone -b 1.3.6 https://github.com/christopherwharrop/rocoto.git 1.3.6
cd 1.3.6
./INSTALL 2>&1 | tee rocoto-1.3.6.install.log
# Prepare a modulefile for rocoto
cd $PREFIX
export ROCOTOBIN=$PREFIX/1.3.6/bin
export ROCOTOLIB=$PREFIX/1.3.6/lib
mkdir $PREFIX/modulefiles
mkdir $PREFIX/modulefiles/rocoto
touch $PREFIX/modulefiles/rocoto/1.3.6.lua
cat > modulefiles/rocoto/1.3.6.lua << EOF
help([[
  Set environment variables for rocoto workflow manager)
]])

-- Make sure another version of the same package is not already loaded
conflict("rocoto")

-- Set environment variables
prepend_path("PATH","$ROCOTOBIN")
prepend_path("LD_LIBRARY_PATH","$ROCOTOLIB")
EOF
# Verify the module could be loaded:
module use /$PREFIX/modulefiles
module load rocoto/1.3.6

###Add needed data###
cd /data
wget https://noaa-ufs-srw-pds.s3.amazonaws.com/current_srw_release_data/fix_data.tgz
tar xfz fix_data.tgz
wget https://noaa-ufs-srw-pds.s3.amazonaws.com/current_srw_release_data/gst_data.tgz
tar xfz gst_data.tgz
# After untaring the files, directories ./fix and ./input_model_data
