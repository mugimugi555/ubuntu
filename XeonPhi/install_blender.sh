#!/bin/bash

echo "=== Xeon Phi に Blender (静的リンク) をインストール ==="

# バージョン指定
BLENDER_VERSION="3.6.0"

# 必要なパッケージをインストール
echo "=== 必要なツールをインストール（ホスト側） ==="
sudo apt update
sudo apt install -y build-essential cmake git wget libx11-dev libxi-dev \
                    libgl1-mesa-dev libjpeg-dev libpng-dev libtiff-dev \
                    libopenal-dev libsndfile1-dev libxfixes-dev libxcursor-dev \
                    libxrandr-dev libxxf86vm-dev libxinerama-dev libglew-dev \
                    libfreetype6-dev libsqlite3-dev libbz2-dev liblzma-dev

# 作業用ディレクトリの作成（ビルドは /tmp で実施）
mkdir -p /tmp/blender_build
cd /tmp/blender_build

# Blender のソースコードを取得
echo "=== Blender ${BLENDER_VERSION} のソースコードを取得 ==="
git clone --branch v${BLENDER_VERSION} --depth 1 https://git.blender.org/blender.git
cd blender

# OpenMP サポート & 静的リンクでコンパイル
echo "=== Blender を静的リンクでビルド ==="
make -j$(nproc) BUILD_CMAKE_ARGS="-DWITH_OPENMP=ON -DWITH_STATIC_LIBS=ON -DCMAKE_EXE_LINKER_FLAGS='-static'"

# インストールディレクトリを `$HOME/mic/bin/` に変更
mkdir -p $HOME/mic/bin/blender-${BLENDER_VERSION}
cp -r build_linux/bin/* $HOME/mic/bin/blender-${BLENDER_VERSION}/

# Blender を Xeon Phi に転送
echo "=== Blender を Xeon Phi に転送 ==="
scp -r $HOME/mic/bin mic0:/home/mic/bin/

# Xeon Phi 側でインストール確認
echo "=== Xeon Phi 側で Blender のバージョン確認 ==="
ssh mic0 "/home/mic/bin/blender-${BLENDER_VERSION}/blender --version"

# 作業ディレクトリの削除（オプション）
rm -rf /tmp/blender_build

echo "=== ビルド用ファイルをクリーンアップしました ==="
echo "=== Xeon Phi に Blender の静的リンクインストールが完了しました！ ==="
