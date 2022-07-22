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
#curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - ;
#echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list ;
#sudo apt update ;
#sudo apt install -y yarn ;

#
node -v ;
npm  -v ;
yarn -v ;
