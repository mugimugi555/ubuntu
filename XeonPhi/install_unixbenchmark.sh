#!/bin/bash

echo "=== Xeon Phi で UNIX Bench をインストール & 実行 ==="

# バージョン指定
UNIXBENCH_VERSION="5.1.3"
INSTALL_DIR="$HOME/mic/bin/unixbench-${UNIXBENCH_VERSION}"

# 必要なツールをインストール
echo "=== 必要なツールをインストール（ホスト側） ==="
sudo apt update
sudo apt install -y build-essential perl wget

### 1️⃣ ホスト側で UNIX Bench のビルド & 転送 ###
echo "=== ホスト側で UNIX Bench ${UNIXBENCH_VERSION} のビルド開始 ==="

# 作業ディレクトリの作成（ビルドは /tmp で実施）
mkdir -p /tmp/unixbench_build
cd /tmp/unixbench_build

# UNIX Bench のソースコードを取得
wget https://byte-unixbench.googlecode.com/files/unixbench-${UNIXBENCH_VERSION}.tar.gz
tar xzf unixbench-${UNIXBENCH_VERSION}.tar.gz
cd unixbench-${UNIXBENCH_VERSION}

# UNIX Bench をビルド
echo "=== UNIX Bench をビルド ==="
make -j$(nproc)

# UNIX Bench を Xeon Phi に転送
echo "=== UNIX Bench を Xeon Phi に転送 ==="
scp -r $HOME/mic/bin mic0:/home/mic/bin/

# 作業ディレクトリの削除（オプション）
rm -rf /tmp/unixbench_build

echo "=== UNIX Bench のビルド & クリーンアップ完了 ==="

---

### 2️⃣ Xeon Phi 側で環境変数の設定 & ベンチマーク実行 ###
echo "=== Xeon Phi 側で環境変数を設定 & ベンチマーク実行 ==="
ssh mic0 << 'EOF'
    UNIXBENCH_VERSION="5.1.3"

    # 環境変数を設定
    echo "export PATH=/home/mic/bin/unixbench-${UNIXBENCH_VERSION}/:\$PATH" >> ~/.bashrc
    source ~/.bashrc

    # Xeon Phi のスレッドを最大利用
    export OMP_NUM_THREADS=240

    # UNIX Bench を実行
    echo "=== UNIX Bench のベンチマークを開始 ==="
    cd /home/mic/bin/unixbench-${UNIXBENCH_VERSION}
    ./Run -c 240

    echo "=== Xeon Phi での UNIX Bench ベンチマーク完了！ ==="
EOF

echo "=== Xeon Phi で UNIX Bench の実行が完了しました！ ==="
