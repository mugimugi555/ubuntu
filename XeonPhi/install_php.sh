#!/bin/bash

echo "=== PHP を静的リンクでビルド & Xeon Phi に転送 ==="

# 必要なパッケージをホストPCにインストール
sudo apt update
sudo apt install -y build-essential autoconf bison re2c \
                    libxml2-dev libsqlite3-dev libcurl4-openssl-dev \
                    libjpeg-dev libpng-dev libxpm-dev libfreetype6-dev libzip-dev

# PHP のソースコードを取得
cd /tmp
wget https://www.php.net/distributions/php-8.2.6.tar.gz
tar xvf php-8.2.6.tar.gz
cd php-8.2.6

# PHP を静的リンクでビルド
./configure --prefix=/home/mic/php --disable-all --enable-cli LDFLAGS="-static"
make -j$(nproc)
make install

# Xeon Phi に転送
scp -r /home/mic/php mic0:/home/mic/

# 動作確認
ssh mic0 "/home/mic/php/bin/php -v"

echo "=== PHP のインストール完了 ==="
