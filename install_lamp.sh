#!/bin/bash

# wget https://raw.githubusercontent.com/mugimugi555/ubuntu/main/install_lamp.sh && bash install_lamp.sh ;

#-----------------------------------------------------------------------------------------------------------------------
# add php repository
#-----------------------------------------------------------------------------------------------------------------------
sudo apt update ;
sudo apt upgrade -y ;
sudo apt install -y ca-certificates apt-transport-https software-properties-common wget curl lsb-release ;
sudo add-apt-repository ppa:ondrej/php -y ;

#-----------------------------------------------------------------------------------------------------------------------
# install apache php mysql
#-----------------------------------------------------------------------------------------------------------------------
sudo apt update ;
sudo apt upgrade -y ;
sudo apt install -y \
  apache2 \
  php php-cli php-fpm php-mbstring php-mysql php-curl php-gd php-curl php-zip php-xml \
  mariadb-server ;

#-----------------------------------------------------------------------------------------------------------------------
# enable php-fpm
#-----------------------------------------------------------------------------------------------------------------------
sudo apt install -y libapache2-mod-fcgid ;
sudo a2enmod proxy_fcgi setenvif ;
PHPVERSION=$(php -v | head -n 1 | cut -d " " -f 2 | cut -f1-2 -d".") ;
sudo a2enconf php$PHPVERSION-fpm ;
sudo systemctl restart apache2 ;
#sudo systemctl status php$PHPVERSION-fpm ;

#-----------------------------------------------------------------------------------------------------------------------
# finish
#-----------------------------------------------------------------------------------------------------------------------
sudo rm /var/www/html/index.html ;
echo "<?php phpinfo(); " | sudo tee /var/www/html/index.php ;
LOCAL_IPADDRESS=`hostname -I | awk -F" " '{print $1}'` ;
echo "======================================" ;
echo "visit => http://$LOCAL_IPADDRESS/" ;
echo "======================================" ;

xdg-open http://$LOCAL_IPADDRESS/ &
