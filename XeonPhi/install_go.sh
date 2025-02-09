#!/bin/bash

echo "=== Xeon Phi に Go (静的リンク版) をインストール ==="

# バージョン指定
GO_VERSION="1.21.1"

# 必要なパッケージをホストPCにインストール
sudo apt update
sudo apt install -y build-essential wget

### 1️⃣ ホスト側で Go のビルド & 転送 ###
echo "=== ホスト側で Go ${GO_VERSION} のビルド開始 ==="

# 作業ディレクトリの作成（ビルドは /tmp で実施）
mkdir -p /tmp/go_build
cd /tmp/go_build

# Go のソースコードを取得
wget https://go.dev/dl/go${GO_VERSION}.src.tar.gz
tar xzf go${GO_VERSION}.src.tar.gz
cd go/src

# Go を静的リンクでビルド
echo "=== Go を静的リンクでビルド ==="
env CGO_ENABLED=0 GOROOT_BOOTSTRAP=/usr/local/go ./make.bash

# インストールディレクトリを `$HOME/mic/bin/go-${GO_VERSION}` に変更
mkdir -p $HOME/mic/bin/go-${GO_VERSION}
cp -r /tmp/go/* $HOME/mic/bin/go-${GO_VERSION}/

# Go を Xeon Phi に転送
echo "=== Go を Xeon Phi に転送 ==="
scp -r $HOME/mic/bin mic0:/home/mic/bin/

# 作業ディレクトリの削除（オプション）
rm -rf /tmp/go_build

echo "=== Go のビルド & クリーンアップ完了 ==="

---

### 2️⃣ Xeon Phi 側で環境変数の設定 & 確認 ###
echo "=== Xeon Phi 側で環境変数を設定 & インストール確認 ==="
ssh mic0 << 'EOF'
    GO_VERSION="1.21.1"

    # 環境変数を設定
    echo "export PATH=/home/mic/bin/go-${GO_VERSION}/bin:\$PATH" >> ~/.bashrc
    echo "export GOROOT=/home/mic/bin/go-${GO_VERSION}" >> ~/.bashrc
    echo "export GOPATH=/home/mic/go-workspace" >> ~/.bashrc
    echo "export GOBIN=\$GOPATH/bin" >> ~/.bashrc
    source ~/.bashrc

    # インストール確認
    echo "=== Xeon Phi 側で Go のバージョン確認 ==="
    go version
EOF

echo "=== Xeon Phi に Go の静的リンクインストールが完了しました！ ==="
