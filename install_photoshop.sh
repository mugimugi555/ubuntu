#!/bin/bash

# wget https://raw.githubusercontent.com/mugimugi555/ubuntu/main/install_photoshop.sh && bash install_photoshop.sh ;

#-----------------------------------------------------------------------------------------------------------------------
# 
#-----------------------------------------------------------------------------------------------------------------------
cd ;
sudo echo ;

#-----------------------------------------------------------------------------------------------------------------------
# add latest wine repository
#-----------------------------------------------------------------------------------------------------------------------
sudo dpkg --add-architecture i386 ;
sudo mkdir -pm755 /etc/apt/keyrings ;
sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key ;
sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/winehq-jammy.sources ;

#-----------------------------------------------------------------------------------------------------------------------
# install latest wine
#-----------------------------------------------------------------------------------------------------------------------
sudo apt update ;
sudo apt install -y --install-recommends libgd3:i386 ;
sudo apt install -y --install-recommends winehq-devel ;
wine --version ;

#-----------------------------------------------------------------------------------------------------------------------
# wine settings
#-----------------------------------------------------------------------------------------------------------------------
cd ;
git clone https://github.com/YoungFellow-le/photoshop-22-linux.git ;
./main-menu.sh ;
winetricks cjkfonts ;

#-----------------------------------------------------------------------------------------------------------------------
# install photoshop ( need adobe windows installer file )
#-----------------------------------------------------------------------------------------------------------------------
cd ;
wine ~/MasterCollection_CS5_LS2/Adobe\ CS5/Set-up.exe ;
wine ~/.wine/drive_c/Program\ Files/Adobe/Adobe\ Photoshop\ CS5/Photoshop.exe ;
