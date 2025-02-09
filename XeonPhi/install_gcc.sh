#!/bin/bash

echo "=== Xeon Phi に GCC & CMake (静的リンク版) をインストール ==="

# バージョン指定
GCC_VERSION="13.1.0"
CMAKE_VERSION="3.27.0"

# 必要なパッケージをホストPCにインストール
sudo apt update
sudo apt install -y build-essential wget

### 1️⃣ ホスト側で GCC のビルド & 転送 ###
echo "=== ホスト側で GCC ${GCC_VERSION} のビルド開始 ==="

# 作業ディレクトリの作成（ビルドは /tmp で実施）
mkdir -p /tmp/gcc_build
cd /tmp/gcc_build

# GCC のソースコードを取得
wget https://ftp.gnu.org/gnu/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.gz
tar xzf gcc-${GCC_VERSION}.tar.gz
cd gcc-${GCC_VERSION}

# 依存関係のライブラリを取得
./contrib/download_prerequisites

# ビルドディレクトリ作成
mkdir build
cd build

# コンパイル設定（静的リンク有効化）
../configure --prefix=$HOME/mic/bin/gcc-${GCC_VERSION} \
             --enable-languages=c,c++ \
             --disable-multilib \
             --enable-static \
             --disable-shared \
             --enable-checking=release

make -j$(nproc)
make install

# GCC を Xeon Phi に転送
echo "=== GCC を Xeon Phi に転送 ==="
scp -r $HOME/mic/bin mic0:/home/mic/bin/

# 作業ディレクトリの削除（オプション）
rm -rf /tmp/gcc_build

echo "=== GCC のビルド & クリーンアップ完了 ==="

---

### 2️⃣ ホスト側で CMake のビルド & 転送 ###
echo "=== ホスト側で CMake ${CMAKE_VERSION} のビルド開始 ==="

# 作業ディレクトリの作成（ビルドは /tmp で実施）
mkdir -p /tmp/cmake_build
cd /tmp/cmake_build

# CMake のソースコードを取得
wget https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}.tar.gz
tar xzf cmake-${CMAKE_VERSION}.tar.gz
cd cmake-${CMAKE_VERSION}

# ビルド & インストール
./bootstrap --prefix=$HOME/mic/bin/cmake-${CMAKE_VERSION} -- -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)
make install

# CMake を Xeon Phi に転送
echo "=== CMake を Xeon Phi に転送 ==="
scp -r $HOME/mic/bin mic0:/home/mic/bin/

# 作業ディレクトリの削除（オプション）
rm -rf /tmp/cmake_build

echo "=== CMake のビルド & クリーンアップ完了 ==="

---

### 3️⃣ Xeon Phi 側で環境変数の設定 & 確認 ###
echo "=== Xeon Phi 側で環境変数を設定 & インストール確認 ==="
ssh mic0 << 'EOF'
    GCC_VERSION="13.1.0"
    CMAKE_VERSION="3.27.0"

    # 環境変数を設定
    echo "export PATH=/home/mic/bin/gcc-${GCC_VERSION}/bin:/home/mic/bin/cmake-${CMAKE_VERSION}/bin:\$PATH" >> ~/.bashrc
    echo "export LD_LIBRARY_PATH=/home/mic/bin/gcc-${GCC_VERSION}/lib64:\$LD_LIBRARY_PATH" >> ~/.bashrc
    source ~/.bashrc

    # インストール確認
    echo "=== Xeon Phi 側で GCC のバージョン確認 ==="
    gcc --version

    echo "=== Xeon Phi 側で CMake のバージョン確認 ==="
    cmake --version
EOF

echo "=== Xeon Phi に GCC & CMake の静的リンクインストールが完了しました！ ==="
