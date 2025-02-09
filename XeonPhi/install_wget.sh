#!/bin/bash

echo "=== wget をビルドして Xeon Phi に転送 ==="

# 必要なパッケージをホストPCにインストール
sudo apt update
sudo apt install -y build-essential libssl-dev libidn2-0-dev libpsl-dev libpcre2-dev

# wget のソースコードを取得
cd /tmp
wget https://ftp.gnu.org/gnu/wget/wget-1.21.3.tar.gz
tar xvf wget-1.21.3.tar.gz
cd wget-1.21.3

# wget をビルド
./configure --prefix=/home/mic/wget --with-ssl=openssl
make -j$(nproc)
make install

# Xeon Phi に転送
scp -r /home/mic/wget mic0:/home/mic/

# 動作確認
ssh mic0 "/home/mic/wget/bin/wget --version"

echo "=== wget のインストール完了 ==="
