#!/usr/bin/bash

# wget https://raw.githubusercontent.com/mugimugi555/ubuntu/main/lubuntu/onkyo/install_wifi.sh && bash install_wifi.sh ;

sudo echo ;

#-----------------------------------------------------------------------------------------------------------------------
# wifi driver
#-----------------------------------------------------------------------------------------------------------------------
# https://packages.debian.org/ja/sid/all/firmware-brcm80211/download
wget http://ftp.jp.debian.org/debian/pool/non-free/f/firmware-nonfree/firmware-brcm80211_20210818-1_all.deb ;
sudo dpkg -i firmware-brcm80211_20210818-1_all.deb ;

#sudo apt-add-repository non-free ;
#sudo apt update ;
#sudo apt upgrade -y ;
