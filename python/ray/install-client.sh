#!/bin/bash

# === 設定 ===
SERVER_IP="192.168.1.100"  # 🔹 サーバーの IP に変更
PYTHON_VERSION="3.10"
VENV_DIR="$HOME/python_venvs"
VENV_PATH="$VENV_DIR/python$PYTHON_VERSION-venv"

# === Python 3.10 の存在確認 ===
check_python_version() {
    echo "🔹 Python 3.10 の存在を確認中..."

    # 🔹 既に Python 3.10 がインストールされているか確認
    if python3.10 --version &>/dev/null; then
        echo "✅ Python 3.10 は既にインストールされています。"
        return 0
    fi

    # 🔹 `apt search` で Python 3.10 のパッケージを探す
    if apt search "^python3.10$" 2>/dev/null | grep -q "^python3.10"; then
        echo "⚠️ Python 3.10 がシステムに見つかりませんでした。インストールします..."
        sudo apt update
        sudo apt install -y python3.10 python3.10-venv python3.10-dev python3-pip
        return 0
    fi

    # 🔹 Python 3.10 が見つからない場合のエラーメッセージ
    echo -e "\n❌ Python 3.10 が見つかりません！"
    echo -e "   \e[1;31m手動で Python 3.10 をソースからビルドするか、"
    echo -e "   Ubuntu の公式リポジトリが更新されるのを待ってください。\e[0m"
    exit 1
}

# === クライアント側のセットアップ ===
setup_client() {
    echo "🔹 クライアント: Python 仮想環境をセットアップ中..."

    # Python 3.10 の確認
    check_python_version

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

    # 🔹 GPU の使用可否 & ステータス一覧を取得
    echo "🔹 リモート GPU の状態を確認中..."
    python - <<EOF
import ray

ray.init(address="auto")

@ray.remote(num_gpus=1)
def gpu_status():
    import torch
    if not torch.cuda.is_available():
        return "❌ GPU が利用できません。"

    gpu_info = []
    for i in range(torch.cuda.device_count()):
        gpu_name = torch.cuda.get_device_name(i)
        total_memory = torch.cuda.get_device_properties(i).total_memory / 1024**3  # GB単位
        used_memory = torch.cuda.memory_allocated(i) / 1024**3  # GB単位
        free_memory = total_memory - used_memory

        gpu_info.append(f"GPU {i}: {gpu_name} | Total: {total_memory:.2f} GB | Used: {used_memory:.2f} GB | Free: {free_memory:.2f} GB")

    return "\n".join(gpu_info)

try:
    gpu_status_result = ray.get(gpu_status.remote())
    print(f"✅ リモート GPU のステータス:\n{gpu_status_result}")
except Exception as e:
    print(f"❌ GPU 情報の取得に失敗: {e}")
    exit 1
EOF

    deactivate
    echo "✅ クライアントのセットアップが完了しました！"
}

setup_client
