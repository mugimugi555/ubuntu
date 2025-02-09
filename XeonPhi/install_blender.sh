#!/bin/bash

echo "=== Xeon Phi に Blender (静的リンク) をインストール ==="

# バージョン指定
BLENDER_VERSION="3.6.0"
INSTALL_DIR="/home/mic/blender-${BLENDER_VERSION}"

# 必要なパッケージをインストール
echo "=== 必要なツールをインストール（ホスト側） ==="
sudo apt update
sudo apt install -y build-essential cmake git wget libx11-dev libxi-dev libgl1-mesa-dev libjpeg-dev libpng-dev libtiff-dev

# ソースコードを取得
cd /tmp
echo "=== Blender ${BLENDER_VERSION} のソースコードを取得 ==="
git clone --branch v${BLENDER_VERSION} --depth 1 https://git.blender.org/blender.git
cd blender

# OpenMP サポート & 静的リンクでコンパイル
echo "=== Blender を静的リンクでビルド ==="
make -j$(nproc) BUILD_CMAKE_ARGS="-DWITH_OPENMP=ON -DWITH_STATIC_LIBS=ON -DCMAKE_EXE_LINKER_FLAGS='-static'"

# Xeon Phi に転送
echo "=== Blender を Xeon Phi に転送 ==="
scp -r build_linux/bin/blender mic0:/home/mic/blender-${BLENDER_VERSION}

# Xeon Phi 側で環境変数の設定 & インストール確認
echo "=== Xeon Phi 側で環境変数を設定 & インストール確認 ==="
ssh mic0 << 'EOF'
    BLENDER_VERSION="3.6.0"
    INSTALL_DIR="/home/mic/blender-${BLENDER_VERSION}"

    # 環境変数を設定
    echo "export PATH=${INSTALL_DIR}/bin:\$PATH" >> ~/.bashrc
    source ~/.bashrc

    # インストール確認
    echo "=== Xeon Phi 側で Blender のバージョン確認 ==="
    blender --version
EOF

echo "=== Xeon Phi に Blender の静的リンクインストールが完了しました！ ==="
