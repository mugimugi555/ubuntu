#!/bin/bash

echo "=== Xeon Phi に OpenCV (静的リンク) をインストール ==="

# バージョン指定
OPENCV_VERSION="4.8.0"
INSTALL_DIR="$HOME/mic/bin/opencv-${OPENCV_VERSION}"

# 必要なライブラリをホストPCにインストール
echo "=== 必要なツールをインストール（ホスト側） ==="
sudo apt update
sudo apt install -y build-essential cmake g++ wget unzip \
                    libjpeg-dev libpng-dev libtiff-dev \
                    libavcodec-dev libavformat-dev libswscale-dev

### 1️⃣ ホスト側で OpenCV のビルド & 転送 ###
echo "=== ホスト側で OpenCV ${OPENCV_VERSION} のビルド開始 ==="

# 作業ディレクトリの作成（ビルドは /tmp で実施）
mkdir -p /tmp/opencv_build
cd /tmp/opencv_build

# OpenCV のソースコードを取得
git clone --branch ${OPENCV_VERSION} --depth 1 https://github.com/opencv/opencv.git
git clone --branch ${OPENCV_VERSION} --depth 1 https://github.com/opencv/opencv_contrib.git
cd opencv

# OpenCV を静的リンクでビルド
mkdir -p build
cd build

cmake -D CMAKE_BUILD_TYPE=RELEASE \
      -D CMAKE_INSTALL_PREFIX=${INSTALL_DIR} \
      -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules \
      -D ENABLE_CXX11=ON -D WITH_OPENMP=ON -D WITH_TBB=OFF \
      -D WITH_GTK=OFF -D WITH_QT=OFF -D BUILD_EXAMPLES=OFF \
      -D BUILD_opencv_apps=OFF -D BUILD_TESTS=OFF -D BUILD_DOCS=OFF \
      -D BUILD_PERF_TESTS=OFF -D ENABLE_PRECOMPILED_HEADERS=OFF \
      -D ENABLE_NEON=OFF -D WITH_V4L=OFF -D WITH_OPENGL=OFF \
      -D WITH_FFMPEG=ON -D WITH_AVFOUNDATION=OFF \
      -D BUILD_SHARED_LIBS=OFF -D CMAKE_EXE_LINKER_FLAGS="-static" ..

make -j$(nproc)
make install

# OpenCV を Xeon Phi に転送
echo "=== OpenCV を Xeon Phi に転送 ==="
scp -r $HOME/mic/bin mic0:/home/mic/bin/

# 作業ディレクトリの削除（オプション）
rm -rf /tmp/opencv_build

echo "=== OpenCV のビルド & クリーンアップ完了 ==="

---

### 2️⃣ Xeon Phi 側で環境変数の設定 & 確認 ###
echo "=== Xeon Phi 側で環境変数を設定 & インストール確認 ==="
ssh mic0 << 'EOF'
    OPENCV_VERSION="4.8.0"

    # 環境変数を設定
    echo "export PATH=/home/mic/bin/opencv-${OPENCV_VERSION}/bin:\$PATH" >> ~/.bashrc
    source ~/.bashrc

    # インストール確認
    echo "=== Xeon Phi 側で OpenCV のバージョン確認 ==="
    /home/mic/bin/opencv-${OPENCV_VERSION}/bin/opencv_version
EOF

echo "=== Xeon Phi に OpenCV (静的リンク) のインストールが完了しました！ ==="
