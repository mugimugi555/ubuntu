#!/bin/bash

# === 設定 ===
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

# === Ray サーバーのセットアップ ===
setup_server() {
    echo "🔹 サーバー: Python と Ray を仮想環境でセットアップ中..."

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

    # 仮想環境をアクティベート
    source "$VENV_PATH/bin/activate"

    # pip を更新
    pip install --upgrade pip setuptools wheel

    # Ray のインストール
    pip install "ray[default]" --ignore-installed

    # CUDA の確認
    echo "🔹 CUDA のバージョンを取得..."
    CUDA_VERSION=$(python -c "import torch; print(torch.version.cuda if torch.cuda.is_available() else 'cpu')")
    echo "🔹 サーバーの CUDA バージョン: $CUDA_VERSION"

    # Ray クラスターモードのセットアップ
    echo "🔹 Ray クラスターモードをセットアップ..."
    ray stop  # 既存の Ray を停止
    ray start --head --port=6379 --dashboard-port=8265

    # Jupyter Notebook（オプション）
    read -p "Jupyter Notebook を起動しますか？ (y/n): " jupyter_choice
    if [ "$jupyter_choice" = "y" ]; then
        pip install jupyter
        nohup jupyter notebook --no-browser --port=8888 > jupyter.log 2>&1 &
        echo "✅ Jupyter Notebook を起動しました (ポート 8888)"
    fi

    deactivate
    echo "✅ サーバーのセットアップが完了しました！"
}

setup_server
