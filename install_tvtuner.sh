#!/usr/bin/bash

# wget 

# NOTE : I did not run this script test.

sudo echo ;

# install docker stable
# sudo apt-get update ;
# sudo apt-get install -y docker-ce ;

# install docker edge
curl -fsSL get.docker.com -o get-docker.sh ;
sudo sh get-docker.sh ;

# install docker compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose ;
sudo chmod +x /usr/local/bin/docker-compose ;
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose ;

# add user group to docker
sudo addgroup --system docker ;
sudo adduser $USER docker ;
sudo systemctl restart docker ;

# install mirakurun
cd ;
mkdir mirakurun ;
cd mirakurun ;
wget https://raw.githubusercontent.com/Chinachu/Mirakurun/master/docker/docker-compose.yml ;
docker-compose pull ; ;
docker-compose run --rm -e SETUP=true mirakurun
docker-compose up -d ;
cd /usr/local/mirakurun/ ;
ls -al ;
curl -X PUT "http://localhost:40772/api/config/channels/scan" ;

# install chinachu ( web gui )
cd ;
git clone git://github.com/kanreisa/Chinachu.git ;
cd Chinachu ;
mkdir recorded ;
echo "[]" > rules.json ;
 cp config.sample.json config.json ;
 ./chinachu installer 1 ;
 ./chinachu update ;
 ./chinachu service wui execute ;
 sudo pm2 start processes.json ;
 sudo pm2 save ;
 sudo pm2 startup ;
