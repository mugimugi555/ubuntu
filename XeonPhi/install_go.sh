#!/bin/bash

echo "=== Xeon Phi に Go (静的リンク版) をインストール ==="

# バージョン指定
GO_VERSION="1.21.1"
INSTALL_DIR="/home/mic/go-${GO_VERSION}"

# ホスト側でビルド
cd /tmp
echo "=== Go ${GO_VERSION} のソースコードを取得 ==="
wget https://go.dev/dl/go${GO_VERSION}.src.tar.gz
tar xzf go${GO_VERSION}.src.tar.gz
cd go/src

echo "=== Go を静的リンクでビルド ==="
env CGO_ENABLED=0 GOROOT_BOOTSTRAP=/usr/local/go ./make.bash

# Xeon Phi に転送
echo "=== Go を Xeon Phi に転送 ==="
scp -r /tmp/go mic0:/home/mic/go-${GO_VERSION}

# Xeon Phi 側で環境変数の設定 & インストール確認
echo "=== Xeon Phi 側で環境変数を設定 & インストール確認 ==="
ssh mic0 << 'EOF'
    GO_VERSION="1.21.1"
    INSTALL_DIR="/home/mic/go-${GO_VERSION}"

    # 環境変数を設定
    echo "export PATH=${INSTALL_DIR}/bin:\$PATH" >> ~/.bashrc
    echo "export GOROOT=${INSTALL_DIR}" >> ~/.bashrc
    echo "export GOPATH=/home/mic/go-workspace" >> ~/.bashrc
    echo "export GOBIN=\$GOPATH/bin" >> ~/.bashrc
    source ~/.bashrc

    # インストール確認
    echo "=== Xeon Phi 側で Go のバージョン確認 ==="
    go version
EOF

echo "=== Xeon Phi に Go の静的リンクインストールが完了しました！ ==="
