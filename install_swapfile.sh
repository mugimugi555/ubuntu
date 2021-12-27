#!/usr/bin/bash

# not tested !!

sudo echo ;
sudo fallocate -l 64G /swapfile ;
sudo chmod 600 /swapfile ;
sudo mkswap /swapfile ;
sudo swapon /swapfile ;
sudo swapon --show ;

# sudo cp /etc/fstab /etc/fstab.back ;
# sudo echo "/swapfile " | tee >> /etc/fstab ;
