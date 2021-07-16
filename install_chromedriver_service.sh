#!/usr/bin/bash

cd ;

# install nodejs npm
wget https://raw.githubusercontent.com/mugimugi555/ubuntu/main/install_nodejs.sh && bash install_nodejs.sh

# install chromedriver
wget https://raw.githubusercontent.com/mugimugi555/ubuntu/main/install_chromedriver.php && php install_chromedriver.php ;

# install pm2 service
sudo npm install pm2 -g ;

# add services
pm2 start "/home/$USER/chromedrivers/chromedriver_89 --port=5089" --name=chromedriver_89_5089 ;
pm2 start "/home/$USER/chromedrivers/chromedriver_90 --port=5090" --name=chromedriver_90_5090 ;
pm2 start "/home/$USER/chromedrivers/chromedriver_91 --port=5091" --name=chromedriver_91_5091 ;
pm2 save ;

# auto start at logon
echo "========== please hit the next command ======>";
pm2 startup ;

