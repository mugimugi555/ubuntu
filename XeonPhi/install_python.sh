#!/bin/bash

echo "=== Xeon Phi に Python 3.9.17 (静的リンク) をインストール ==="

# バージョン指定
PYTHON_VERSION="3.9.17"
INSTALL_DIR="$HOME/mic/bin/python-${PYTHON_VERSION}"

# 必要なライブラリをホストPCにインストール
echo "=== 必要なツールをインストール（ホスト側） ==="
sudo apt update
sudo apt install -y build-essential libssl-dev libffi-dev \
                    libbz2-dev libsqlite3-dev libreadline-dev libncurses5-dev \
                    libncursesw5-dev zlib1g-dev liblzma-dev wget

### 1️⃣ ホスト側で Python のビルド & 転送 ###
echo "=== ホスト側で Python ${PYTHON_VERSION} のビルド開始 ==="

# 作業ディレクトリの作成（ビルドは /tmp で実施）
mkdir -p /tmp/python_build
cd /tmp/python_build

# Python のソースコードを取得
wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz
tar xvf Python-${PYTHON_VERSION}.tgz
cd Python-${PYTHON_VERSION}

# Python を静的リンクでビルド
./configure --prefix=${INSTALL_DIR} --enable-optimizations LDFLAGS="-static"
make -j$(nproc)
make install

# Python を Xeon Phi に転送
echo "=== Python を Xeon Phi に転送 ==="
scp -r $HOME/mic/bin mic0:/home/mic/bin/

# 作業ディレクトリの削除（オプション）
rm -rf /tmp/python_build

echo "=== Python のビルド & クリーンアップ完了 ==="

---

### 2️⃣ Xeon Phi 側で環境変数の設定 & 確認 ###
echo "=== Xeon Phi 側で環境変数を設定 & インストール確認 ==="
ssh mic0 << 'EOF'
    PYTHON_VERSION="3.9.17"

    # 環境変数を設定
    echo "export PATH=/home/mic/bin/python-${PYTHON_VERSION}/bin:\$PATH" >> ~/.bashrc
    source ~/.bashrc

    # インストール確認
    echo "=== Xeon Phi 側で Python のバージョン確認 ==="
    python3 --version
EOF

echo "=== Xeon Phi に Python (静的リンク) のインストールが完了しました！ ==="

---

### 3️⃣ pip のインストール & パッケージ導入 ###
echo "=== pip のインストール & 必要なライブラリの導入 ==="

ssh mic0 << 'EOF'
    PYTHON_VERSION="3.9.17"

    # pip をインストール
    /home/mic/bin/python-${PYTHON_VERSION}/bin/python3 -m ensurepip
    /home/mic/bin/python-${PYTHON_VERSION}/bin/python3 -m pip install --upgrade pip

    # NumPy & OpenCV をインストール
    /home/mic/bin/python-${PYTHON_VERSION}/bin/python3 -m pip install numpy opencv-python-headless
EOF

echo "=== pip & ライブラリのインストール完了 ==="

---

### 4️⃣ Python スクリプトを Xeon Phi に転送 & 実行 ###
echo "=== Python の動作確認スクリプトを転送 & 実行 ==="

# `for_upload/` にある Python スクリプトを転送
scp for_upload/test_python.py mic0:/home/mic/

# Xeon Phi で Python スクリプトを実行
ssh mic0 "/home/mic/bin/python-${PYTHON_VERSION}/bin/python3 /home/mic/test_python.py"

### 5️⃣ 結果を取得 ###
echo "=== 実行結果を取得 ==="
scp mic0:/home/mic/test_python.py_result.txt .

echo "=== すべての処理が完了しました！ ==="
