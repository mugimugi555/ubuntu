#!/bin/bash

# wget https://raw.githubusercontent.com/mugimugi555/ubuntu/main/install.sh && bash install.sh ;
#
# or save and edit file
#
# wget https://raw.githubusercontent.com/mugimugi555/ubuntu/main/install.sh && gedit install.sh ;
# bash install.sh ;

#-----------------------------------------------------------------------------------------------------------------------
# home jp 2 english
#-----------------------------------------------------------------------------------------------------------------------
LANG=C xdg-user-dirs-gtk-update ;

#-----------------------------------------------------------------------------------------------------------------------
# settings
#-----------------------------------------------------------------------------------------------------------------------
gsettings set org.gnome.desktop.interface enable-animations false           ;
gsettings set org.gnome.desktop.session idle-delay 0                        ;
gsettings set org.gnome.settings-daemon.plugins.power idle-dim false        ;
gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 30 ;

#-----------------------------------------------------------------------------------------------------------------------
# sudo time out
#-----------------------------------------------------------------------------------------------------------------------
echo 'Defaults timestamp_timeout = 1200' | sudo EDITOR='tee -a' visudo ;

#-----------------------------------------------------------------------------------------------------------------------
# wall paper
#-----------------------------------------------------------------------------------------------------------------------
wget http://gahag.net/img/201602/11s/gahag-0055029460-1.jpg -O /home/$USER/Pictures/1.jpg ;
gsettings set org.gnome.desktop.background picture-uri "file:///home/$USER/Pictures/1.jpg" ;

#-----------------------------------------------------------------------------------------------------------------------
# proxy
#-----------------------------------------------------------------------------------------------------------------------
#sudo echo "Acquire::http::Proxy \"http://192.168.0.5:3142\";" | sudo tee -a /etc/apt/apt.conf.d/02proxy ;

#-----------------------------------------------------------------------------------------------------------------------
# software
#-----------------------------------------------------------------------------------------------------------------------
echo "samba-common samba-common/workgroup string  WORKGROUP" | sudo debconf-set-selections ;
echo "samba-common samba-common/dhcp boolean true"           | sudo debconf-set-selections ;
echo "samba-common samba-common/do_debconf boolean true"     | sudo debconf-set-selections ;
sudo apt update ;
sudo apt upgrade -y ;

# exfat-utils 
sudo apt install -y emacs-nox htop curl git axel samba openssh-server net-tools exfat-fuse ffmpeg ibus-mozc imagemagick lame unar vlc ;
sudo apt autoremove -y ;

#-----------------------------------------------------------------------------------------------------------------------
# vscode & gimp
#-----------------------------------------------------------------------------------------------------------------------
sudo snap install --classic code ;
sudo snap install --classic gimp ;

#-----------------------------------------------------------------------------------------------------------------------
# setting jp
#-----------------------------------------------------------------------------------------------------------------------
sudo update-locale LANG=ja_JP.UTF8 ;
sudo apt install -y manpages-ja manpages-ja-dev ;
sudo update-locale LANG=ja_JP.UTF8 ;
sudo ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime ;
sudo mkdir /usr/share/locale-langpack/ja ;
sudo apt install -y ibus-mozc language-pack-gnome-ja language-pack-gnome-ja-base language-pack-ja language-pack-ja-base fonts-takao-gothic fonts-takao-mincho $(check-language-support) ;

#-----------------------------------------------------------------------------------------------------------------------
# hdparm sleep hdd
#-----------------------------------------------------------------------------------------------------------------------
sudo hdparm -S 242 /dev/sd* ;

#-----------------------------------------------------------------------------------------------------------------------
# youtube
#-----------------------------------------------------------------------------------------------------------------------
sudo curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl ;
sudo chmod a+rx /usr/local/bin/youtube-dl ;

#-----------------------------------------------------------------------------------------------------------------------
# jless
#-----------------------------------------------------------------------------------------------------------------------
# curl -OL https://github.com/PaulJuliusMartinez/jless/releases/download/v0.7.1/jless-v0.7.1-x86_64-unknown-linux-gnu.zip ;
# unzip jless-v0.7.1-x86_64-unknown-linux-gnu.zip
# ./jless data.json
# sudo mv jless /usr/local/bin/jless

#-----------------------------------------------------------------------------------------------------------------------
# chrome
#-----------------------------------------------------------------------------------------------------------------------
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O google-chrome-stable_current_amd64.deb ;
sudo sudo apt install -y ./google-chrome-stable_current_amd64.deb ;

#-----------------------------------------------------------------------------------------------------------------------
# remote desktop
#-----------------------------------------------------------------------------------------------------------------------
#cd ;
#sudo apt install -y wget ;
#wget https://raw.githubusercontent.com/KeithIMyers/Chrome-Remote-Desktop-Ubuntu-Setup/master/chrome-remote-desktop-setup.sh ;
#sudo bash chrome-remote-desktop-setup.sh ;

#-----------------------------------------------------------------------------------------------------------------------
# gsettings list-recursively > 2.txt
#-----------------------------------------------------------------------------------------------------------------------
gsettings set org.gnome.shell favorite-apps "['google-chrome.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop', 'gnome-control-center.desktop']" ;

#-----------------------------------------------------------------------------------------------------------------------
#
#-----------------------------------------------------------------------------------------------------------------------
sudo sed -i 's/#NTP=/NTP=ntp.nict.jp/g' /etc/systemd/timesyncd.conf ;

gsettings set org.gnome.desktop.interface font-name 'Noto Sans CJK JP 11' ;
gsettings set org.gnome.mutter auto-maximize false ;

sudo apt install -y gnome-tweaks ;
sudo apt install -y ubuntu-restricted-extras ;

#-----------------------------------------------------------------------------------------------------------------------
# caps2ctrl
#-----------------------------------------------------------------------------------------------------------------------
CAPS2CTRL=$(cat<<TEXT
BACKSPACE="guess"
XKBMODEL="pc105"
XKBLAYOUT="jp"
XKBVARIANT=""
XKBOPTIONS="ctrl:nocaps"
TEXT
)
sudo echo "$CAPS2CTRL" | sudo tee /etc/default/keyboard ;

MYKEYBOARD=$(cat<<TEXT
<component>
  <version>2.23.2815.102+dfsg-8ubuntu1</version>
  <name>com.google.IBus.Mozc</name>
  <license>New BSD</license>
  <exec>/usr/lib/ibus-mozc/ibus-engine-mozc --ibus</exec>
  <textdomain>ibus-mozc</textdomain>
  <author>Google Inc.</author>
  <homepage>https://github.com/google/mozc</homepage>
  <description>Mozc Component</description>
<engines>
<engine>
  <description>Mozc (Japanese Input Method)</description>
  <language>ja</language>
  <symbol>&#x3042;</symbol>
  <rank>80</rank>
  <icon_prop_key>InputMode</icon_prop_key>
  <icon>/usr/share/ibus-mozc/product_icon.png</icon>
  <setup>/usr/lib/mozc/mozc_tool --mode=config_dialog</setup>
  <layout>jp</layout>
  <name>mozc-jp</name>
  <longname>Mozc</longname>
</engine>
</engines>
</component>
TEXT
)
sudo echo "$MYKEYBOARD" | sudo tee /usr/share/ibus/component/mozc.xml ;

#-----------------------------------------------------------------------------------------------------------------------
# alias
#-----------------------------------------------------------------------------------------------------------------------
MYALIAS=$(cat<<TEXT
alias a="axel -a -n 10"
alias u='unar'
TEXT
)
echo "$MYALIAS" >> ~/.bashrc ;
source ~/.bashrc ;

#-----------------------------------------------------------------------------------------------------------------------
# reboot
#-----------------------------------------------------------------------------------------------------------------------
sudo apt autoremove -y ;
sudo reboot now ;
