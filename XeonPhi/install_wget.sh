#!/bin/bash

echo "=== wget を静的リンクでビルド & Xeon Phi に転送 ==="

# バージョン指定
WGET_VERSION="1.21.3"
INSTALL_DIR="$HOME/mic/bin/wget"

# 必要なパッケージをホストPCにインストール
echo "=== 必要なパッケージをインストール（ホスト側） ==="
sudo apt update
sudo apt install -y build-essential libssl-dev libidn2-0-dev libpsl-dev libpcre2-dev wget

### 1️⃣ ホスト側で wget のビルド & 転送 ###
echo "=== ホスト側で wget ${WGET_VERSION} のビルド開始 ==="

# 作業ディレクトリの作成（ビルドは /tmp で実施）
mkdir -p /tmp/wget_build
cd /tmp/wget_build

# wget のソースコードを取得
wget https://ftp.gnu.org/gnu/wget/wget-${WGET_VERSION}.tar.gz
tar xzf wget-${WGET_VERSION}.tar.gz
cd wget-${WGET_VERSION}

# wget を静的リンクでビルド
echo "=== wget を静的リンクでビルド ==="
./configure --prefix=${INSTALL_DIR} --with-ssl=openssl --disable-shared LDFLAGS="-static"
make -j$(nproc)
make install

# wget を Xeon Phi に転送
echo "=== wget を Xeon Phi に転送 ==="
scp -r ${INSTALL_DIR} mic0:/home/mic/bin/

# 作業ディレクトリの削除（オプション）
rm -rf /tmp/wget_build

echo "=== wget のビルド & クリーンアップ完了 ==="

---

### 2️⃣ Xeon Phi 側で環境変数の設定 & 動作確認 ###
echo "=== Xeon Phi 側で環境変数を設定 & wget の確認 ==="
ssh mic0 << 'EOF'
    WGET_INSTALL_DIR="/home/mic/bin/wget"

    # 環境変数を設定
    echo "export PATH=${WGET_INSTALL_DIR}/bin:\$PATH" >> ~/.bashrc
    source ~/.bashrc

    # インストール確認
    echo "=== Xeon Phi 側で wget のバージョン確認 ==="
    wget --version
EOF

echo "=== Xeon Phi に wget の静的リンクインストールが完了しました！ ==="
