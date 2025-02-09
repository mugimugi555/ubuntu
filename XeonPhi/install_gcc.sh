#!/bin/bash

echo "=== Xeon Phi に GCC & CMake (静的リンク版) をインストール ==="

# バージョン指定
GCC_VERSION="13.1.0"
CMAKE_VERSION="3.27.0"
GCC_INSTALL_DIR="/home/mic/gcc-${GCC_VERSION}"
CMAKE_INSTALL_DIR="/home/mic/cmake-${CMAKE_VERSION}"

### 1️⃣ ホスト側で GCC のビルド & 転送 ###
echo "=== ホスト側で GCC ${GCC_VERSION} のビルド開始 ==="
cd /tmp
wget https://ftp.gnu.org/gnu/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.gz
tar xzf gcc-${GCC_VERSION}.tar.gz
cd gcc-${GCC_VERSION}

# 依存関係のライブラリを取得
./contrib/download_prerequisites

# ビルドディレクトリ作成
mkdir build
cd build

# コンパイル設定（静的リンク有効化）
../configure --prefix=${GCC_INSTALL_DIR} \
             --enable-languages=c,c++ \
             --disable-multilib \
             --enable-static \
             --disable-shared \
             --enable-checking=release

make -j$(nproc)
make install

# Xeon Phi に転送
echo "=== GCC を Xeon Phi に転送 ==="
scp -r ${GCC_INSTALL_DIR} mic0:/home/mic/

### 2️⃣ ホスト側で CMake のビルド & 転送 ###
echo "=== ホスト側で CMake ${CMAKE_VERSION} のビルド開始 ==="
cd /tmp
wget https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}.tar.gz
tar xzf cmake-${CMAKE_VERSION}.tar.gz
cd cmake-${CMAKE_VERSION}

# ビルド & インストール
./bootstrap --prefix=${CMAKE_INSTALL_DIR} -- -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)
make install

# Xeon Phi に転送
echo "=== CMake を Xeon Phi に転送 ==="
scp -r ${CMAKE_INSTALL_DIR} mic0:/home/mic/

### 3️⃣ Xeon Phi 側で環境変数の設定 & 確認 ###
echo "=== Xeon Phi 側で環境変数を設定 & インストール確認 ==="
ssh mic0 << 'EOF'
    GCC_VERSION="13.1.0"
    CMAKE_VERSION="3.27.0"
    GCC_INSTALL_DIR="/home/mic/gcc-${GCC_VERSION}"
    CMAKE_INSTALL_DIR="/home/mic/cmake-${CMAKE_VERSION}"

    # 環境変数を設定
    echo "export PATH=${GCC_INSTALL_DIR}/bin:${CMAKE_INSTALL_DIR}/bin:\$PATH" >> ~/.bashrc
    echo "export LD_LIBRARY_PATH=${GCC_INSTALL_DIR}/lib64:\$LD_LIBRARY_PATH" >> ~/.bashrc
    source ~/.bashrc

    # インストール確認
    echo "=== Xeon Phi 側で GCC のバージョン確認 ==="
    gcc --version

    echo "=== Xeon Phi 側で CMake のバージョン確認 ==="
    cmake --version
EOF

echo "=== Xeon Phi に GCC & CMake の静的リンクインストールが完了しました！ ==="
