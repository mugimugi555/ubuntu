#!/bin/bash

echo "=== Xeon Phi に htop (静的リンク) をインストール ==="

# バージョン指定
HTOP_VERSION="3.2.2"
INSTALL_DIR="/home/mic/htop-${HTOP_VERSION}"

# 必要なツールをインストール
echo "=== 必要なツールをインストール（ホスト側） ==="
sudo apt update
sudo apt install -y build-essential libncurses-dev wget

# 一時ディレクトリで作業
cd /tmp

# ソースコードを取得
echo "=== htop ${HTOP_VERSION} のソースコードを取得 ==="
wget https://github.com/htop-dev/htop/releases/download/${HTOP_VERSION}/htop-${HTOP_VERSION}.tar.gz
tar xzf htop-${HTOP_VERSION}.tar.gz
cd htop-${HTOP_VERSION}

# コンパイル & 静的リンクでビルド
echo "=== htop を静的リンクでビルド ==="
./configure --prefix=${INSTALL_DIR} --disable-shared LDFLAGS="-static"
make -j$(nproc)

# Xeon Phi に転送
echo "=== htop を Xeon Phi に転送 ==="
scp htop mic0:/home/mic/

# Xeon Phi 側でインストール
echo "=== Xeon Phi 側で htop をインストール ==="
ssh mic0 << 'EOF'
    HTOP_VERSION="3.2.2"
    INSTALL_DIR="/home/mic/htop-${HTOP_VERSION}"

    echo "=== Xeon Phi 側で htop をセットアップ ==="
    mkdir -p ${INSTALL_DIR}/bin
    mv /home/mic/htop ${INSTALL_DIR}/bin/
    chmod +x ${INSTALL_DIR}/bin/htop

    # 環境変数を設定
    echo "export PATH=${INSTALL_DIR}/bin:\$PATH" >> ~/.bashrc
    source ~/.bashrc

    # インストール確認
    echo "=== Xeon Phi 側で htop のインストール確認 ==="
    htop --version
EOF

echo "=== Xeon Phi に htop の静的リンクインストールが完了しました！ ==="
