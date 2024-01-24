#install go
wget https://go.dev/dl/go1.21.6.linux-amd64.tar.gz
tar -xvf go1.21.6.linux-amd64.tar.gz 
cd go
export PATH=$PATH:/home/ubuntu/go/bin
export GOPATH=/home/ubuntu/go
export GOBIN=/home/ubuntu/bin 

#Install singularity
wget https://github.com/sylabs/singularity/releases/download/v3.11.0/singularity-ce-3.11.0.tar.gz
tar -xzf singularity-ce-3.11.0.tar.gz 
cd singularity-ce-3.11.0/
sudo apt-get install libseccomp-dev
sudo apt-get update
./mconfig &&     make -C ./builddir &&     sudo make -C ./builddir install

#Build the container image
sudo singularity build --sandbox ubuntu20.04-intel-srwapp docker://noaaepic/ubuntu20.04-intel-srwapp:release-public-v2.2.0

#Upgrade lmod/Lua
https://sourceforge.net/projects/lmod/files/Lmod-8.6.tar.bz2
tar xvfj Lmod-8.6.tar.bz2
cd Lmod-8.6
sudo apt update
#Upgrade Lua to 5.3.x
./configure --prefix=/opt/apps
make install
source /opt/apps/lmod/lmod/init/bash

#Install ruby and ruby-dev
sudo apt-get install ruby
sudo apt-get install ruby-dev

#Install miniconda


#Install rocoto

