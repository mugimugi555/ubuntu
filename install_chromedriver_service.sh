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
#pm2 start "/home/$USER/chromedrivers/chromedriver_97  --port=5097" --name=chromedriver_97_5097     ;
#pm2 start "/home/$USER/chromedrivers/chromedriver_98  --port=5098" --name=chromedriver_98_5098     ;
#pm2 start "/home/$USER/chromedrivers/chromedriver_99  --port=5099" --name=chromedriver_99_5099     ;
#pm2 start "/home/$USER/chromedrivers/chromedriver_109 --port=5100" --name=chromedriver_200_5100    ;

pm2 save ;

# auto start at logon
pm2 startup ;
sudo env PATH=$PATH:/usr/local/bin /usr/local/lib/node_modules/pm2/bin/pm2 startup systemd -u $USER --hp /home/$USER

pm2 status ;

#xdg-open http://localhost:5089 &
#xdg-open http://localhost:5090 &
#xdg-open http://localhost:5091 &

#echo "http://localhost:5089";
#echo "http://localhost:5090";
#echo "http://localhost:5091";
