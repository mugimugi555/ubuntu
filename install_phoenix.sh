#!/bin/bash

# ====================
# 必要なパッケージをインストール
# ====================
echo "必要なパッケージをインストールしています..."
sudo apt install -y libimobiledevice-utils ifuse usbmuxd ideviceinstaller wget unzip

# ====================
# 作業ディレクトリの準備
# ====================
cd 
mkdir myusbmuxd
cd myusbmuxd

# ====================
# 再度、必要なパッケージをインストール
# ====================
sudo apt install -y libimobiledevice-utils ifuse usbmuxd ideviceinstaller wget unzip

# ====================
# Phoenix.ipaをダウンロード
# ====================
echo "Phoenix.ipaをダウンロードしています..."
wget https://phoenixpwn.com/Phoenix.ipa -O Phoenix.ipa

# ====================
# Cydia Impactorのダウンロードと解凍
# ====================
echo "Cydia Impactorをダウンロードして解凍しています..."
unzip cydiaimpactor-latest-linux.zip -d cydiaimpactor

# ====================
# Impactorのダウンロードと解凍
# ====================
echo "Impactorをダウンロードして解凍しています..."
wget https://cache.saurik.com/impactor/l64/Impactor64_0.9.56.tgz
tar xvf Impactor64_0.9.56.tgz

# ====================
# Cydia Impactorに移動して実行権限を設定
# ====================
cd cydiaimpactor
chmod +x Impactor
ls
echo "Cydia Impactorを実行します..."
./Impactor 

# ====================
# libplist-devをインストール
# ====================
echo "libplist-devをインストールしています..."
sudo apt install -y libplist-dev

# ====================
# usbmuxdのソースコードをクローンしてインストール
# ====================
echo "usbmuxdをインストールしています..."
git clone https://github.com/libimobiledevice/usbmuxd.git
cd usbmuxd/
./autogen.sh
make
sudo make install
cd ..

# ====================
# 開発に必要なツールをインストール
# ====================
echo "autoconf, automake, libtool, pkg-configをインストールしています..."
sudo apt install autoconf automake libtool pkg-config

# ====================
# libplistのソースコードをクローンしてインストール
# ====================
echo "libplistをインストールしています..."
git clone https://github.com/libimobiledevice/libplist.git
cd libplist
./autogen.sh
make
sudo make install
cd ..

# ====================
# libimobiledevice-devをインストール
# ====================
echo "libimobiledevice-devをインストールしています..."
sudo apt install libimobiledevice-dev

# ====================
# libimobiledevice-glueのソースコードをクローンしてインストール
# ====================
echo "libimobiledevice-glueをインストールしています..."
git clone https://github.com/libimobiledevice/libimobiledevice-glue.git
cd libimobiledevice-glue
./autogen.sh 
make
sudo make install
cd ..

# ====================
# 最後にusbmuxdを再インストール
# ====================
echo "最後にusbmuxdを再インストールします..."
cd usbmuxd/
./autogen.sh 
make
sudo make install

# ====================
# 完了
# ====================
echo "インストールが完了しました！"
