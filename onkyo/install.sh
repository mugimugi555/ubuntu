#!/usr/bin/bash

# wget https://raw.githubusercontent.com/mugimugi555/ubuntu/main/onkyo/install.sh && bash install.sh ;

# lubuntu -> ubuntu desktop

sudo echo ;

#-----------------------------------------------------------------------------------------------------------------------
# install ubuntu desktop
#-----------------------------------------------------------------------------------------------------------------------
sudo apt update ;
sudo apt upgrade -y ;
sudo apt install -y ubuntu-desktop ;

#-----------------------------------------------------------------------------------------------------------------------
# update boot nomodeset mode
#-----------------------------------------------------------------------------------------------------------------------
sed -ei 's/quiet splash”/quiet splash nomodeset”/g' /etc/default/grub ;
sudo update-grub2 ;

#-----------------------------------------------------------------------------------------------------------------------
# enable ubuntu desktop gdm3
#-----------------------------------------------------------------------------------------------------------------------
sudo dpkg-reconfigure gdm3 ;

# wifi
# https://packages.debian.org/ja/sid/all/firmware-brcm80211/download
# wget http://ftp.jp.debian.org/debian/pool/non-free/f/firmware-nonfree/firmware-brcm80211_20210818-1_all.deb ;
# sudo dpkg -i firmware-brcm80211_20210818-1_all.deb ;
