#!/usr/bin/bash

wget https://raw.githubusercontent.com/mugimugi555/ubuntu/main/install_vmware.sh && bash install_vmware.sh ;

sudo apt install -y gcc ;
sudo apt install -y build-essential ;
sudo apt install -y unzip ;

xdg-open "https://customerconnect.vmware.com/en/downloads/details?downloadGroup=WKST-PLAYER-1702&productId=1377&rPId=104734" ;
sudo sh VMware-Player-Full-17.0.2-21581411.x86_64.bundle ;

# https://github.com/mkubecek/vmware-host-modules/blob/master/INSTALL
cd ;
wget https://github.com/mkubecek/vmware-host-modules/archive/workstation-17.0.2.tar.gz ;
tar -xzf workstation-17.0.2.tar.gz ;
cd vmware-host-modules-workstation-17.0.2 ;
make ;
sudo make install ;

vmplayer & ;
