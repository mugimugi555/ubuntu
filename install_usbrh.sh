!#/usr/bin/bash

# 

sudo echo ;
sudo apt install -y build-essential ;
sudo apt install -y libusb-dev ;
cd ;
git clone https://github.com/osapon/usbrh-linux.git ;
cd usbrh-linux/ ;
make ;
sudo ./usbrh ;
