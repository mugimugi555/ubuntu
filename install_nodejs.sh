#!/usr/bin/bash

# wget https://raw.githubusercontent.com/mugimugi555/ubuntu/main/install_nodejs.sh && bash install_nodejs.sh ;

sudo echo;

#
sudo apt install -y nodejs npm ;
node -v ;
npm  -v ;

#
sudo npm install n -g ;
sudo n stable ;
sudo npm install -g yarn ;
sudo apt purge -y nodejs ;
sudo apt autoremove -y ;
exec $SHELL -l ;

#
node -v ;
npm  -v ;
yarn -v ;
