#!/bin/bash

# === コマンドライン引数 ===
PYTHON_SCRIPT="$1"  # 実行する Python ファイル
SERVER_IP="$2"  # Ray クラスターヘッドノードの IP (ローカルなら "localhost")

# === ヘルプ表示 ===
if [ -z "$PYTHON_SCRIPT" ] || [ -z "$SERVER_IP" ]; then
    echo "❌ 実行する Python ファイルとサーバー IP を指定してください！"
    echo "   使い方: ./ray-send.sh <python_script> <server_ip>"
    exit 1
fi

# === Python の存在確認 ===
if ! command -v python3 &>/dev/null; then
    echo "❌ Python 3 が見つかりません！"
    exit 1
fi

# === Ray のインストール確認 ===
if ! python3 -c "import ray" &>/dev/null; then
    echo "❌ Ray がインストールされていません！`pip install ray` を実行してください。"
    exit 1
fi

# === Ray クラスターヘッドに接続 ===
echo "🔹 Ray クラスターヘッドノード ($SERVER_IP) に接続..."
ray start --address="$SERVER_IP:6379"

# === Python ファイルを Ray で実行 ===
echo "🔹 Ray で Python ファイルを実行: $PYTHON_SCRIPT"
python3 - <<EOF
import ray
import os

ray.init(address="auto")

@ray.remote
def run_script(script_path):
    try:
        with open(script_path, "r") as f:
            exec(f.read(), globals())
        return f"✅ {script_path} を正常に実行しました！"
    except Exception as e:
        return f"❌ {script_path} の実行中にエラーが発生しました: {e}"

result = ray.get(run_script.remote("$PYTHON_SCRIPT"))
print(result)
EOF

echo "✅ Ray による Python 実行が完了しました！"
