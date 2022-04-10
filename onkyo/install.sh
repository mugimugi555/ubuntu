#!/usr/bin/bash

sudo echo ;
sudo apt update ;
sudo apt install -y grub2-common grub-efi-ia32 ;
sudo grub-install --efi-directory=/boot/efi ;
sudo update-grub ;

sudo sed -e "s/quiet splash\”/quiet splash nomodeset\”/" /etc/default/grub ;
sudo update-grub2 ;
