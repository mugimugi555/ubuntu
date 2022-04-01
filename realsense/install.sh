#!/bin/bash

# wget wget https://raw.githubusercontent.com/mugimugi555/ubuntu/main/realsense/install.sh && bash install.sh ;

# http://www1.meijo-u.ac.jp/~kohara/cms/technicalreport/ubuntu1804_realsense
# https://qiita.com/keoitate/items/efe4212b0074e10378ec

sudo echo ;

sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-key F6E65AC044F831AC80A06380C8B3A55A6F3EFCDE || sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key F6E65AC044F831AC80A06380C8B3A55A6F3EFCDE ;
sudo add-apt-repository "deb https://librealsense.intel.com/Debian/apt-repo $(lsb_release -cs) main" -u ;

sudo apt install -y librealsense2-dkms ;
sudo apt install -y librealsense2-utils ;
sudo apt install -y librealsense2-dev ;

sudo realsense-viewer & ;
