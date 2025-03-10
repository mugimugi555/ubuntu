#!/usr/bin/bash

# =============================================================
# Ubuntu に Python の最新版をインストールし、venv をセットアップ
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
# venv 仮想環境の作成
# =============================================================
echo "🔧 Python 仮想環境 (venv) を作成..."

# 仮想環境のディレクトリを作成
VENV_DIR="$HOME/my_python_env"
if [ ! -d "$VENV_DIR" ]; then
    python3 -m venv "$VENV_DIR"
    echo "✅ 仮想環境を作成しました: $VENV_DIR"
else
    echo "✅ 仮想環境はすでに存在します: $VENV_DIR"
fi

# 仮想環境を有効化
echo "🌟 仮想環境を有効化..."
source "$VENV_DIR/bin/activate"

# =============================================================
# 必要な Python パッケージをインストール
# =============================================================
echo "📦 pip を最新にアップデート..."
pip install --upgrade pip

# インストール済みパッケージの確認
pip list

# =============================================================
# インストールの確認
# =============================================================
echo "🐍 インストールされた Python のバージョン:"
python --version
pip --version

echo "✅ 仮想環境が有効化されました！"
echo "📝 仮想環境を終了するには 'deactivate' を実行してください。"

# シェルを再読み込み
exec $SHELL -l
