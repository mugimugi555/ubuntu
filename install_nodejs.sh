#!/usr/bin/bash

#

sudo echo;

sudo apt install -y nodejs npm ;
sudo npm install n -g ;
sudo n stable ;
sudo apt purge -y nodejs npm ;
exec $SHELL -l ;
node -v ;
