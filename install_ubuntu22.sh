#!/usr/bin/bash

sudo apt update ;
sudo apt upgrade -y ;
sudo apt install update-manager ;
sudo apt dist-upgrade -y ;
sudo do-release-upgrade -c -d -y ;
