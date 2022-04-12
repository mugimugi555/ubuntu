#!/usr/bin/bash

sudo echo ;

#
sudo apt update ;
sudo apt upgrade -y ;
sudo apt install -y ubuntu-desktop ;

#
sed -ei 's/quiet splash”/quiet splash nomodeset”/g' /etc/default/grub ;
sudo update-grub2 ;

#
sudo dpkg-reconfigure gdm3 ;
