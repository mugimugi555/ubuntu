#!/bin/bash

echo "=== Xeon Phi に Node.js (静的リンク) をインストール ==="

# バージョン指定
NODE_VERSION="20.11.0"

# 必要なツールをインストール
echo "=== 必要なツールをインストール（ホスト側） ==="
sudo apt update
sudo apt install -y build-essential python3 g++ make wget

### 1️⃣ ホスト側で Node.js のビルド & 転送 ###
echo "=== ホスト側で Node.js ${NODE_VERSION} のビルド開始 ==="

# 作業ディレクトリの作成（ビルドは /tmp で実施）
mkdir -p /tmp/node_build
cd /tmp/node_build

# ソースコードを取得
wget https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}.tar.gz
tar xzf node-v${NODE_VERSION}.tar.gz
cd node-v${NODE_VERSION}

# Node.js を静的リンクでビルド
echo "=== Node.js を静的リンクでビルド ==="
./configure --prefix=$HOME/mic/bin/node-${NODE_VERSION} --fully-static
make -j$(nproc)
make install

# Node.js を Xeon Phi に転送
echo "=== Node.js を Xeon Phi に転送 ==="
scp -r $HOME/mic/bin mic0:/home/mic/bin/

# 作業ディレクトリの削除（オプション）
rm -rf /tmp/node_build

echo "=== Node.js のビルド & クリーンアップ完了 ==="

---

### 2️⃣ Xeon Phi 側で環境変数の設定 & 確認 ###
echo "=== Xeon Phi 側で環境変数を設定 & インストール確認 ==="
ssh mic0 << 'EOF'
    NODE_VERSION="20.11.0"

    # 環境変数を設定
    echo "export PATH=/home/mic/bin/node-${NODE_VERSION}/bin:\$PATH" >> ~/.bashrc
    source ~/.bashrc

    # インストール確認
    echo "=== Xeon Phi 側で Node.js のバージョン確認 ==="
    node -v

    echo "=== Xeon Phi 側で npm のバージョン確認 ==="
    npm -v
EOF

echo "=== Xeon Phi に Node.js (静的リンク) のインストールが完了しました！ ==="
