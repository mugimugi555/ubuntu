#!/bin/bash

echo "=== Xeon Phi で UNIX Bench をインストール & 実行 ==="

# バージョン指定
UNIXBENCH_VERSION="5.1.3"
INSTALL_DIR="/home/mic/unixbench-${UNIXBENCH_VERSION}"

# 必要なツールをインストール
echo "=== 必要なツールをインストール（ホスト側） ==="
sudo apt update
sudo apt install -y build-essential perl wget

# 一時ディレクトリで作業
cd /tmp

# UNIX Bench のソースコードを取得
echo "=== UNIX Bench ${UNIXBENCH_VERSION} のソースコードを取得 ==="
wget https://byte-unixbench.googlecode.com/files/unixbench-${UNIXBENCH_VERSION}.tar.gz
tar xzf unixbench-${UNIXBENCH_VERSION}.tar.gz
cd unixbench-${UNIXBENCH_VERSION}

# UNIX Bench をビルド
echo "=== UNIX Bench をビルド ==="
make -j$(nproc)

# Xeon Phi に転送
echo "=== UNIX Bench を Xeon Phi に転送 ==="
scp -r . mic0:/home/mic/unixbench-${UNIXBENCH_VERSION}

# Xeon Phi 側で環境変数の設定 & インストール確認
echo "=== Xeon Phi 側で環境変数を設定 & ベンチマーク実行 ==="
ssh mic0 << 'EOF'
    UNIXBENCH_VERSION="5.1.3"
    INSTALL_DIR="/home/mic/unixbench-${UNIXBENCH_VERSION}"

    # 環境変数を設定
    echo "export PATH=${INSTALL_DIR}/bin:\$PATH" >> ~/.bashrc
    source ~/.bashrc

    # Xeon Phi のスレッドを最大利用
    export OMP_NUM_THREADS=240

    # UNIX Bench を実行
    echo "=== UNIX Bench のベンチマークを開始 ==="
    cd ${INSTALL_DIR}
    ./Run -c 240

    echo "=== Xeon Phi での UNIX Bench ベンチマーク完了！ ==="
EOF

echo "=== Xeon Phi で UNIX Bench の実行が完了しました！ ==="
