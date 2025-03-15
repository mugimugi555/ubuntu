#!/bin/bash

# Python のバージョンリスト
PYTHON_VERSIONS=("3.8.18" "3.9.18" "3.10.13" "3.11.6" "3.12.2")

# Python のインストールディレクトリ
INSTALL_DIR="/usr/local/python"

# 仮想環境のディレクトリ
VENV_DIR="$HOME/python_venvs"

# 必要なパッケージをインストール
echo "🔹 必要なパッケージをインストール中..."
sudo apt update
sudo apt install -y \
    build-essential \
    libssl-dev zlib1g-dev \
    libncurses5-dev libgdbm-dev \
    libnss3-dev libsqlite3-dev \
    libreadline-dev libffi-dev \
    curl libbz2-dev liblzma-dev \
    tk-dev

# インストールディレクトリを作成
sudo mkdir -p "$INSTALL_DIR"

# 各 Python バージョンをダウンロード・コンパイル・インストール
for version in "${PYTHON_VERSIONS[@]}"; do
    major_version="${version%.*}"  # 例: "3.10.13" → "3.10"

    echo "🔹 Python $version をダウンロード & コンパイル中..."
    cd /usr/src
    sudo curl -O "https://www.python.org/ftp/python/$version/Python-$version.tgz"
    sudo tar -xvf "Python-$version.tgz"
    cd "Python-$version"

    echo "🔹 Python $version をインストール中..."
    sudo ./configure --enable-optimizations --prefix="$INSTALL_DIR/$major_version"
    sudo make -j$(nproc)
    sudo make altinstall

    # シンボリックリンクを作成
    sudo ln -sf "$INSTALL_DIR/$major_version/bin/python$major_version" "/usr/local/bin/python$major_version"

    echo "✅ Python $version のインストール完了！"
done

# 仮想環境用ディレクトリを作成
mkdir -p "$VENV_DIR"

# 各 Python バージョンごとに仮想環境を作成
for version in "${PYTHON_VERSIONS[@]}"; do
    major_version="${version%.*}"  # 例: "3.10.13" → "3.10"
    VENV_PATH="$VENV_DIR/python$major_version-venv"

    echo "🔹 Python $major_version 用の仮想環境を作成: $VENV_PATH"

    # 仮想環境を作成
    "/usr/local/bin/python$major_version" -m venv "$VENV_PATH"

    # 仮想環境を有効化して pip を更新
    source "$VENV_PATH/bin/activate"
    pip install --upgrade pip setuptools wheel
    deactivate
done

echo "✅ Python のコンパイル & 仮想環境の作成が完了しました！"
echo "📌 仮想環境の場所: $VENV_DIR"
echo "🔹 仮想環境の使用方法:"
echo "   source $VENV_DIR/python3.10-venv/bin/activate  # Python 3.10 を使用"
echo "   deactivate  # 仮想環境を終了"
