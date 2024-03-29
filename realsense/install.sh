#!/bin/bash

# wget wget https://raw.githubusercontent.com/mugimugi555/ubuntu/main/realsense/install.sh && bash install.sh ;

# http://www1.meijo-u.ac.jp/~kohara/cms/technicalreport/ubuntu1804_realsense
# https://qiita.com/keoitate/items/efe4212b0074e10378ec

sudo echo ;

#-----------------------------------------------------------------------------------------------------------------------
# add repository
#-----------------------------------------------------------------------------------------------------------------------
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-key F6E65AC044F831AC80A06380C8B3A55A6F3EFCDE || sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key F6E65AC044F831AC80A06380C8B3A55A6F3EFCDE ;
sudo add-apt-repository "deb https://librealsense.intel.com/Debian/apt-repo $(lsb_release -cs) main" -u ;

#-----------------------------------------------------------------------------------------------------------------------
# install libarary
#-----------------------------------------------------------------------------------------------------------------------
sudo apt install -y librealsense2-dkms ;
sudo apt install -y librealsense2-utils ;
sudo apt install -y librealsense2-dev ;

#-----------------------------------------------------------------------------------------------------------------------
# launch app
#-----------------------------------------------------------------------------------------------------------------------
sudo realsense-viewer ;

#-----------------------------------------------------------------------------------------------------------------------
# launch python app
#-----------------------------------------------------------------------------------------------------------------------
sudo pip3 install pyrealsense2 ;
sudo pip3 install opencv-python ;
sudo pip3 install numpy ;

wget https://raw.githubusercontent.com/mugimugi555/ubuntu/main/realsense/realsense_1.py ;
sudo python3 realsense_1.py ; 
