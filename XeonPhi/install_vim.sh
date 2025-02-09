#!/bin/bash

echo "=== Vim を静的リンクでビルド & Xeon Phi に転送 ==="

# バージョン指定
VIM_VERSION="9.0.1800"
INSTALL_DIR="$HOME/mic/bin/vim"

# 必要なパッケージをホストPCにインストール
echo "=== 必要なパッケージをインストール（ホスト側） ==="
sudo apt update
sudo apt install -y build-essential ncurses-dev wget

### 1️⃣ ホスト側で Vim のビルド & 転送 ###
echo "=== ホスト側で Vim ${VIM_VERSION} のビルド開始 ==="

# 作業ディレクトリの作成（ビルドは /tmp で実施）
mkdir -p /tmp/vim_build
cd /tmp/vim_build

# Vim のソースコードを取得
wget https://github.com/vim/vim/archive/refs/tags/v${VIM_VERSION}.tar.gz -O vim.tar.gz
tar xzf vim.tar.gz
cd vim-*

# Vim をビルド
echo "=== Vim を静的リンクでビルド ==="
./configure --prefix=${INSTALL_DIR} --disable-gui --without-x --enable-multibyte --with-tlib=ncurses LDFLAGS="-static"
make -j$(nproc)
make install

# Vim を Xeon Phi に転送
echo "=== Vim を Xeon Phi に転送 ==="
scp -r ${INSTALL_DIR} mic0:/home/mic/bin/

# 作業ディレクトリの削除（オプション）
rm -rf /tmp/vim_build

echo "=== Vim のビルド & クリーンアップ完了 ==="

---

### 2️⃣ Xeon Phi 側で環境変数の設定 & 動作確認 ###
echo "=== Xeon Phi 側で環境変数を設定 & Vim の確認 ==="
ssh mic0 << 'EOF'
    VIM_INSTALL_DIR="/home/mic/bin/vim"

    # 環境変数を設定
    echo "export PATH=${VIM_INSTALL_DIR}/bin:\$PATH" >> ~/.bashrc
    source ~/.bashrc

    # インストール確認
    echo "=== Xeon Phi 側で Vim のバージョン確認 ==="
    vim --version
EOF

echo "=== Xeon Phi に Vim の静的リンクインストールが完了しました！ ==="
