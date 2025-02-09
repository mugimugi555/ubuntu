#!/bin/bash

echo "=== Xeon Phi に Node.js (静的リンク) をインストール ==="

# バージョン指定
NODE_VERSION="20.11.0"
INSTALL_DIR="/home/mic/node-${NODE_VERSION}"

# 必要なツールをインストール
echo "=== 必要なツールをインストール（ホスト側） ==="
sudo apt update
sudo apt install -y build-essential python3 g++ make wget

# 一時ディレクトリで作業
cd /tmp

# Node.js のソースコードを取得
echo "=== Node.js ${NODE_VERSION} のソースコードを取得 ==="
wget https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}.tar.gz
tar xzf node-v${NODE_VERSION}.tar.gz
cd node-v${NODE_VERSION}

# Node.js を静的リンクでビルド
echo "=== Node.js を静的リンクでビルド ==="
./configure --prefix=${INSTALL_DIR} --fully-static
make -j$(nproc)
make install

# Xeon Phi に転送
echo "=== Node.js を Xeon Phi に転送 ==="
scp -r ${INSTALL_DIR} mic0:/home/mic/

# Xeon Phi 側で環境変数の設定 & インストール確認
echo "=== Xeon Phi 側で環境変数を設定 & インストール確認 ==="
ssh mic0 << 'EOF'
    NODE_VERSION="20.11.0"
    INSTALL_DIR="/home/mic/node-${NODE_VERSION}"

    # 環境変数を設定
    echo "export PATH=${INSTALL_DIR}/bin:\$PATH" >> ~/.bashrc
    source ~/.bashrc

    # インストール確認
    echo "=== Xeon Phi 側で Node.js のバージョン確認 ==="
    node -v

    echo "=== Xeon Phi 側で npm のバージョン確認 ==="
    npm -v
EOF

echo "=== Xeon Phi に Node.js (静的リンク) のインストールが完了しました！ ==="
