#!/bin/bash

# === 設定 ===
PYTHON_VERSION="python3.10"

# === Python 3.10 の存在確認 ===
check_python_version() {
    echo "🔹 Python 3.10 の存在を確認中..."

    if $PYTHON_VERSION --version &>/dev/null; then
        echo "✅ Python 3.10 は既にインストールされています。"
        return 0
    fi

    if apt search "^python3.10$" 2>/dev/null | grep -q "^python3.10"; then
        echo "⚠️ Python 3.10 がシステムに見つかりませんでした。インストールします..."
        sudo apt update
        sudo apt install -y python3.10 python3.10-dev python3-pip
        return 0
    fi

    echo -e "\n❌ Python 3.10 が見つかりません！"
    echo -e "   \e[1;31m手動で Python 3.10 をソースからビルドするか、"
    echo -e "   Ubuntu の公式リポジトリが更新されるのを待ってください。\e[0m"
    exit 1
}

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

# === Ray サーバーのセットアップ ===
setup_server() {
    echo "🔹 サーバー: Python と Ray をセットアップ中..."

    # Python 3.10 の確認
    check_python_version

    # pip の更新
    echo "🔹 pip を更新..."
    sudo $PYTHON_VERSION -m pip install --upgrade pip setuptools wheel

    # Ray のインストール
    echo "🔹 Ray をインストール..."
    sudo $PYTHON_VERSION -m pip install "ray[default]" --ignore-installed

    # CUDA の取得
    get_cuda_version

    # 🔹 PyTorch のインストール
    echo "🔹 CUDA ${CUDA_VERSION} に対応する PyTorch をインストール..."
    sudo $PYTHON_VERSION -m pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/$CUDA_VERSION

    # 🔹 `torch` のインストール確認
    if ! $PYTHON_VERSION -c "import torch" &>/dev/null; then
        echo "❌ PyTorch のインストールに失敗しました！"
        exit 1
    fi
    echo "✅ PyTorch のインストールが完了しました！"

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
            sudo $PYTHON_VERSION -m pip install jupyter
            nohup jupyter notebook --no-browser --port=8888 > "$JUPYTER_LOG" 2>&1 &
            echo "✅ Jupyter Notebook を起動しました (ポート 8888)"
            echo "📌 ログは $JUPYTER_LOG に保存されます。"
        fi
    fi

    echo "✅ サーバーのセットアップが完了しました！"
}

setup_server
