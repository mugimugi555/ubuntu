#!/usr/bin/bash

# wget https://raw.githubusercontent.com/mugimugi555/ubuntu/main/install_nodejs.sh && bash install_nodejs.sh

sudo echo;

sudo apt install -y nodejs npm ;
sudo npm install n -g ;
sudo n stable ;
sudo apt purge -y nodejs npm ;
#exec $SHELL -l ;
node -v ;
