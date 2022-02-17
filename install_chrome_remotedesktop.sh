#!/bin/bash

# wget 

cd ;
mkdir ~/.config/chrome-remote-desktop ;
wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb ;
sudo apt install -y ./chrome-remote-desktop_current_amd64.deb  ;
xdg-open https://remotedesktop.google.com/access/ & ;
