#!/bin/bash

# ====================
# 必要なパッケージをインストール
# ====================
echo "必要なパッケージをインストールしています..."
sudo apt install -y libimobiledevice-utils ifuse usbmuxd ideviceinstaller wget unzip

# ====================
# 作業ディレクトリの準備
# ====================
echo "作業ディレクトリを準備しています..."
cd 
mkdir myusbmuxd  # usbmuxd用のディレクトリを作成
cd myusbmuxd

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
chmod +x Impactor  # Impactorに実行権限を付与
ls  # ファイルリストを表示
echo "Cydia Impactorを実行します..."
./Impactor  # Cydia Impactorを実行

# ====================
# libplist-devをインストール
# ====================
echo "libplist-devをインストールしています..."
sudo apt install -y libplist-dev  # libplist-devパッケージをインストール

# ====================
# usbmuxdのソースコードをクローンしてインストール
# ====================
echo "usbmuxdをインストールしています..."
git clone https://github.com/libimobiledevice/usbmuxd.git  # usbmuxdのソースをクローン
cd usbmuxd/
./autogen.sh  # 自動生成スクリプトを実行
make  # ソースコードをコンパイル
sudo make install  # インストール
cd ..

# ====================
# 開発に必要なツールをインストール
# ====================
echo "autoconf, automake, libtool, pkg-configをインストールしています..."
sudo apt install autoconf automake libtool pkg-config  # 開発ツールをインストール

# ====================
# libplistのソースコードをクローンしてインストール
# ====================
echo "libplistをインストールしています..."
git clone https://github.com/libimobiledevice/libplist.git  # libplistのソースをクローン
cd libplist
./autogen.sh  # 自動生成スクリプトを実行
make  # ソースコードをコンパイル
sudo make install  # インストール
cd ..

# ====================
# libimobiledevice-devをインストール
# ====================
echo "libimobiledevice-devをインストールしています..."
sudo apt install libimobiledevice-dev  # libimobiledevice-devパッケージをインストール

# ====================
# libimobiledevice-glueのソースコードをクローンしてインストール
# ====================
echo "libimobiledevice-glueをインストールしています..."
git clone https://github.com/libimobiledevice/libimobiledevice-glue.git  # libimobiledevice-glueのソースをクローン
cd libimobiledevice-glue
./autogen.sh  # 自動生成スクリプトを実行
make  # ソースコードをコンパイル
sudo make install  # インストール
cd ..

# ====================
# 最後にusbmuxdを再インストール
# ====================
echo "最後にusbmuxdを再インストールします..."
cd usbmuxd/
./autogen.sh  # 自動生成スクリプトを実行
make  # ソースコードをコンパイル
sudo make install  # インストール
cd ..

# ====================
# libncurses5をインストール（Impactor実行のため）
# ====================
echo "libncurses5をインストールしています..."
sudo apt install -y libncurses5  # libncurses5パッケージをインストール

# ====================
# 最後にImpactorを実行
# ====================
echo "Impactorを実行します..."
./Impactor  # Cydia Impactorを実行

# ====================
# 完了
# ====================
echo "インストールが完了しました！"  # 完了メッセージ
