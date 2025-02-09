#!/bin/bash

echo "=== Xeon Phi に PHP (静的リンク) をインストール ==="

# バージョン指定
PHP_VERSION="8.2.6"
INSTALL_DIR="$HOME/mic/bin/php-${PHP_VERSION}"

# 必要なライブラリをホストPCにインストール
echo "=== 必要なツールをインストール（ホスト側） ==="
sudo apt update
sudo apt install -y build-essential autoconf bison re2c \
                    libxml2-dev libsqlite3-dev libcurl4-openssl-dev \
                    libjpeg-dev libpng-dev libxpm-dev libfreetype6-dev libzip-dev

### 1️⃣ ホスト側で PHP のビルド & 転送 ###
echo "=== ホスト側で PHP ${PHP_VERSION} のビルド開始 ==="

# 作業ディレクトリの作成（ビルドは /tmp で実施）
mkdir -p /tmp/php_build
cd /tmp/php_build

# PHP のソースコードを取得
wget https://www.php.net/distributions/php-${PHP_VERSION}.tar.gz
tar xvf php-${PHP_VERSION}.tar.gz
cd php-${PHP_VERSION}

# PHP を静的リンクでビルド
./configure --prefix=${INSTALL_DIR} --disable-all --enable-cli LDFLAGS="-static"
make -j$(nproc)
make install

# PHP を Xeon Phi に転送
echo "=== PHP を Xeon Phi に転送 ==="
scp -r $HOME/mic/bin mic0:/home/mic/bin/

# 作業ディレクトリの削除（オプション）
rm -rf /tmp/php_build

echo "=== PHP のビルド & クリーンアップ完了 ==="

---

### 2️⃣ Xeon Phi 側で環境変数の設定 & 確認 ###
echo "=== Xeon Phi 側で環境変数を設定 & インストール確認 ==="
ssh mic0 << 'EOF'
    PHP_VERSION="8.2.6"

    # 環境変数を設定
    echo "export PATH=/home/mic/bin/php-${PHP_VERSION}/bin:\$PATH" >> ~/.bashrc
    source ~/.bashrc

    # インストール確認
    echo "=== Xeon Phi 側で PHP のバージョン確認 ==="
    php -v
EOF

echo "=== Xeon Phi に PHP (静的リンク) のインストールが完了しました！ ==="
