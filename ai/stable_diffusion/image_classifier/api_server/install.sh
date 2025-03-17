#!/bin/bash

set -e  # エラーが発生したらスクリプトを停止

# === 設定 ===
SERVICE_NAME="image-classifier-api"
INSTALL_DIR="/opt/$SERVICE_NAME"
PYTHON_ENV_DIR="$INSTALL_DIR/venv"
API_SCRIPT="image_classifier_api.py"
PORT="8000"

echo "🔹 $SERVICE_NAME のインストールを開始..."

# 1. 必要なパッケージのインストール
echo "🔹 必要なパッケージをインストール中..."
sudo apt update && sudo apt install -y python3 python3-venv python3-pip curl

# 2. インストールディレクトリの作成
echo "🔹 インストールディレクトリを作成: $INSTALL_DIR"
sudo mkdir -p "$INSTALL_DIR"
sudo chown $USER:$USER "$INSTALL_DIR"

# 3. Python 仮想環境の作成
if [ ! -d "$PYTHON_ENV_DIR" ]; then
    echo "🔹 Python 仮想環境を作成: $PYTHON_ENV_DIR"
    python3 -m venv "$PYTHON_ENV_DIR"
fi

# 仮想環境を有効化
source "$PYTHON_ENV_DIR/bin/activate"

# 4. 必要な Python ライブラリのインストール
echo "🔹 必要な Python ライブラリをインストール中..."
pip install --upgrade pip
pip install fastapi uvicorn pillow requests webuiapi

# 5. systemd サービスファイルの作成
echo "🔹 systemd サービスファイルを作成: /etc/systemd/system/$SERVICE_NAME.service"
sudo bash -c "cat <<EOF > /etc/systemd/system/$SERVICE_NAME.service
[Unit]
Description=Image Classifier API Service
After=network.target

[Service]
User=$USER
Group=$USER
WorkingDirectory=$INSTALL_DIR
ExecStart=$PYTHON_ENV_DIR/bin/uvicorn $API_SCRIPT:app --host 0.0.0.0 --port $PORT
Restart=always

[Install]
WantedBy=multi-user.target
EOF"

# 6. systemd サービスの登録と起動
echo "🔹 systemd サービスを有効化して起動..."
sudo systemctl daemon-reload
sudo systemctl enable $SERVICE_NAME
sudo systemctl start $SERVICE_NAME

echo "✅ $SERVICE_NAME のインストールが完了しました！"
echo "🔹 API のエンドポイント: http://localhost:$PORT"
echo "🔹 ステータス確認: sudo systemctl status $SERVICE_NAME"
echo "🔹 停止: sudo systemctl stop $SERVICE_NAME"
echo "🔹 再起動: sudo systemctl restart $SERVICE_NAME"
