#!/bin/bash

echo "=== OpenCV & YOLO を静的リンクでビルド & Xeon Phi に転送 ==="

### 1️⃣ OpenCV のビルド（静的リンク） & 転送 ###
echo "=== OpenCV を静的リンクでビルド & 転送 ==="

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
      -D CMAKE_INSTALL_PREFIX=$HOME/mic/bin/opencv \
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
echo "=== OpenCV を Xeon Phi に転送 ==="
scp -r $HOME/mic/bin/opencv mic0:/home/mic/bin/

# 動作確認
ssh mic0 "/home/mic/bin/opencv/bin/opencv_version"

echo "=== OpenCV のビルド & 転送完了 ==="

# 作業ディレクトリの削除（オプション）
rm -rf /tmp/opencv_build

echo "=== ビルド用ファイルをクリーンアップしました ==="

---

### 2️⃣ YOLO モデルのダウンロード ###
echo "=== YOLO モデルを Xeon Phi に直接ダウンロード ==="

# Xeon Phi でモデルのディレクトリを作成し、wget でダウンロード
ssh mic0 << 'EOF'
    mkdir -p /home/mic/yolo/models/
    cd /home/mic/yolo/models/
    wget -O yolov3.weights https://pjreddie.com/media/files/yolov3.weights
    wget -O yolov3.cfg https://github.com/pjreddie/darknet/raw/master/cfg/yolov3.cfg
    wget -O coco.names https://github.com/pjreddie/darknet/raw/master/data/coco.names
EOF

echo "=== YOLO モデルのダウンロード完了 ==="

---

### 3️⃣ YouTube から動画をダウンロード & 転送 ###
echo "=== yt-dlp を使用して動画をダウンロード ==="

# ダウンロードする動画 URL
VIDEO_URL="https://www.youtube.com/watch?v=EPJe3FqMSy0"

# yt-dlp をホストPCで実行
./yt-dlp -f "best" "$VIDEO_URL" -o "downloaded_video.mp4"

# Xeon Phi に動画をアップロード
scp downloaded_video.mp4 mic0:/home/mic/
echo "=== 動画のダウンロード & アップロード完了 ==="

---

### 4️⃣ Python スクリプトを Xeon Phi に転送 & 実行 ###
echo "=== Xeon Phi で YOLO による物体検出を実行 ==="

# `for_upload/` にある Python スクリプトを転送
scp for_upload/yolo_detect.py mic0:/home/mic/

# Xeon Phi で Python スクリプトを実行
ssh mic0 "/home/mic/bin/opencv/bin/python3 /home/mic/yolo_detect.py"

---

### 5️⃣ 処理済み動画をホストに取得 ###
echo "=== 処理済み動画を取得 ==="
scp mic0:/home/mic/output.mp4 .

echo "=== すべての処理が完了しました！ ==="
