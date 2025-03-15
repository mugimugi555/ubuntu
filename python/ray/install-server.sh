#!/bin/bash

# === 設定 ===
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

# === Ray サーバーのセットアップ ===
setup_server() {
    echo "🔹 サーバー: Python と Ray を仮想環境でセットアップ中..."

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

    # 仮想環境をアクティベート
    source "$VENV_PATH/bin/activate"

    # pip の更新
    pip install --upgrade pip setuptools wheel

    # Ray のインストール
    pip install "ray[default]" --ignore-installed

    # 🔹 CUDA の確認
    echo "🔹 CUDA のバージョンを取得..."
    CUDA_VERSION=$(python -c "import torch; print(torch.version.cuda if torch.cuda.is_available() else 'cpu')")
    if [ "$CUDA_VERSION" = "cpu" ]; then
        echo "❌ CUDA が見つかりません！リモート GPU の使用には CUDA が必要です。"
        exit 1
    fi
    echo "✅ サーバーの CUDA バージョン: $CUDA_VERSION"

    # 🔹 Ray クラスターモードのセットアップ
    echo "🔹 Ray クラスターモードをセットアップ..."
    ray stop  # 既存の Ray を停止
    ray start --head --port=6379 --dashboard-port=8265

    # 🔹 Jupyter Notebook（オプション）
    JUPYTER_LOG="/var/log/jupyter.log"
    read -p "Jupyter Notebook を起動しますか？ (y/n): " jupyter_choice
    if [ "$jupyter_choice" = "y" ]; then
        if pgrep -f "jupyter-notebook" > /dev/null; then
            echo "✅ Jupyter Notebook はすでに実行中です。"
        else
            pip install jupyter
            nohup jupyter notebook --no-browser --port=8888 > "$JUPYTER_LOG" 2>&1 &
            echo "✅ Jupyter Notebook を起動しました (ポート 8888)"
            echo "📌 ログは $JUPYTER_LOG に保存されます。"
        fi
    fi

    deactivate
    echo "✅ サーバーのセットアップが完了しました！"
}

setup_server
