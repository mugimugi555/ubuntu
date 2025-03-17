#!/bin/bash

set -e  # エラー時にスクリプトを停止

# === 設定 ===
INSTALL_DIR="$HOME/image_classifier"
PYTHON_ENV_DIR="$INSTALL_DIR/venv"
SCRIPT_NAME="image_classifier.py"

echo "🔹 画像分類ツールのインストールを開始します..."

# 1. 必要なパッケージをインストール
echo "🔹 必要なパッケージをインストール..."
sudo apt update && sudo apt install -y python3 python3-venv python3-pip

# 2. インストールディレクトリを作成
mkdir -p "$INSTALL_DIR"

# 3. Python 仮想環境の作成
if [ ! -d "$PYTHON_ENV_DIR" ]; then
    echo "🔹 Python 仮想環境を作成中..."
    python3 -m venv "$PYTHON_ENV_DIR"
else
    echo "✅ 既に仮想環境が存在します: $PYTHON_ENV_DIR"
fi

# 仮想環境を有効化
source "$PYTHON_ENV_DIR/bin/activate"

# 4. 必要な Python ライブラリをインストール
echo "🔹 必要な Python ライブラリをインストール..."
pip install --upgrade pip
pip install pillow webuiapi

# 仮想環境を無効化
deactivate

echo "✅ インストールが完了しました！"
echo "📌 使い方:"
echo "   1. Python 仮想環境を有効化"
echo "      source $PYTHON_ENV_DIR/bin/activate"
echo "   2. 画像分類を実行"
echo "      python $INSTALL_DIR/$SCRIPT_NAME path_to_your_image.jpg"
echo "   3. 仮想環境を終了"
echo "      deactivate"
