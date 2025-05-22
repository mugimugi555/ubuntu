#!/bin/bash
set -e

# wget https://raw.githubusercontent.com/mugimugi555/ubuntu/main/install.sh && bash install.sh ;

# ======================= 基本設定と初期化 =======================

# ホームディレクトリ名を英語に
echo "🔹 ホームディレクトリ名を英語に変更します。"
LANG=C xdg-user-dirs-update --force

# Gnome の基本設定
echo "🔹 GNOME 設定を適用します。"
gsettings set org.gnome.desktop.interface enable-animations false
gsettings set org.gnome.desktop.session idle-delay 0
gsettings set org.gnome.settings-daemon.plugins.power idle-dim false
gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 30

# APT のフェーズアップデート設定
echo "🔹 APT の設定を追加します。"
echo 'APT::Get::Always-Include-Phased-Updates "true";' | sudo tee /etc/apt/apt.conf.d/99include-phased-updates

# sudo タイムアウト延長
echo "🔹 sudo のタイムアウトを延長します。"
echo 'Defaults timestamp_timeout = 1200' | sudo EDITOR='tee -a' visudo

# 壁紙変更
echo "🔹 壁紙をダウンロードして設定します。"
wget http://gahag.net/img/201602/11s/gahag-0055029460-1.jpg -O "$HOME/Pictures/1.jpg"
gsettings set org.gnome.desktop.background picture-uri "file://$HOME/Pictures/1.jpg"

# ======================= EULA/ウィザード抑制 =======================
echo "🔹 フォントと Postfix のウィザードを回避設定します。"
echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" \
  | sudo debconf-set-selections
echo "postfix postfix/mailname string localhost" | sudo debconf-set-selections
echo "postfix postfix/main_mailer_type string 'No configuration'" | sudo debconf-set-selections

echo "✅ ms-fonts と postfix のウィザード回避済み"

# ======================= 基本ソフトウェア =======================
echo "🔹 基本ソフトウェアをインストールします。"
sudo apt update && sudo apt upgrade -y

# システムユーティリティ
echo "🔹 システムユーティリティをインストールします。"
sudo apt install -y unzip curl htop git axel samba openssh-server net-tools exfat-fuse

echo "🔹 エディタをインストールします。"
sudo apt install -y emacs-nox gedit

# メディア関連ツール
echo "🔹 メディア関連ツールをインストールします。"
sudo apt install -y ffmpeg imagemagick lame vlc unar

# Snapアプリ
echo "🔹 Snap アプリをインストールします。"
sudo snap install kdiskmark && sudo snap connect kdiskmark:removable-media
sudo snap install losslesscut && sudo snap connect losslesscut:removable-media
sudo snap install --classic code
sudo snap install --classic gimp
sudo snap install --edge yt-dlp

# ======================= ブラウザと Snap 削除 =======================
echo "🔹 Snap版 Firefox を削除します。"
sudo snap remove firefox || true

echo "🔹 Braveブラウザをインストールします。"
sudo apt install -y curl
curl -fsS https://dl.brave.com/install.sh | sh

echo "🔹 Google Chrome をインストールします。"
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O chrome.deb
sudo apt install -y ./chrome.deb

# ======================= ロケール・日本語設定 =======================
echo "🔹 日本語環境をインストールします。"
sudo apt install -y ibus-mozc manpages-ja manpages-ja-dev gnome-tweaks ubuntu-restricted-extras

echo "🔹 ロケールと言語設定を適用します。"
sudo update-locale LANG=ja_JP.UTF8
sudo ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
sudo mkdir -p /usr/share/locale-langpack/ja
sudo apt install -y language-pack-gnome-ja language-pack-gnome-ja-base language-pack-ja language-pack-ja-base \
  fonts-takao-gothic fonts-takao-mincho $(check-language-support)

# ======================= システム設定 =======================
echo "🔹 NTP 設定やフォント設定します。"
sudo sed -i 's/#NTP=/NTP=ntp.nict.jp/g' /etc/systemd/timesyncd.conf

gsettings set org.gnome.desktop.interface font-name 'Noto Sans CJK JP 11'
gsettings set org.gnome.mutter auto-maximize false
gsettings set org.gnome.shell favorite-apps "['brave-browser.desktop', 'google-chrome.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop', 'gedit.desktop', 'gnome-control-center.desktop']"

# HDDスリープ設定
echo "🔹 HDD スリープ設定します。"
sudo hdparm -S 242 /dev/sd*

# ======================= 日本語入力 Mozc 設定 =======================
echo "🔹 日本語入力 Mozc の設定します。"
cat <<EOF | sudo tee /etc/default/keyboard
BACKSPACE="guess"
XKBMODEL="pc105"
XKBLAYOUT="jp"
XKBVARIANT=""
XKBOPTIONS="ctrl:nocaps"
EOF

cat <<EOF | sudo tee /usr/share/ibus/component/mozc.xml
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
EOF

# ======================= エイリアス追加 =======================
echo "🔹 エイリアスを追加します。"
cat <<EOF >> ~/.bashrc

# myalias
alias a="axel -a -n 10"
alias u='unar'
alias up='sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y ; sudo snap refresh'
EOF

# ======================= 終了処理 =======================
echo "🔹 不要なパッケージを削除します。"
sudo apt autoremove -y

echo "🔄 再起動します..."
sudo reboot now
