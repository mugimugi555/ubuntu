#!/bin/bash

# === 設定 ===
SERVER_IP="192.168.1.100"  # 🔹 サーバーの IP に変更
PYTHON_VERSION="3.10"
VENV_DIR="$HOME/python_venvs"
VENV_PATH="$VENV_DIR/python$PYTHON_VERSION-venv"

# === Python 3.10 の存在確認 ===
check_python_version() {
    if ! apt search "^python3.10$" 2>/dev/null | grep -q "^python3.10"; then
        echo -e "\n❌ Python 3.10 が見つかりません！"
        exit 1
    fi
}

# === クライアント側のセットアップ ===
setup_client() {
    echo "🔹 クライアント: Python 仮想環境をセットアップ中..."

    # Python 3.10 の確認
    check_python_version

    # 必要なパッケージをインストール
    sudo apt update
    sudo apt install -y python3.10 python3.10-venv python3.10-dev python3-pip

    # 仮想環境の作成
    mkdir -p "$VENV_DIR"
    if [ ! -d "$VENV_PATH" ]; then
        echo "🔹 Python 3.10 の仮想環境を作成: $VENV_PATH"
        python3.10 -m venv "$VENV_PATH"
    else
        echo "✅ 既存の仮想環境が見つかりました: $VENV_PATH"
    fi

    # 仮想環境のアクティベート
    source "$VENV_PATH/bin/activate"

    # pip の更新
    pip install --upgrade pip setuptools wheel

    # Ray のインストール
    pip install "ray[default]" --ignore-installed

    # Ray クラスターヘッドノードに接続
    echo "🔹 Ray クラスターヘッドノードに接続: $SERVER_IP"
    ray stop
    ray start --address="$SERVER_IP:6379"

    # 🔹 GPU を使うテストタスク
    echo "🔹 GPU の使用可否をテスト..."
    python - <<EOF
import ray

ray.init(address="auto")

@ray.remote(num_gpus=1)
def gpu_task():
    import torch
    return torch.cuda.get_device_name(0)

try:
    gpu_name = ray.get(gpu_task.remote())
    print(f"✅ リモート GPU: {gpu_name} を使用可能")
except Exception as e:
    print(f"❌ GPU タスクの実行に失敗: {e}")
    exit 1
EOF

    deactivate
    echo "✅ クライアントのセットアップが完了しました！"
}

setup_client
