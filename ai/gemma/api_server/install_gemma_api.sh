#!/bin/bash

set -e  # エラーが発生したらスクリプトを停止

# === 設定 ===
INSTALL_DIR="$HOME/gemma_api"
PYTHON_ENV_DIR="$HOME/venvs/gemma3"
SERVICE_FILE="/etc/systemd/system/gemma_api.service"

# === CUDA バージョンの取得 ===
get_cuda_version() {
    echo "🔹 `nvcc` で CUDA のバージョンを取得..."
    if command -v nvcc &>/dev/null; then
        CUDA_VERSION=$(nvcc --version | grep "release" | awk '{print $NF}' | sed -E 's/[V,]//g' | cut -d'.' -f1,2)
        CUDA_VERSION="cu$(echo $CUDA_VERSION | tr -d '.')"
        echo "✅ 正しく検出された CUDA バージョン: $CUDA_VERSION"
    else
        echo "❌ `nvcc` コマンドが見つかりません！CUDA が正しくインストールされているか確認してください。"
        exit 1
    fi
}

echo "🔹 Google Gemma 3 API のインストールを開始します..."

# 1. 必要なパッケージをインストール
echo "🔹 必要なパッケージをインストール中..."
sudo apt update && sudo apt install -y python3 python3-venv python3-pip git curl jq

# 2. CUDA バージョンの取得
get_cuda_version

# 3. Python 仮想環境の作成
if [ ! -d "$PYTHON_ENV_DIR" ]; then
    echo "🔹 Python 仮想環境を作成中..."
    python3 -m venv "$PYTHON_ENV_DIR"
fi

# 仮想環境を有効化
source "$PYTHON_ENV_DIR/bin/activate"

# 4. 依存ライブラリをインストール
echo "🔹 必要な Python ライブラリをインストール中..."
pip install --upgrade pip setuptools wheel
pip install torch torchvision torchaudio --index-url "https://download.pytorch.org/whl/$CUDA_VERSION"
pip install transformers huggingface_hub accelerate fastapi uvicorn pydantic

# 5. API サーバースクリプトを配置
echo "🔹 API サーバースクリプトを配置..."
mkdir -p "$INSTALL_DIR"
cp gemma_api.py "$INSTALL_DIR/"

# 6. systemd サービスファイルを作成
echo "🔹 systemd サービスを設定..."
cat <<EOF | sudo tee "$SERVICE_FILE"
[Unit]
Description=Google Gemma 3 API Service
After=network.target

[Service]
User=$USER
Group=$USER
WorkingDirectory=$INSTALL_DIR
ExecStart=$PYTHON_ENV_DIR/bin/uvicorn gemma_api:app --host 0.0.0.0 --port 8000
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# 7. systemd サービスのリロード & 有効化
echo "🔹 Google Gemma 3 API サービスを有効化..."
sudo systemctl daemon-reload
sudo systemctl enable gemma_api
sudo systemctl restart gemma_api

echo "✅ Google Gemma 3 API のインストールが完了しました！"
echo "🌍 APIは http://localhost:8000 で利用可能"
echo "📌 サービスの状態を確認: sudo systemctl status gemma_api"
echo "📌 サービスを停止: sudo systemctl stop gemma_api"
echo "📌 サービスを再起動: sudo systemctl restart gemma_api"
