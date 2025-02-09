#!/bin/bash

echo "=== Emacs を静的リンクでビルド & Xeon Phi に転送 ==="

# バージョン指定
EMACS_VERSION="28.2"

# 必要なパッケージをホストPCにインストール
sudo apt update
sudo apt install -y build-essential libncurses-dev wget

# 作業用ディレクトリの作成（ビルドは /tmp で実施）
mkdir -p /tmp/emacs_build
cd /tmp/emacs_build

# Emacs のソースコードを取得
echo "=== Emacs ${EMACS_VERSION} のソースコードを取得 ==="
wget https://ftp.gnu.org/gnu/emacs/emacs-${EMACS_VERSION}.tar.gz
tar xvf emacs-${EMACS_VERSION}.tar.gz
cd emacs-${EMACS_VERSION}

# Emacs を静的リンクでビルド
echo "=== Emacs を静的リンクでビルド ==="
./configure --prefix=$HOME/mic/bin/emacs-${EMACS_VERSION} --without-x --without-sound LDFLAGS="-static"
make -j$(nproc)
make install

# Emacs を Xeon Phi に転送
echo "=== Emacs を Xeon Phi に転送 ==="
scp -r $HOME/mic/bin mic0:/home/mic/bin/

# Xeon Phi 側でインストール確認
echo "=== Xeon Phi 側で Emacs のバージョン確認 ==="
ssh mic0 "/home/mic/bin/emacs-${EMACS_VERSION}/bin/emacs --version"

# 作業ディレクトリの削除（オプション）
rm -rf /tmp/emacs_build

echo "=== ビルド用ファイルをクリーンアップしました ==="
echo "=== Xeon Phi に Emacs の静的リンクインストールが完了しました！ ==="
