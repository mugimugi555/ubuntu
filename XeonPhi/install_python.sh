#!/bin/bash

echo "=== Python 3.9+ を静的リンクでビルド & Xeon Phi に転送 ==="

### 1️⃣ 必要なライブラリをホストPCにインストール ###
echo "=== ホストPCでビルド用のライブラリをインストール ==="
sudo apt update
sudo apt install -y build-essential libssl-dev libffi-dev \
                    libbz2-dev libsqlite3-dev libreadline-dev libncurses5-dev \
                    libncursesw5-dev zlib1g-dev liblzma-dev wget

### 2️⃣ Python のソースコードを取得 ###
echo "=== Python 3.9.17 のソースコードをダウンロード ==="
cd /tmp
wget https://www.python.org/ftp/python/3.9.17/Python-3.9.17.tgz
tar xvf Python-3.9.17.tgz
cd Python-3.9.17

### 3️⃣ Python を静的リンクでビルド ###
echo "=== Python を静的リンクでビルド中（時間がかかります） ==="
./configure --prefix=/home/mic/python --enable-optimizations LDFLAGS="-static"
make -j$(nproc)
make install

### 4️⃣ Xeon Phi に Python を転送 ###
echo "=== Python を Xeon Phi に転送 ==="
scp -r /home/mic/python mic0:/home/mic/

### 5️⃣ pip のインストール ###
echo "=== pip をインストール ==="
ssh mic0 "/home/mic/python/bin/python3 -m ensurepip"
ssh mic0 "/home/mic/python/bin/python3 -m pip install --upgrade pip"

### 6️⃣ NumPy & OpenCV のインストール ###
echo "=== NumPy & OpenCV を Xeon Phi にインストール ==="
ssh mic0 "/home/mic/python/bin/python3 -m pip install numpy opencv-python-headless"

### 7️⃣ Python の動作確認スクリプトを作成 ###
echo "=== Python の動作確認スクリプトを作成 & 転送 ==="
cat << EOF > test_python.py
import platform
import sys
import numpy as np

print("Python は正常に動作しています！")
print(f"OS: {platform.system()} {platform.release()}")
print(f"Python バージョン: {sys.version}")
print(f"NumPy バージョン: {np.__version__}")
EOF

scp test_python.py mic0:/home/mic/

### 8️⃣ Python スクリプトを実行 ###
echo "=== Python スクリプトを実行 ==="
ssh mic0 "/home/mic/python/bin/python3 /home/mic/test_python.py"

### 9️⃣ 結果を取得 ###
echo "=== 実行結果を取得 ==="
scp mic0:/home/mic/test_python.py_result.txt .

echo "=== すべての処理が完了しました！ ==="
