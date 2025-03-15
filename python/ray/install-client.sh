#!/bin/bash

# === 設定 ===
SERVER_IP="192.168.1.100"  # 🔹 サーバーの IP に変更
PYTHON_VERSION="3.10"
VENV_DIR="$HOME/python_venvs"
VENV_PATH="$VENV_DIR/python$PYTHON_VERSION-venv"

# === クライアント側のセットアップ ===
setup_client() {
    echo "🔹 クライアント: Python 仮想環境をセットアップ中..."

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

    # サーバーに接続
    echo "🔹 Ray クラスターヘッドノードに接続: $SERVER_IP"
    ray stop
    ray start --address="$SERVER_IP:6379"

    # 🔹 Ray の接続可否とステータス取得
    echo "🔹 Ray クラスターステータスを取得..."
    SERVER_IP=$SERVER_IP python - <<EOF
import os
import ray

try:
    SERVER_IP = os.environ.get("SERVER_IP", "127.0.0.1")  # 環境変数から取得
    ray.init(address="auto")
    
    print("\n✅ Ray クラスターステータス:")
    print(f"  - Ray ダッシュボード: http://{SERVER_IP}:8265")
    
    cluster_resources = ray.cluster_resources()
    available_resources = ray.available_resources()
    
    print(f"  - クラスターのリソース (総数): {cluster_resources}")
    print(f"  - 現在利用可能なリソース: {available_resources}")
    
    print("\n🔹 クラスターのノード情報:")
    for node in ray.nodes():
        print(f"  - ID: {node['NodeID']}, 状態: {node['Alive']}, リソース: {node['Resources']}")
    
except Exception as e:
    print(f"❌ Ray クラスターステータスの取得に失敗: {e}")
    exit(1)
EOF

    deactivate
    echo "✅ クライアントのセットアップが完了しました！"
}

setup_client
