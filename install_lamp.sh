#!/bin/bash

#-----------------------------------------------------------------------------------------------------------------------
# LAMP 環境の最新 PHP をインストールするスクリプト
#-----------------------------------------------------------------------------------------------------------------------

echo "✅ Ubuntu LAMP スタック & 最新 PHP インストール開始..."

#-----------------------------------------------------------------------------------------------------------------------
# 必要なリポジトリを追加
#-----------------------------------------------------------------------------------------------------------------------
sudo apt update && sudo apt upgrade -y
sudo apt install -y ca-certificates apt-transport-https software-properties-common wget curl lsb-release

# PHP の公式リポジトリ追加（最新バージョンを取得可能にする）
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update

#-----------------------------------------------------------------------------------------------------------------------
# 最新の PHP のバージョンを取得
#-----------------------------------------------------------------------------------------------------------------------
LATEST_PHP_VERSION=$(apt-cache search php | grep -oP '^php[0-9]+\.[0-9]+' | sort -V | tail -n 1 | sed 's/php//')
echo "✅ 最新の PHP バージョン: $LATEST_PHP_VERSION"

#-----------------------------------------------------------------------------------------------------------------------
# Apache, 最新 PHP, MySQL をインストール
#-----------------------------------------------------------------------------------------------------------------------
sudo apt install -y \
  apache2 \
  php$LATEST_PHP_VERSION php$LATEST_PHP_VERSION-fpm \
  php$LATEST_PHP_VERSION-mbstring php$LATEST_PHP_VERSION-mysql php$LATEST_PHP_VERSION-curl \
  php$LATEST_PHP_VERSION-gd php$LATEST_PHP_VERSION-zip php$LATEST_PHP_VERSION-xml \
  mariadb-server

#-----------------------------------------------------------------------------------------------------------------------
# Apache で PHP-FPM を有効化
#-----------------------------------------------------------------------------------------------------------------------
sudo apt install -y libapache2-mod-fcgid
sudo a2enmod proxy_fcgi setenvif
sudo a2enconf php$LATEST_PHP_VERSION-fpm
sudo systemctl restart apache2

#-----------------------------------------------------------------------------------------------------------------------
# テストページの作成
#-----------------------------------------------------------------------------------------------------------------------
sudo rm -f /var/www/html/index.html
echo "<?php phpinfo();" | sudo tee /var/www/html/index.php > /dev/null

LOCAL_IPADDRESS=$(hostname -I | awk '{print $1}')
echo "======================================"
echo "🚀 PHP $LATEST_PHP_VERSION がインストールされました！"
echo "🌐 サイトを開く => http://$LOCAL_IPADDRESS/"
echo "======================================"

# 自動でブラウザを開く（GUI 環境の場合）
if command -v xdg-open &> /dev/null; then
    xdg-open http://$LOCAL_IPADDRESS/ &
fi
