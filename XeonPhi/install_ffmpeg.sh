#!/bin/bash

### 1️⃣ 動画のダウンロード（ut-dlp を使用） ###
echo "=== ut-dlp（yt-dlp）を使用して動画をダウンロード ==="

# ダウンロードする動画 URL を設定（変更可能）
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

### 2️⃣ Xeon Phi に FFmpeg をインストール（なければビルド） ###
echo "=== Xeon Phi の FFmpeg 確認 ==="

# Xeon Phi に FFmpeg があるか確認
ssh mic0 'if [ ! -f "/home/mic/ffmpeg" ]; then echo "FFmpeg が見つかりません。ビルドを開始します..."; exit 1; else echo "FFmpeg は既にインストール済み"; exit 0; fi'
if [ $? -eq 1 ]; then
    echo "=== FFmpeg のビルドを開始 ==="

    # 必要なライブラリをインストール（ホスト側）
    sudo apt update
    sudo apt install -y yasm nasm libx264-dev libx265-dev libfdk-aac-dev libmp3lame-dev

    # ソースコードを取得 & ビルド
    git clone https://github.com/FFmpeg/FFmpeg.git
    cd FFmpeg
    ./configure --enable-gpl --enable-libx264 --enable-libx265 --enable-libfdk-aac --enable-libmp3lame \
                --enable-openmp --arch=x86_64 --target-os=linux --enable-avx512
    make -j$(nproc)
    cd ..

    # ビルドした FFmpeg を Xeon Phi に転送
    scp FFmpeg/ffmpeg mic0:/home/mic/
    echo "=== FFmpeg のインストール完了 ==="
fi

### 3️⃣ Xeon Phi で FFmpeg によるエンコード実行 ###
echo "=== Xeon Phi でエンコードを実行 ==="
ssh mic0 << 'EOF'
    echo "=== FFmpeg を使用してエンコード開始 ==="

    # H.264 エンコード
    /home/mic/ffmpeg -i /home/mic/downloaded_video.mp4 -c:v libx264 -preset fast -crf 23 -threads 240 /home/mic/output_h264.mp4

    # H.265 (HEVC) エンコード
    /home/mic/ffmpeg -i /home/mic/downloaded_video.mp4 -c:v libx265 -preset medium -crf 22 -threads 240 /home/mic/output_h265.mp4

    echo "=== エンコード完了 ==="
EOF

### 4️⃣ エンコード後の動画をホストに取得 ###
echo "=== エンコード済み動画を取得 ==="
scp mic0:/home/mic/output_h264.mp4 .
scp mic0:/home/mic/output_h265.mp4 .
echo "=== すべての処理が完了しました！ ==="
