#!/usr/bin/bash

# wget https://raw.githubusercontent.com/mugimugi555/ubuntu/main/install_printer.sh && bash install_printer.sh ;

cd ;
sudo echo ;

echo "=================================";
echo "";
echo "  install libraries for compile";
echo "";
echo "=================================";
sudo apt install gcc libtool libssl-dev libc-dev libjpeg-turbo8-dev libpng-dev libtiff5-dev cups ;
sudo apt-get install libcups2-dev ;
echo "";

echo "=================================";
echo "";
echo "   download file and extract";
echo "";
echo "=================================";
wget https://jaist.dl.sourceforge.net/project/gimp-print/gutenprint-5.3/5.3.4/gutenprint-5.3.4.tar.bz2 ;
tar xvf gutenprint-5.3.4.tar.bz2 ;
cd gutenprint-5.3.4/ ;
echo "";

echo "=================================";
echo "";
echo "configure and make and make install";
echo "";
echo "=================================";
./configure ;
make clean ;
make ;
sudo make install ;
echo "";

echo "=================================";
echo "";
echo "       cups install done";
echo "";
echo "=================================";
echo "";
echo "  please install driver manuary";
echo "";
echo "=================================";
echo "";
gnome-control-center printers &
