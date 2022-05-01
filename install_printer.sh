#!/usr/bin/bash

# wget https://raw.githubusercontent.com/mugimugi555/ubuntu/main/install_printer.sh && bash install_printer.sh ;

cd ;
sudo echo ;

sudo apt install -y gcc libtool libssl-dev libc-dev libjpeg-turbo8-dev libpng-dev libtiff5-dev cups ;
sudo apt install -y libcups2-dev ;

cd ;
wget https://jaist.dl.sourceforge.net/project/gimp-print/gutenprint-5.3/5.3.4/gutenprint-5.3.4.tar.bz2 ;
tar xvf gutenprint-5.3.4.tar.bz2 ;
cd gutenprint-5.3.4/ ;

./configure ;
make clean ;
make -j$(nproc) ;
sudo make install ;

gnome-control-center printers &
