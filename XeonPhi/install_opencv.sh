#!/bin/bash

echo "=== Xeon Phi で OpenCV を使用する準備 ==="

### 1️⃣ Xeon Phi に OpenCV があるか確認 ###
echo "=== Xeon Phi の OpenCV 確認 ==="

# Xeon Phi で OpenCV が存在するか確認
ssh mic0 'if [ ! -f "/home/mic/opencv/bin/python3" ] || ! /home/mic/opencv/bin/python3 -c "import cv2" 2>/dev/null; then exit 1; else exit 0; fi'
if [ $? -eq 1 ]; then
    echo "=== OpenCV が見つかりません。ビルドを開始します... ==="

    # 必要なライブラリをホストPCにインストール
    sudo apt update
    sudo apt install -y build-essential cmake g++ wget unzip \
                        libjpeg-dev libpng-dev libtiff-dev \
                        libavcodec-dev libavformat-dev libswscale-dev

    # OpenCV のソースコードを取得
    cd /tmp
    git clone https://github.com/opencv/opencv.git
    git clone https://github.com/opencv/opencv_contrib.git
    cd opencv

    # OpenCV を静的リンクでビルド
    mkdir -p build && cd build
    cmake -D CMAKE_BUILD_TYPE=RELEASE \
          -D CMAKE_INSTALL_PREFIX=/home/mic/opencv \
          -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules \
          -D ENABLE_CXX11=ON \
          -D WITH_OPENMP=ON \
          -D WITH_TBB=OFF \
          -D WITH_GTK=OFF \
          -D WITH_QT=OFF \
          -D BUILD_EXAMPLES=OFF \
          -D BUILD_opencv_apps=OFF \
          -D BUILD_TESTS=OFF \
          -D BUILD_DOCS=OFF \
          -D BUILD_PERF_TESTS=OFF \
          -D ENABLE_PRECOMPILED_HEADERS=OFF \
          -D ENABLE_NEON=OFF \
          -D WITH_V4L=OFF \
          -D WITH_OPENGL=OFF \
          -D WITH_FFMPEG=ON \
          -D WITH_AVFOUNDATION=OFF \
          -D BUILD_SHARED_LIBS=OFF \
          -D CMAKE_EXE_LINKER_FLAGS="-static" ..
    make -j$(nproc)
    make install

    # OpenCV を Xeon Phi に転送
    scp -r /home/mic/opencv mic0:/home/mic/

    # 動作確認
    ssh mic0 "/home/mic/opencv/bin/python3 -c 'import cv2; print(cv2.__version__)'"

    echo "=== OpenCV のビルド & 転送完了 ==="
else
    echo "=== OpenCV は既にインストール済み ==="
fi

---

### 2️⃣ YouTube から動画をダウンロード & 転送 ###
echo "=== yt-dlp を使用して動画をダウンロード ==="

# ダウンロードする動画 URL
VIDEO_URL="https://www.youtube.com/watch?v=EPJe3FqMSy0"

# yt-dlp をホストPCで実行
./yt-dlp -f "best" "$VIDEO_URL" -o "downloaded_video.mp4"

# Xeon Phi に動画をアップロード
scp downloaded_video.mp4 mic0:/home/mic/
echo "=== 動画のダウンロード & アップロード完了 ==="

---

### 3️⃣ Xeon Phi で OpenCV による動画処理（エフェクト or 顔認識） ###
echo "=== Xeon Phi で OpenCV による動画処理を実行 ==="

# OpenCV の処理スクリプトを作成 & 転送
cat << EOF > process_video.py
import cv2

# 動画の読み込み
cap = cv2.VideoCapture("/home/mic/downloaded_video.mp4")
if not cap.isOpened():
    print("動画を開けません！")
    exit()

# 出力ファイルの設定
fourcc = cv2.VideoWriter_fourcc(*"mp4v")
out = cv2.VideoWriter("/home/mic/output.mp4", fourcc, 30, (int(cap.get(3)), int(cap.get(4))))

# Haarcascades を使用した顔認識
face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + "haarcascade_frontalface_default.xml")

while True:
    ret, frame = cap.read()
    if not ret:
        break

    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    faces = face_cascade.detectMultiScale(gray, 1.3, 5)

    for (x, y, w, h) in faces:
        cv2.rectangle(frame, (x, y), (x+w, y+h), (255, 0, 0), 2)  # 顔を矩形で囲む

    out.write(frame)

cap.release()
out.release()
print("=== 動画処理完了 ===")
EOF

# スクリプトを Xeon Phi に転送して実行
scp process_video.py mic0:/home/mic/
ssh mic0 "/home/mic/opencv/bin/python3 /home/mic/process_video.py"

---

### 4️⃣ 処理済み動画をホストに取得 ###
echo "=== 処理済み動画を取得 ==="
scp mic0:/home/mic/output.mp4 .
echo "=== すべての処理が完了しました！ ==="
