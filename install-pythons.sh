#!/bin/bash

# Python のインストールディレクトリ
INSTALL_DIR="/usr/local/python"

# 仮想環境のディレクトリ
VENV_DIR="$HOME/python_venvs"

# 固定の Python バージョンリスト
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
    libffi-dev

# `libmpdec` の存在を確認し、インストール
if apt-cache search libmpdec | grep -q "libmpdec"; then
    echo "✅ libmpdec が見つかりました。APT でインストールします。"
    sudo apt install -y libmpdec3
else
    echo "⚠️ libmpdec が見つかりません。ソースからビルドします。"
    cd /usr/src
    sudo curl -O https://www.bytereef.org/software/mpdecimal/releases/mpdecimal-2.5.1.tar.gz
    sudo tar -xvf mpdecimal-2.5.1.tar.gz
    cd mpdecimal-2.5.1
    sudo ./configure --prefix=/usr/local
    sudo make -j$(nproc)
    sudo make install
    echo "✅ libmpdec のインストールが完了しました。"
fi

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
        --disable-test-modules --without-doc-strings \
        LDFLAGS="-L/usr/local/lib" CPPFLAGS="-I/usr/local/include"
    sudo make -j$(nproc) SKIP_TESTS=yes
    sudo make altinstall  # テストを省略して高速インストール

    # シンボリックリンクを作成
    sudo ln -sf "$INSTALL_DIR/$version/bin/python$version" "/usr/local/bin/python$version"
    sudo ln -sf "$INSTALL_DIR/$version/lib/libpython$version.so" "/usr/lib/libpython$version.so"

    echo "✅ Python $full_version のインストール完了！"
done

echo "✅ Python の最適化インストールが完了しました！"
