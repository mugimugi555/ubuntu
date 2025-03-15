#!/bin/bash

# Python のバージョンリスト
PYTHON_VERSIONS=("3.8" "3.9" "3.10" "3.11" "3.12")

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

# 各 Python バージョンのインストールを試行
for version in "${PYTHON_VERSIONS[@]}"; do
    echo "🔹 Python $version をリポジトリからインストール可能か確認中..."
    if apt-cache show "python$version" > /dev/null 2>&1; then
        echo "✅ リポジトリに Python $version が見つかりました。インストールします。"
        sudo apt install -y "python$version" "python$version-venv" "python$version-dev"
    else
        echo "⚠️ Python $version はリポジトリにありません。ソースからビルドします。"
        
        # ソースからビルド
        full_version=$(curl -s https://www.python.org/ftp/python/ | grep -oP "$version\.\d+" | tail -1)
        if [ -z "$full_version" ]; then
            echo "❌ Python $version の最新バージョンが取得できませんでした。スキップします。"
            continue
        fi

        echo "🔹 Python $full_version をダウンロード & コンパイル中..."
        cd /usr/src
        sudo curl -O "https://www.python.org/ftp/python/$full_version/Python-$full_version.tgz"
        sudo tar -xvf "Python-$full_version.tgz"
        cd "Python-$full_version"

        echo "🔹 Python $full_version をインストール中..."
        sudo ./configure --enable-optimizations --prefix="$INSTALL_DIR/$version"
        sudo make -j$(nproc)
        sudo make altinstall

        # シンボリックリンクを作成
        sudo ln -sf "$INSTALL_DIR/$version/bin/python$version" "/usr/local/bin/python$version"

        echo "✅ Python $full_version のインストール完了！"
    fi
done

# 仮想環境用ディレクトリを作成
mkdir -p "$VENV_DIR"

# 各 Python バージョンごとに仮想環境を作成
for version in "${PYTHON_VERSIONS[@]}"; do
    VENV_PATH="$VENV_DIR/python$version-venv"

    echo "🔹 Python $version 用の仮想環境を作成: $VENV_PATH"

    # 仮想環境を作成
    "/usr/local/bin/python$version" -m venv "$VENV_PATH"

    # 仮想環境を有効化して pip を更新
    source "$VENV_PATH/bin/activate"
    pip install --upgrade pip setuptools wheel
    deactivate
done

echo "✅ Python のインストール & 仮想環境の作成が完了しました！"
echo "📌 仮想環境の場所: $VENV_DIR"
echo "🔹 仮想環境の使用方法:"
echo "   source $VENV_DIR/python3.10-venv/bin/activate  # Python 3.10 を使用"
echo "   deactivate  # 仮想環境を終了"
