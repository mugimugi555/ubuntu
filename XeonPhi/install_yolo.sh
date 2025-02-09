#!/bin/bash

echo "=== Xeon Phi で OpenCV & YOLO を使用する準備 ==="

### 1️⃣ OpenCV のビルド（静的リンク） & 転送 ###
echo "=== OpenCV を静的リンクでビルド & 転送 ==="

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
scp -r /home/mic/opencv mic0:/home/mic/

# 動作確認
ssh mic0 "/home/mic/opencv/bin/opencv_version"

echo "=== OpenCV のビルド & 転送完了 ==="

---

### 2️⃣ YOLO モデルのダウンロード & 転送 ###
echo "=== YOLO モデルをセットアップ ==="

ssh mic0 "mkdir -p /home/mic/yolo"
scp yolov3.weights mic0:/home/mic/yolo/yolov3.weights
scp yolov3.cfg mic0:/home/mic/yolo/yolov3.cfg
scp coco.names mic0:/home/mic/yolo/coco.names

echo "=== YOLO モデルのセットアップ完了 ==="

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

### 4️⃣ Xeon Phi で YOLO による物体検出を実行 ###
echo "=== Xeon Phi で YOLO による物体検出を実行 ==="

# YOLO の処理スクリプトを作成 & 転送
cat << EOF > yolo_detect.py
import cv2
import numpy as np

# YOLO モデルの読み込み
net = cv2.dnn.readNet("/home/mic/yolo/yolov3.weights", "/home/mic/yolo/yolov3.cfg")
layer_names = net.getLayerNames()
output_layers = [layer_names[i - 1] for i in net.getUnconnectedOutLayers()]
classes = open("/home/mic/yolo/coco.names").read().strip().split("\n")

# 動画の読み込み
cap = cv2.VideoCapture("/home/mic/downloaded_video.mp4")
fourcc = cv2.VideoWriter_fourcc(*"mp4v")
out = cv2.VideoWriter("/home/mic/output.mp4", fourcc, 30, (int(cap.get(3)), int(cap.get(4))))

while cap.isOpened():
    ret, frame = cap.read()
    if not ret:
        break

    height, width = frame.shape[:2]

    # 画像を YOLO に入力
    blob = cv2.dnn.blobFromImage(frame, 1/255.0, (416, 416), swapRB=True, crop=False)
    net.setInput(blob)
    detections = net.forward(output_layers)

    for detection in detections:
        for obj in detection:
            scores = obj[5:]
            class_id = np.argmax(scores)
            confidence = scores[class_id]
            if confidence > 0.5:
                box = obj[:4] * np.array([width, height, width, height])
                (centerX, centerY, w, h) = box.astype("int")
                x, y = int(centerX - w / 2), int(centerY - h / 2)

                # 検出されたオブジェクトを枠で囲む
                color = (0, 255, 0)
                cv2.rectangle(frame, (x, y), (x + w, y + h), color, 2)
                label = f"{classes[class_id]}: {confidence:.2f}"
                cv2.putText(frame, label, (x, y - 5), cv2.FONT_HERSHEY_SIMPLEX, 0.5, color, 2)

    out.write(frame)

cap.release()
out.release()
print("=== YOLO 物体検出完了！ ===")
EOF

# スクリプトを Xeon Phi に転送して実行
scp yolo_detect.py mic0:/home/mic/
ssh mic0 "/home/mic/opencv/bin/python3 /home/mic/yolo_detect.py"

---

### 5️⃣ 処理済み動画をホストに取得 ###
echo "=== 処理済み動画を取得 ==="
scp mic0:/home/mic/output.mp4 .

echo "=== すべての処理が完了しました！ ==="
