#!/bin/bash

echo "=== Vim をビルドして Xeon Phi に転送 ==="

# 必要なパッケージをホストPCにインストール
sudo apt update
sudo apt install -y build-essential ncurses-dev

# Vim のソースコードを取得
cd /tmp
wget https://github.com/vim/vim/archive/refs/tags/v9.0.1800.tar.gz -O vim.tar.gz
tar xvf vim.tar.gz
cd vim-*

# Vim をビルド
./configure --prefix=/home/mic/vim --disable-gui --without-x
make -j$(nproc)
make install

# Xeon Phi に転送
scp -r /home/mic/vim mic0:/home/mic/

# 動作確認
ssh mic0 "/home/mic/vim/bin/vim --version"

echo "=== Vim のインストール完了 ==="
