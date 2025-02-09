#!/bin/bash

echo "=== Xeon Phi で ImageMagick を使用する準備 ==="

### 1️⃣ ImageMagick のビルド（静的リンク） & 転送 ###
echo "=== ImageMagick を静的リンクでビルド & 転送 ==="

# 必要なライブラリをホストPCにインストール
sudo apt update
sudo apt install -y build-essential libjpeg-dev libpng-dev libtiff-dev libwebp-dev

# ImageMagick のソースコードを取得
cd /tmp
git clone https://github.com/ImageMagick/ImageMagick.git
cd ImageMagick

# ImageMagick を静的リンクでビルド
./configure --prefix=/home/mic/imagemagick --enable-openmp --disable-shared LDFLAGS="-static"
make -j$(nproc)
make install

# ImageMagick を Xeon Phi に転送
scp -r /home/mic/imagemagick mic0:/home/mic/

# 動作確認
ssh mic0 "/home/mic/imagemagick/bin/magick -version"

echo "=== ImageMagick のビルド & 転送完了 ==="

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

### 3️⃣ Xeon Phi で ImageMagick による動画 → 静止画変換 + エッジフィルタ ###
echo "=== Xeon Phi で動画を静止画に変換 & エッジフィルタ適用 ==="

ssh mic0 << 'EOF'
    echo "=== ImageMagick で動画を静止画に変換 ==="

    # 動画を静止画（1 秒ごと）に変換
    /home/mic/imagemagick/bin/magick convert /home/mic/downloaded_video.mp4 -scene 1 /home/mic/frame_%04d.png

    echo "=== 静止画にエッジ検出フィルタを適用 ==="

    # すべてのフレームにエッジフィルターを適用
    export OMP_NUM_THREADS=240
    for file in /home/mic/frame_*.png; do
        /home/mic/imagemagick/bin/magick convert "$file" -edge 1 "/home/mic/edge_$file"
    done

    echo "=== 静止画処理完了 ==="
EOF

---

### 4️⃣ 処理済み画像をホストに取得 ###
echo "=== 処理済み画像を取得 ==="
scp mic0:/home/mic/edge_frame_*.png .
echo "=== すべての処理が完了しました！ ==="
