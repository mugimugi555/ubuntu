#!/bin/bash

# Python のバージョンリスト
PYTHON_VERSIONS=("3.8" "3.9" "3.10" "3.11" "3.12")

# Python のインストールディレクトリ
INSTALL_DIR="/usr/local/python"

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
    tk-dev libmpdec-dev libexpat1-dev \
    libgdbm-compat-dev libuuid1 uuid-dev

# インストールディレクトリを作成
sudo mkdir -p "$INSTALL_DIR"

# 各 Python バージョンをインストール
for version in "${PYTHON_VERSIONS[@]}"; do
    echo "🔹 Python $version をソースからビルド中..."

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

    echo "🔹 Python $full_version を最適化コンパイル中..."
    sudo ./configure --enable-optimizations --enable-shared --prefix="$INSTALL_DIR/$version" \
        --disable-test-modules --without-doc-strings
    sudo make -j$(nproc) SKIP_TESTS=yes
    sudo make altinstall  # テストを省略して高速インストール

    # シンボリックリンクを作成
    sudo ln -sf "$INSTALL_DIR/$version/bin/python$version" "/usr/local/bin/python$version"
    sudo ln -sf "$INSTALL_DIR/$version/lib/libpython$version.so" "/usr/lib/libpython$version.so"

    echo "✅ Python $full_version のインストール完了！"
done

echo "✅ Python の最適化インストールが完了しました！"
