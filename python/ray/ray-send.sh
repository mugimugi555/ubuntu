#!/bin/bash

# === 設定 ===
PYTHON_VERSION="3.10"
VENV_DIR="$HOME/python_venvs"
VENV_PATH="$VENV_DIR/python$PYTHON_VERSION-venv"

# === コマンドライン引数 ===
PYTHON_SCRIPT="$1"  # 実行する Python ファイル
SERVER_IP="$2"  # Ray クラスターヘッドノードの IP (ローカルなら "localhost")

# === ヘルプ表示 ===
if [ -z "$PYTHON_SCRIPT" ] || [ -z "$SERVER_IP" ]; then
    echo "❌ 実行する Python ファイルとサーバー IP を指定してください！"
    echo "   使い方: ./ray_submit.sh <python_script> <server_ip>"
    exit 1
fi

# === Python 3.10 の仮想環境を有効化 ===
if [ ! -d "$VENV_PATH" ]; then
    echo "❌ 仮想環境が見つかりません！"
    exit 1
fi
source "$VENV_PATH/bin/activate"

# === Ray クラスターのチェック ===
if ! ray status &>/dev/null; then
    echo "❌ Ray が動作していません！`ray start` でクラスターを開始してください。"
    exit 1
fi

# === Ray クラスターヘッドに接続 ===
echo "🔹 Ray クラスターヘッドノード ($SERVER_IP) に接続..."
ray start --address="$SERVER_IP:6379"

# === Python ファイルを Ray で実行 ===
echo "🔹 Ray で Python ファイルを実行: $PYTHON_SCRIPT"
python - <<EOF
import ray
import os

ray.init(address="auto")

@ray.remote
def run_script(script_path):
    with open(script_path, "r") as f:
        exec(f.read(), globals())
    return f"✅ {script_path} を実行しました！"

result = ray.get(run_script.remote("$PYTHON_SCRIPT"))
print(result)
EOF

# === クリーンアップ ===
deactivate
echo "✅ Ray による Python 実行が完了しました！"
