#!/bin/bash

echo "=== Emacs を静的リンクでビルド & Xeon Phi に転送 ==="

# 必要なパッケージをホストPCにインストール
sudo apt update
sudo apt install -y build-essential libncurses-dev

# Emacs のソースコードを取得
cd /tmp
wget https://ftp.gnu.org/gnu/emacs/emacs-28.2.tar.gz
tar xvf emacs-28.2.tar.gz
cd emacs-28.2

# Emacs を静的リンクでビルド
./configure --prefix=/home/mic/emacs --without-x --without-sound LDFLAGS="-static"
make -j$(nproc)
make install

# Xeon Phi に転送
scp -r /home/mic/emacs mic0:/home/mic/

# 動作確認
ssh mic0 "/home/mic/emacs/bin/emacs --version"

echo "=== Emacs のインストール完了 ==="
