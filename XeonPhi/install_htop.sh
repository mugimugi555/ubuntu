#!/bin/bash

echo "=== Xeon Phi に htop (静的リンク) をインストール ==="

# バージョン指定
HTOP_VERSION="3.2.2"

# 必要なツールをインストール
echo "=== 必要なツールをインストール（ホスト側） ==="
sudo apt update
sudo apt install -y build-essential libncurses-dev wget

### 1️⃣ ホスト側で htop のビルド & 転送 ###
echo "=== ホスト側で htop ${HTOP_VERSION} のビルド開始 ==="

# 作業ディレクトリの作成（ビルドは /tmp で実施）
mkdir -p /tmp/htop_build
cd /tmp/htop_build

# ソースコードを取得
wget https://github.com/htop-dev/htop/releases/download/${HTOP_VERSION}/htop-${HTOP_VERSION}.tar.gz
tar xzf htop-${HTOP_VERSION}.tar.gz
cd htop-${HTOP_VERSION}

# htop を静的リンクでビルド
echo "=== htop を静的リンクでビルド ==="
./configure --prefix=$HOME/mic/bin/htop-${HTOP_VERSION} --disable-shared LDFLAGS="-static"
make -j$(nproc)
make install

# htop を Xeon Phi に転送
echo "=== htop を Xeon Phi に転送 ==="
scp -r $HOME/mic/bin mic0:/home/mic/bin/

# 作業ディレクトリの削除（オプション）
rm -rf /tmp/htop_build

echo "=== htop のビルド & クリーンアップ完了 ==="

---

### 2️⃣ Xeon Phi 側で環境変数の設定 & 確認 ###
echo "=== Xeon Phi 側で環境変数を設定 & インストール確認 ==="
ssh mic0 << 'EOF'
    HTOP_VERSION="3.2.2"

    # 環境変数を設定
    echo "export PATH=/home/mic/bin/htop-${HTOP_VERSION}/bin:\$PATH" >> ~/.bashrc
    source ~/.bashrc

    # インストール確認
    echo "=== Xeon Phi 側で htop のバージョン確認 ==="
    htop --version
EOF

echo "=== Xeon Phi に htop の静的リンクインストールが完了しました！ ==="
