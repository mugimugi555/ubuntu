# Intel Xeon Phi (Knights Corner) 向け Ubuntu 環境構築ガイド

このリポジトリでは、Intel Xeon Phi（Knights Corner）向けの **Ubuntu 環境構築手順** を提供します。Python のインストール、OpenCV のビルド、YOLO（You Only Look Once）を使用した物体検出、ImageMagick の活用方法について解説しています。

---

## 📌 目次
- [前提条件](#前提条件)
- [Ubuntu のセットアップ](#ubuntu-のセットアップ)
- [必要なパッケージのインストール](#必要なパッケージのインストール)
- [Xeon Phi の認識と設定](#xeon-phi-の認識と設定)
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
                    libatlas-base-dev gfortran python3-dev intel-mic-kmod intel-mic-tools
```

---

## 📌 Xeon Phi の認識と設定
### Xeon Phi が認識されているか確認
```bash
lspci | grep -i "co-processor"
```
✅ **Xeon Phi が認識されていれば表示されます。**

### Xeon Phi 用のドライバがロードされているか確認
```bash
lsmod | grep mic
```
✅ **`mic.ko` モジュールがロードされていれば OK**

### `mic0` が正しく作成されているか確認
```bash
ls /dev/mic*
```
✅ `/dev/mic0` が表示されていれば OK。

### SSH 接続確認
```bash
ssh mic0 "echo 'Xeon Phi に正常に接続できます。'"
```
✅ **接続成功なら OK。失敗した場合は `mic0` の IP 設定を確認**

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
      -D BUILD_SHARED_LIBS=OFF \
      -D CMAKE_EXE_LINKER_FLAGS="-static" ..
make -j$(nproc)
make install
```

---

## 📌 YOLO（物体検出）の実行
Python のスクリプトは `for_upload/` ディレクトリに格納し、シェルスクリプトから実行することで再利用しやすくなります。

```bash
scp for_upload/yolo_detect.py mic0:/home/mic/
ssh mic0 "python3 /home/mic/yolo_detect.py"
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

Python スクリプトは `for_upload/` ディレクトリに格納し、シェルスクリプトから呼び出すことで、再利用しやすくなります。
