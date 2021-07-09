#!/usr/bin/bash

#

# sudo emacs /etc/apt/sources.list.d/hpe.list ;
# deb https://downloads.linux.hpe.com/SDR/repo/mcp focal/current non-free

sudo echo ;
echo "deb https://downloads.linux.hpe.com/SDR/repo/mcp focal/current non-free" | sudo tee -a /etc/apt/sources.list.d/hpe.list ;

curl https://downloads.linux.hpe.com/SDR/hpPublicKey2048.pub | sudo apt-key add - ;
curl https://downloads.linux.hpe.com/SDR/hpPublicKey2048_key1.pub | sudo apt-key add - ;
curl https://downloads.linux.hpe.com/SDR/hpePublicKey2048_key1.pub | sudo apt-key add - ;

sudo apt update ;
sudo apt install ssa ssacli ssaducli ;
