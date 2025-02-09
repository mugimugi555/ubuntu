#!/bin/bash

echo "=== Xeon Phi に cURL (静的リンク) をインストール ==="

# バージョン指定
CURL_VERSION="8.5.0"

# 必要なツールをインストール
echo "=== 必要なツールをインストール（ホスト側） ==="
sudo apt update
sudo apt install -y build-essential wget

# 作業用ディレクトリの作成（ビルドは /tmp で実施）
mkdir -p /tmp/curl_build
cd /tmp/curl_build

# cURL のソースコードを取得
echo "=== cURL ${CURL_VERSION} のソースコードを取得 ==="
wget https://curl.se/download/curl-${CURL_VERSION}.tar.gz
tar xzf curl-${CURL_VERSION}.tar.gz
cd curl-${CURL_VERSION}

# cURL を静的リンクでビルド
echo "=== cURL を静的リンクでビルド ==="
./configure --prefix=$HOME/mic/bin --disable-shared --enable-static
make -j$(nproc)
make install

# cURL を Xeon Phi に転送
echo "=== cURL を Xeon Phi に転送 ==="
scp -r $HOME/mic/bin mic0:/home/mic/bin/

# Xeon Phi 側でインストール確認
echo "=== Xeon Phi 側で cURL のバージョン確認 ==="
ssh mic0 "/home/mic/bin/bin/curl --version"

# 作業ディレクトリの削除（オプション）
rm -rf /tmp/curl_build

echo "=== ビルド用ファイルをクリーンアップしました ==="
echo "=== Xeon Phi に cURL の静的リンクインストールが完了しました！ ==="
