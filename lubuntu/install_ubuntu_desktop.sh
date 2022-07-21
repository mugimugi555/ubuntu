#!/usr/bin/bash

# wget https://raw.githubusercontent.com/mugimugi555/ubuntu/main/lubuntu/install_ubuntu_desktop.sh && bash install_ubuntu_desktop.sh ;

# lubuntu -> ubuntu desktop

sudo echo ;

#-----------------------------------------------------------------------------------------------------------------------
# sudo time out
#-----------------------------------------------------------------------------------------------------------------------
echo 'Defaults timestamp_timeout = 1200' | sudo EDITOR='tee -a' visudo ;

#-----------------------------------------------------------------------------------------------------------------------
# install ubuntu desktop
#-----------------------------------------------------------------------------------------------------------------------
sudo apt-add-repository non-free -r ;
sudo apt update ;
sudo apt upgrade -y ;

#-----------------------------------------------------------------------------------------------------------------------
#
#-----------------------------------------------------------------------------------------------------------------------
sudo apt install -y openssh-server ;
sudo apt install -y ubuntu-desktop ;

#-----------------------------------------------------------------------------------------------------------------------
# update boot nomodeset mode
#-----------------------------------------------------------------------------------------------------------------------
sudo sed -ie 's/quiet splash"/quiet splash nomodeset"/g' /etc/default/grub ;
sudo update-grub2 ;

#-----------------------------------------------------------------------------------------------------------------------
# auto login on sddm
#-----------------------------------------------------------------------------------------------------------------------
#MY_AUTO_LOGIN=$(cat<<TEXT
#[Autologin]
#Session=ubuntu.desktop
#User=$USER
#TEXT
#)
#sudo cp /etc/sddm.conf /etc/sddm.conf.org ;
#echo "$MY_AUTO_LOGIN" | sudo tee /etc/sddm.conf ;

#-----------------------------------------------------------------------------------------------------------------------
# grup install old
#-----------------------------------------------------------------------------------------------------------------------
#sudo apt install -y grub2-common grub-efi-ia32 ;
#sudo grub-install --efi-directory=/boot/efi ;
#sudo update-grub ;

#-----------------------------------------------------------------------------------------------------------------------
# finish
#-----------------------------------------------------------------------------------------------------------------------
sudo reboot now ;
