#!/usr/bin/bash

# wget https://raw.githubusercontent.com/mugimugi555/ubuntu/main/install_power_save.sh && bash install_power_save.sh ;

sudo echo ;
sudo apt install -y powertop ;
sudo powertop --auto-tune ;
sudo add-apt-repository -y ppa:linrunner/tlp ;
sudo apt-get update ;
sudo apt install -y tlp tlp-rdw ;
sudo tlp start ;

sudo apt install -y gnome-shell-extensions ;

echo "please install browser extension >";
xdg-open https://extensions.gnome.org/extension/1082/cpufreq/ &
