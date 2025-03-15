#!/bin/bash

# Python のインストールディレクトリ
INSTALL_DIR="/usr/local/python"

# 仮想環境のディレクトリ
VENV_DIR="$HOME/python_venvs"

# Python バージョンリスト
PYTHON_VERSIONS=("3.8" "3.9" "3.10" "3.11" "3.12" "3.13")

# 必要なパッケージをインストール
echo "🔹 必要なパッケージをインストール中..."
sudo apt update
sudo apt install -y \
    build-essential \
    libssl-dev zlib1g-dev \
    libncurses-dev libgdbm-dev \
    libnss3-dev libsqlite3-dev \
    libreadline-dev libffi-dev \
    curl libbz2-dev liblzma-dev \
    tk-dev libexpat1-dev \
    libgdbm-compat-dev libuuid1 uuid-dev \
    libffi-dev software-properties-common

# 🔹 PPA の追加を試みる
echo "🔹 PPA の追加を試行中..."
if sudo add-apt-repository -y ppa:deadsnakes/ppa; then
    echo "✅ PPA が追加されました。"
    sudo apt update
else
    echo "⚠️ PPA の追加に失敗しました。"
fi

# インストールディレクトリを作成
sudo mkdir -p "$INSTALL_DIR"

# 各 Python バージョンをインストール
for version in "${PYTHON_VERSIONS[@]}"; do
    echo "🔹 Python $version のインストールを確認中..."

    # 🔹 APT での Python インストールを試みる
    if apt-cache show "python$version" &>/dev/null; then
        echo "✅ Python $version が APT で利用可能です。インストールします..."
        sudo apt install -y "python$version" "python$version-venv" "python$version-dev"
        continue
    else
        echo "⚠️ Python $version は APT で見つかりません。"
    fi

    # 🔹 ソースからビルド
    echo "🔹 Python $version をソースからビルド中..."
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

    # 最適化オプションを設定
    export CFLAGS="-fno-profile-arcs -fno-test-coverage"
    export LDFLAGS="-Wl,-rpath=/usr/local/lib -L/usr/local/lib"
    export CPPFLAGS="-I/usr/local/include"

    echo "🔹 Python $full_version を最適化コンパイル中..."
    sudo ./configure --enable-optimizations --enable-shared --prefix="$INSTALL_DIR/$version" \
        --disable-test-modules --without-doc-strings --without-gcov

    sudo make clean
    sudo make -j$(nproc)
    sudo make install
    sudo make altinstall

    # シンボリックリンクを作成
    sudo ln -sf "$INSTALL_DIR/$version/bin/python$version" "/usr/local/bin/python$version"
    sudo ln -sf "$INSTALL_DIR/$version/lib/libpython$version.so" "/usr/lib/libpython$version.so"

    echo "✅ Python $full_version のインストール完了！"
done

echo "✅ Python の最適化インストールが完了しました！"

# 仮想環境の作成
mkdir -p "$VENV_DIR"
echo "🔹 仮想環境の作成を開始します..."

for version in "${PYTHON_VERSIONS[@]}"; do
    VENV_PATH="$VENV_DIR/python$version-venv"

    if [ -x "/usr/local/bin/python$version" ]; then
        echo "🔹 Python $version 用の仮想環境を作成: $VENV_PATH"

        # 仮想環境を作成
        "/usr/local/bin/python$version" -m venv "$VENV_PATH"

        # 仮想環境を有効化して pip を最新に更新
        source "$VENV_PATH/bin/activate"
        pip install --upgrade pip setuptools wheel
        deactivate

        echo "✅ 仮想環境 $VENV_PATH のセットアップ完了！"
    else
        echo "⚠️ Python $version が見つかりませんでした。仮想環境の作成をスキップします。"
    fi
done

echo "✅ すべての Python 仮想環境が作成されました！"
echo "📌 仮想環境の場所: $VENV_DIR"
echo "🔹 仮想環境の使用方法:"
echo "   source $VENV_DIR/python3.10-venv/bin/activate  # Python 3.10 を使用"
echo "   deactivate  # 仮想環境を終了"
