#!/bin/bash

# === 設定 ===
SERVER_IP="192.168.1.100"  # 🔹 サーバーの IP アドレスに変更
PYTHON_VERSION="3.10"
VENV_DIR="$HOME/python_venvs"
VENV_PATH="$VENV_DIR/python$PYTHON_VERSION-venv"

# === Python 3.10 の存在確認 ===
check_python_version() {
    echo "🔹 `apt search` で Python 3.10 の存在を確認します..."

    # 🔹 `apt search` で Python 3.10 を検索
    if ! apt search "^python3.10$" 2>/dev/null | grep -q "^python3.10"; then
        echo -e "\n❌ Python 3.10 が見つかりません！"
        echo -e "   \e[1;31m手動で Python 3.10 をソースからビルドするか、"
        echo -e "   Ubuntu の公式リポジトリが更新されるのを待ってください。\e[0m"
        exit 1
    else
        echo "✅ Python 3.10 はシステムに存在します。続行します。"
    fi
}

# === サーバー側のセットアップ ===
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
    echo "🔹 pip を更新..."
    pip install --upgrade pip setuptools wheel

    # Ray のインストール
    echo "🔹 Ray をインストール..."
    pip install "ray[default]" --ignore-installed

    # Ray クラスターモードのセットアップ
    echo "🔹 Ray クラスターモードをセットアップ..."
    ray stop  # 既存の Ray を停止
    ray start --head --port=6379 --dashboard-port=8265

    deactivate

    echo "✅ サーバーのセットアップが完了しました！"
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
    echo "🔹 pip を更新..."
    pip install --upgrade pip setuptools wheel

    # Ray のインストール
    echo "🔹 Ray をインストール..."
    pip install "ray[default]" --ignore-installed

    # サーバーに接続
    echo "🔹 Ray クラスターヘッドノードに接続: $SERVER_IP"
    ray stop
    ray start --address="$SERVER_IP:6379"

    # 🔹 CUDA のバージョンを調べる
    echo "🔹 CUDA のバージョンを取得..."
    CUDA_VERSION=$(python - <<EOF
import torch
if torch.cuda.is_available():
    capability = torch.cuda.get_device_capability()
    major, minor = capability
    if major == 7:
        print("cu102")  # CUDA 10.2
    elif major == 8:
        print("cu118")  # CUDA 11.8
    elif major == 9:
        print("cu121")  # CUDA 12.1
    else:
        print("cpu")  # CUDA 不明なら CPU 版
else:
    print("cpu")
EOF
)
    echo "🔹 CUDA バージョン: $CUDA_VERSION"

    # 🔹 PyTorch のインストール
    if [ "$CUDA_VERSION" = "cpu" ]; then
        echo "🔹 CPU 版の PyTorch をインストール..."
        pip install torch torchvision torchaudio
    else
        echo "🔹 CUDA ${CUDA_VERSION} に対応する PyTorch をインストール..."
        pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/$CUDA_VERSION
    fi

    # 🔹 GPU の利用可否を確認
    echo "🔹 GPU の使用可否をテスト..."
    python - <<EOF
import torch
import ray

ray.init(address="auto")

print("✅ Ray の利用可能リソース:")
print(ray.available_resources())

if torch.cuda.is_available():
    print(f"✅ CUDA が利用可能です: {torch.cuda.get_device_name(0)}")
    print(f"🔥 GPU のメモリ使用量: {torch.cuda.memory_allocated() / 1024**2:.2f} MB")
else:
    print("⚠️ CUDA が利用できません。")
EOF

    deactivate

    echo "✅ クライアントのセットアップが完了しました！"
}

# === メニュー選択 ===
echo "🔹 どちらのセットアップを実行しますか？"
echo "   1) サーバーのセットアップ"
echo "   2) クライアントのセットアップ（CUDA バージョン取得 & GPU テスト付き）"
read -p "選択してください (1/2): " choice

case "$choice" in
    1) setup_server ;;
    2) setup_client ;;
    *) echo "⚠️ 無効な選択です。終了します。" ;;
esac
