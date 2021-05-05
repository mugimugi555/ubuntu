#!/usr/bin/bash

# sudo
sudo echo ;
cd ;

# add repo
echo "deb https://apt.repos.intel.com/oneapi all main" | sudo tee /etc/apt/sources.list.d/oneAPI.list ;
wget https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB ;
sudo apt-key add GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB ;
rm GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB ;

# install app
sudo apt update ;
sudo apt -y install intel-basekit ;

# enable app
source /opt/intel/oneapi/setvars.sh intel64 ;

# list app
ls -1 /opt/intel/oneapi/compiler/latest/linux/bin

# do command
clang --version ;
