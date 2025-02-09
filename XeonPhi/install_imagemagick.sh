#!/bin/bash

### 1️⃣ Xeon Phi に ImageMagick をインストール（なければビルド） ###
echo "=== Xeon Phi の ImageMagick 確認 ==="

# Xeon Phi に ImageMagick があるか確認
ssh mic0 'if ! command -v magick &> /dev/null; then echo "ImageMagick が見つかりません。ビルドを開始します..."; exit 1; else echo "ImageMagick は既にインストール済み"; exit 0; fi'
if [ $? -eq 1 ]; then
    echo "=== ImageMagick のビルドを開始 ==="

    # 必要なライブラリをインストール（ホスト側）
    sudo apt update
    sudo apt install -y build-essential libjpeg-dev libpng-dev libtiff-dev libwebp-dev

    # ソースコードを取得 & ビルド
    git clone https://github.com/ImageMagick/ImageMagick.git
    cd ImageMagick
    ./configure --enable-openmp --disable-shared
    make -j$(nproc)
    cd ..

    # ビルドした ImageMagick を Xeon Phi に転送
    scp ImageMagick/utilities/magick mic0:/home/mic/
    echo "=== ImageMagick のインストール完了 ==="
fi

### 2️⃣ 動画のダウンロード（ut-dlp を使用） ###
echo "=== ut-dlp（yt-dlp）を使用して動画をダウンロード ==="

# ダウンロードする動画 URL
VIDEO_URL="https://www.youtube.com/watch?v=EPJe3FqMSy0"

# ut-dlp（yt-dlp）をインストール（なければ）
if ! command -v yt-dlp &> /dev/null; then
    echo "yt-dlp が見つかりません。インストールします..."
    pip3 install -U yt-dlp
fi

# YouTube から動画をダウンロード
yt-dlp -f "best" "$VIDEO_URL" -o "downloaded_video.mp4"

# Xeon Phi に動画をアップロード
scp downloaded_video.mp4 mic0:/home/mic/
echo "=== 動画のダウンロード & アップロード完了 ==="

### 3️⃣ Xeon Phi で ImageMagick による動画 → 静止画変換 + エッジ検出 ###
echo "=== Xeon Phi で動画を静止画に変換 & エッジフィルタ適用 ==="
ssh mic0 << 'EOF'
    echo "=== ImageMagick で動画を静止画に変換 ==="

    # 動画を静止画（1 秒ごと）に変換
    /home/mic/magick convert /home/mic/downloaded_video.mp4 -scene 1 /home/mic/frame_%04d.png

    echo "=== 静止画にエッジ検出フィルタを適用 ==="

    # すべてのフレームにエッジフィルターを適用
    OMP_NUM_THREADS=240
    for file in /home/mic/frame_*.png; do
        /home/mic/magick convert "$file" -edge 1 "/home/mic/edge_$file"
    done

    echo "=== 静止画処理完了 ==="
EOF

### 4️⃣ 処理済み画像をホストに取得 ###
echo "=== 処理済み画像を取得 ==="
scp mic0:/home/mic/edge_frame_*.png .
echo "=== すべての処理が完了しました！ ==="
