#!/usr/bin/bash

# Install VMware Workstation Player on Ubuntu 22.04 LTS - Linux Shout 
# https://www.how2shout.com/linux/install-vmware-workstation-player-on-ubuntu-22-04-lts/

sudo apt install -y gcc ;
sudo apt install -y build-essential ;
sudo apt install -y unzip ;

cd ;
wget https://codeload.github.com/mkubecek/vmware-host-modules/zip/refs/tags/w16.2.3-k5.18 ;
unzip w16.2.3-k5.18 ;
cd vmware-host-modules-w16.2.3-k5.18 ;
tar -cf vmmon.tar vmmon-only ;
tar -cf vmnet.tar vmnet-only ;
sudo cp -v vmmon.tar vmnet.tar /usr/lib/vmware/modules/source/ ;

sudo vmware-modconfig --console --install-all ;
