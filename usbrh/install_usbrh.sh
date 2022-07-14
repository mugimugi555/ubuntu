!#/usr/bin/bash

# wget https://raw.githubusercontent.com/mugimugi555/ubuntu/main/usbrh/install_usbrh.sh && bash install_usbrh.sh ;

sudo su -

sudo apt install -y build-essential ;
sudo apt install -y libusb-dev ;

cd ;
git clone https://github.com/osapon/usbrh-linux.git ;
cd usbrh-linux/ ;
make ;
sudo ./usbrh ;
