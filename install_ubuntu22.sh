#!/usr/bin/bash

# wget https://raw.githubusercontent.com/mugimugi555/ubuntu/main/install_ubuntu22.sh && bash install_ubuntu22.sh ;

sudo apt update ;
sudo apt upgrade -y ;
sudo apt install update-manager ;
sudo apt dist-upgrade -y ;
sudo do-release-upgrade -c -d -y ;
sudo reboot now ;
