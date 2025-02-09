#!/bin/bash

echo "=== Xeon Phi に Python 3.9+ をインストール & スクリプトをアップロード ==="

### 1️⃣ Python 3.9+ をインストール（なければビルド） ###
echo "=== Python のインストールを確認 ==="

ssh mic0 'if ! command -v python3 &> /dev/null || python3 -c "import sys; exit(sys.version_info < (3,9))"; then
    echo "Python 3.9+ をインストールします..."

    # 必要なライブラリをインストール
    sudo apt update && sudo apt install -y build-essential libssl-dev libffi-dev \
                    libbz2-dev libsqlite3-dev libreadline-dev libncurses5-dev \
                    libncursesw5-dev zlib1g-dev liblzma-dev wget

    # Python の最新版を取得
    cd /home/mic/
    wget https://www.python.org/ftp/python/3.9.17/Python-3.9.17.tgz

    # 解凍 & コンパイル
    tar xvf Python-3.9.17.tgz
    cd Python-3.9.17
    ./configure --enable-optimizations
    make -j$(nproc)
    sudo make altinstall

    # Python 3.9 をデフォルトに設定
    sudo ln -sf /usr/local/bin/python3.9 /usr/bin/python3
    sudo ln -sf /usr/local/bin/pip3.9 /usr/bin/pip3

    echo "Python 3.9 インストール完了"
else
    echo "Python 3.9+ は既にインストール済み"
fi'

### 2️⃣ 必要なライブラリをインストール ###
echo "=== Python のライブラリをインストール ==="

ssh mic0 'pip3 install --upgrade pip'
ssh mic0 'pip3 install numpy opencv-python opencv-python-headless'

### 3️⃣ スクリプトをアップロード ###
echo "=== Python テストスクリプトを作成 & アップロード ==="

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

### 4️⃣ スクリプトを実行 ###
echo "=== Python スクリプトを実行 ==="
ssh mic0 "python3 /home/mic/test_python.py"

### 5️⃣ 結果を取得 ###
echo "=== 実行結果を取得 ==="
scp mic0:/home/mic/test_python.py_result.txt .

echo "=== すべての処理が完了しました！ ==="
