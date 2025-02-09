#!/bin/bash

echo "=== OpenCV を静的リンクでビルド & 転送（ビルドは /tmp, バイナリは $HOME/mic/bin） ==="

# 必要なライブラリをホストPCにインストール
sudo apt update
sudo apt install -y build-essential cmake g++ wget unzip \
                    libjpeg-dev libpng-dev libtiff-dev \
                    libavcodec-dev libavformat-dev libswscale-dev

# 作業用フォルダの作成（ビルドは /tmp で実施）
mkdir -p /tmp/opencv_build
cd /tmp/opencv_build

# OpenCV のソースコードを取得
git clone https://github.com/opencv/opencv.git
git clone https://github.com/opencv/opencv_contrib.git
cd opencv

# OpenCV を静的リンクでビルド
mkdir -p /tmp/opencv_build/opencv/build
cd /tmp/opencv_build/opencv/build

cmake -D CMAKE_BUILD_TYPE=RELEASE \
      -D CMAKE_INSTALL_PREFIX=$HOME/mic/bin \
      -D OPENCV_EXTRA_MODULES_PATH=/tmp/opencv_build/opencv_contrib/modules \
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
scp -r $HOME/mic/bin mic0:/home/mic/bin/

# 動作確認
ssh mic0 "/home/mic/bin/bin/opencv_version"

echo "=== OpenCV のビルド & 転送完了 ==="

# 作業ディレクトリの削除（オプション）
rm -rf /tmp/opencv_build

echo "=== ビルド用ファイルをクリーンアップしました ==="
