# Intel Xeon Phi (Knights Corner) 向け Ubuntu 環境構築ガイド

このリポジトリでは、Intel Xeon Phi（Knights Corner）向けの **Ubuntu 環境構築手順** を提供します。Python のインストール、OpenCV のビルド、YOLO（You Only Look Once）を使用した物体検出、ImageMagick の活用方法について解説しています。

---

## 📌 目次
- [前提条件](#前提条件)
- [Ubuntu のセットアップ](#ubuntu-のセットアップ)
- [必要なパッケージのインストール](#必要なパッケージのインストール)
- [Python のインストール](#python-のインストール)
- [OpenCV のビルドとインストール](#opencv-のビルドとインストール)
- [YOLO（物体検出）の実行](#yolo物体検出の実行)
- [ImageMagick のセットアップと活用](#imagemagick-のセットアップと活用)

---

## 📌 前提条件
Xeon Phi で Ubuntu を動作させる前に、以下の環境が必要です。

✅ **Intel Xeon Phi（Knights Corner）コプロセッサ**  
✅ **Ubuntu または類似の Linux 環境を実行できるホスト PC**  
✅ **基本的な Linux コマンドの知識**  
✅ **インターネット接続（パッケージのダウンロード用）**

---

## 📌 Ubuntu のセットアップ
1. **Ubuntu のイメージを Xeon Phi に書き込む**
   - Xeon Phi に対応した Ubuntu イメージを入手
   - USB またはネットワーク経由で Xeon Phi に書き込む

2. **Ubuntu の起動**
   - Xeon Phi を起動し、Ubuntu が動作することを確認

---

## 📌 必要なパッケージのインストール
以下のコマンドを実行して、必要なパッケージをインストールします。

```bash
sudo apt update
sudo apt install -y build-essential cmake git wget unzip pkg-config \
                    libjpeg-dev libpng-dev libtiff-dev libavcodec-dev \
                    libavformat-dev libswscale-dev libv4l-dev \
                    libxvidcore-dev libx264-dev libgtk-3-dev \
                    libatlas-base-dev gfortran python3-dev
```

---

## 📌 Python のインストール
デフォルトの Python バージョンが古い場合は、**Python 3.9 をソースからビルド** してインストールします。

```bash
cd /tmp
wget https://www.python.org/ftp/python/3.9.17/Python-3.9.17.tgz
tar xzf Python-3.9.17.tgz
cd Python-3.9.17

./configure --enable-optimizations
make -j$(nproc)
sudo make altinstall

python3.9 --version
```

---

## 📌 OpenCV のビルドとインストール

```bash
cd ~
git clone https://github.com/opencv/opencv.git
git clone https://github.com/opencv/opencv_contrib.git
cd opencv
mkdir build
cd build

cmake -D CMAKE_BUILD_TYPE=RELEASE \
      -D CMAKE_INSTALL_PREFIX=/home/mic/opencv \
      -D OPENCV_EXTRA_MODULES_PATH=~/opencv_contrib/modules \
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
```

---

## 📌 YOLO（物体検出）の実行

```bash
mkdir -p ~/yolo
cd ~/yolo
wget https://pjreddie.com/media/files/yolov3.weights
wget https://raw.githubusercontent.com/pjreddie/darknet/master/cfg/yolov3.cfg
wget https://raw.githubusercontent.com/pjreddie/darknet/master/data/coco.names
```

YOLO で動画処理を行うスクリプト（`yolo_detect.py`）を作成して実行します。

```python
import cv2
import numpy as np

net = cv2.dnn.readNet("yolov3.weights", "yolov3.cfg")
classes = open("coco.names").read().strip().split("\n")

cap = cv2.VideoCapture("input.mp4")
fourcc = cv2.VideoWriter_fourcc(*"mp4v")
out = cv2.VideoWriter("output.mp4", fourcc, 30.0, (int(cap.get(3)), int(cap.get(4))))

while cap.isOpened():
    ret, frame = cap.read()
    if not ret:
        break

    height, width, _ = frame.shape
    blob = cv2.dnn.blobFromImage(frame, 1/255.0, (416, 416), swapRB=True, crop=False)
    net.setInput(blob)
    outs = net.forward(net.getUnconnectedOutLayersNames())

    for detection in outs:
        for obj in detection:
            scores = obj[5:]
            class_id = np.argmax(scores)
            confidence = scores[class_id]
            if confidence > 0.5:
                box = obj[:4] * np.array([width, height, width, height])
                (centerX, centerY, w, h) = box.astype("int")
                x, y = int(centerX - w / 2), int(centerY - h / 2)
                cv2.rectangle(frame, (x, y), (x + w, y + h), (0, 255, 0), 2)
                cv2.putText(frame, f"{classes[class_id]}: {confidence:.2f}", (x, y - 5), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 2)

    out.write(frame)

cap.release()
out.release()
```

---

## 📌 ImageMagick のセットアップと活用
ImageMagick を静的リンクでビルドし、動画から静止画に変換、エッジフィルタを適用します。

```bash
/home/mic/imagemagick/bin/magick convert /home/mic/downloaded_video.mp4 -scene 1 /home/mic/frame_%04d.png
for file in /home/mic/frame_*.png; do
    /home/mic/imagemagick/bin/magick convert "$file" -edge 1 "/home/mic/edge_$file"
done
```

---

## 📌 追加情報
詳細な手順やカスタマイズ方法については、各スクリプトのコメントをご確認ください。

