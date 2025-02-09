#!/bin/bash

echo "=== Xeon Phi に cURL (静的リンク) をインストール ==="

# バージョン指定
CURL_VERSION="8.5.0"
INSTALL_DIR="/home/mic/curl-${CURL_VERSION}"

# 必要なツールをインストール
echo "=== 必要なツールをインストール（ホスト側） ==="
sudo apt update
sudo apt install -y build-essential wget

# 一時ディレクトリで作業
cd /tmp

# cURL のソースコードを取得
echo "=== cURL ${CURL_VERSION} のソースコードを取得 ==="
wget https://curl.se/download/curl-${CURL_VERSION}.tar.gz
tar xzf curl-${CURL_VERSION}.tar.gz
cd curl-${CURL_VERSION}

# cURL を静的リンクでビルド
echo "=== cURL を静的リンクでビルド ==="
./configure --prefix=${INSTALL_DIR} --disable-shared --enable-static
make -j$(nproc)
make install

# Xeon Phi に転送
echo "=== cURL を Xeon Phi に転送 ==="
scp -r ${INSTALL_DIR} mic0:/home/mic/

# Xeon Phi 側で環境変数の設定 & インストール確認
echo "=== Xeon Phi 側で環境変数を設定 & インストール確認 ==="
ssh mic0 << 'EOF'
    CURL_VERSION="8.5.0"
    INSTALL_DIR="/home/mic/curl-${CURL_VERSION}"

    # 環境変数を設定
    echo "export PATH=${INSTALL_DIR}/bin:\$PATH" >> ~/.bashrc
    source ~/.bashrc

    # インストール確認
    echo "=== Xeon Phi 側で cURL のバージョン確認 ==="
    curl --version
EOF

echo "=== Xeon Phi に cURL の静的リンクインストールが完了しました！ ==="
