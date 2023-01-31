#!/usr/bin/bash

# wget https://raw.githubusercontent.com/mugimugi555/ubuntu/main/install_wifi_ rtl8188.sh && bash install_wifi_ rtl8188.sh ;

#-----------------------------------------------------------------------------------------------------------------------
# install rtl8188 driver
#-----------------------------------------------------------------------------------------------------------------------

cd  ;
sudo apt-get install build-essential git dkms linux-headers-$(uname -r) ;
git clone https://github.com/kelebek333/rtl8188fu ;
sudo dkms install ./rtl8188fu ;
sudo cp ./rtl8188fu/firmware/rtl8188fufw.bin /lib/firmware/rtlwifi/ ;

gnome-control-center wifi & ;
