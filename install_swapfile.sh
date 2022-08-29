#!/usr/bin/bash

# wget https://raw.githubusercontent.com/mugimugi555/ubuntu/main/install_swapfile.sh && bash install_swapfile.sh ;

sudo echo ;

#
sudo swapoff -a 

#
sudo fallocate -l 64G /swapfile ;
sudo chmod 600 /swapfile ;
sudo mkswap /swapfile ;
sudo swapon /swapfile ;
sudo swapon --show ;

# sudo cp /etc/fstab /etc/fstab.back ;
# sudo echo "/swapfile " | tee >> /etc/fstab ;
