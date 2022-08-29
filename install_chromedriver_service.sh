#!/usr/bin/bash

# wget https://raw.githubusercontent.com/mugimugi555/ubuntu/main/install_chromedriver_service.sh && bash install_chromedriver_service.sh ;

# install nodejs npm
#wget https://raw.githubusercontent.com/mugimugi555/ubuntu/main/install_nodejs.sh && bash install_nodejs.sh

# install chromedriver
#wget https://raw.githubusercontent.com/mugimugi555/ubuntu/main/install_chromedriver.php && php install_chromedriver.php ;

# install pm2 service
sudo npm install pm2 -g ;

# add services
pm2 start "/home/$USER/chromedrivers/chromedriver     --port=5001" --name=chromedriver_latest_5001 ;
pm2 save ;

# auto start at logon
pm2 startup ;
sudo env PATH=$PATH:/usr/local/bin /usr/local/lib/node_modules/pm2/bin/pm2 startup systemd -u $USER --hp /home/$USER

pm2 status ;

xdg-open http://localhost:5001 &
