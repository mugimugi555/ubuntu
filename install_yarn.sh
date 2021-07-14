#!/usr/bin/bash

# wget https://raw.githubusercontent.com/mugimugi555/ubuntu/main/install_yarn.sh && bash install_yarn.sh ;

curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - ;
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list ;
sudo apt update ;
sudo apt install -y yarn ;
