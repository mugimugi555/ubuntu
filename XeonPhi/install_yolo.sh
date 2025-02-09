#!/bin/bash

echo "=== Xeon Phi に OpenCV と YOLO をインストール ==="

# 必要なライブラリをインストール
ssh mic0 'sudo apt update && sudo apt install -y cmake g++ wget unzip python3-dev python3-numpy \
                    libjpeg-dev libpng-dev libtiff-dev libavcodec-dev libavformat-dev libswscale-dev'

# OpenCV のインストール（なければビルド）
ssh mic0 'if ! command -v python3 &> /dev/null || ! python3 -c "import cv2" 2>/dev/null; then
    echo "OpenCV をビルドします..."
    git clone https://github.com/opencv/opencv.git && git clone https://github.com/opencv/opencv_contrib.git
    mkdir -p opencv/build && cd opencv/build
    cmake -D CMAKE_BUILD_TYPE=RELEASE \
          -D CMAKE_INSTALL_PREFIX=/usr/local \
          -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules \
          -D ENABLE_CXX11=ON -D WITH_OPENMP=ON -D WITH_TBB=OFF -D WITH_GTK=OFF -D WITH_QT=OFF \
          -D BUILD_EXAMPLES=OFF -D BUILD_opencv_apps=OFF -D BUILD_TESTS=OFF -D BUILD_DOCS=OFF \
          -D BUILD_PERF_TESTS=OFF -D ENABLE_PRECOMPILED_HEADERS=OFF -D ENABLE_NEON=OFF \
          -D WITH_V4L=OFF -D WITH_OPENGL=OFF -D WITH_FFMPEG=ON -D WITH_AVFOUNDATION=OFF ..
    make -j$(nproc) && sudo make install
fi'

echo "=== YOLO モデルのダウンロード ==="
ssh mic0 'mkdir -p /home/mic/yolo && cd /home/mic/yolo'
ssh mic0 'wget -O /home/mic/yolo/yolov3.weights https://pjreddie.com/media/files/yolov3.weights'
ssh mic0 'wget -O /home/mic/yolo/yolov3.cfg https://github.com/pjreddie/darknet/blob/master/cfg/yolov3.cfg?raw=true'
ssh mic0 'wget -O /home/mic/yolo/coco.names https://github.com/pjreddie/darknet/blob/master/data/coco.names?raw=true'

echo "=== OpenCV & YOLO のインストール完了 ==="

### 2️⃣ 動画のダウンロード（yt-dlp を使用） ###
echo "=== ut-dlp（yt-dlp）を使用して動画をダウンロード ==="

VIDEO_URL="https://www.youtube.com/watch?v=EPJe3FqMSy0"

if ! command -v yt-dlp &> /dev/null; then
    echo "yt-dlp をインストール..."
    pip3 install -U yt-dlp
fi

yt-dlp -f "best" "$VIDEO_URL" -o "downloaded_video.mp4"

# Xeon Phi に動画をアップロード
scp downloaded_video.mp4 mic0:/home/mic/
echo "=== 動画のダウンロード & アップロード完了 ==="

### 3️⃣ Xeon Phi で YOLO を実行 ###
echo "=== Xeon Phi で YOLO による物体検出を実行 ==="

# OpenCV の処理スクリプトを作成 & 転送
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
ssh mic0 "python3 /home/mic/yolo_detect.py"

### 4️⃣ 処理済み動画をホストに取得 ###
echo "=== 処理済み動画を取得 ==="
scp mic0:/home/mic/output.mp4 .

echo "=== すべての処理が完了しました！ ==="
