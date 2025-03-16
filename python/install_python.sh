#!/usr/bin/bash

# =============================================================
# Ubuntu に Python の最新版をインストールし、複数の venv 環境をセットアップ
# =============================================================

echo "✅ Python 最新版 & venv のセットアップを開始します..."

# 必要なパッケージの更新
sudo apt update -y
sudo apt upgrade -y

# =============================================================
# Python 最新版をインストール
# =============================================================
echo "🚀 Python の最新版をインストール..."
sudo apt install -y python3 python3-venv python3-pip python3-dev python3-virtualenv

# Python のバージョン確認
PYTHON_VERSION=$(python3 --version | awk '{print $2}')
echo "✅ Python $PYTHON_VERSION をインストールしました！"

# =============================================================
# venv 仮想環境の作成 (最新版)
# =============================================================
echo "🔧 Python の仮想環境 (venv) を作成..."

# 最新版 Python 用の仮想環境
VENV_DIR="$HOME/python_envs"
LATEST_VENV="$VENV_DIR/venv-latest"

mkdir -p "$VENV_DIR"

if [ ! -d "$LATEST_VENV" ]; then
    python3 -m venv "$LATEST_VENV"
    echo "✅ 仮想環境を作成しました: $LATEST_VENV"
else
    echo "✅ 仮想環境はすでに存在します: $LATEST_VENV"
fi

# =============================================================
# Python のメジャーバージョンごとに仮想環境を作成
# =============================================================
echo "🔧 複数バージョンの仮想環境をセットアップ..."
PYTHON_VERSIONS=("3.6" "3.7" "3.8" "3.9" "3.10" "3.11" "3.12")

for VERSION in "${PYTHON_VERSIONS[@]}"; do
    PYTHON_BIN=$(command -v python$VERSION)
    ENV_NAME="venv$VERSION"
    ENV_PATH="$VENV_DIR/$ENV_NAME"

    if [ -x "$PYTHON_BIN" ]; then
        if [ ! -d "$ENV_PATH" ]; then
            echo "🔧 Python $VERSION の仮想環境を作成中..."
            $PYTHON_BIN -m venv "$ENV_PATH"
            echo "✅ 仮想環境が作成されました: $ENV_PATH"
        else
            echo "✅ 既に存在します: $ENV_PATH"
        fi
    else
        echo "⚠️ Python $VERSION はシステムにインストールされていません。"
    fi
done

# =============================================================
# 使い方の案内
# =============================================================
echo "🎉 仮想環境のセットアップが完了しました！"
echo "🔹 仮想環境を有効化するには以下のコマンドを実行してください:"
echo "----------------------------------------"
echo "source $VENV_DIR/venv-latest/bin/activate  # 最新版"
for VERSION in "${PYTHON_VERSIONS[@]}"; do
    ENV_NAME="venv$VERSION"
    ENV_PATH="$VENV_DIR/$ENV_NAME"
    if [ -d "$ENV_PATH" ]; then
        echo "source $ENV_PATH/bin/activate  # Python $VERSION"
    fi
done
echo "----------------------------------------"
echo "🚀 必要な環境を有効化して開発を始めてください！"

# シェルを再読み込み
exec $SHELL -l
