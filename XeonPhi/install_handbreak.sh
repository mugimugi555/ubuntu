#!/bin/bash

### 1️⃣ 動画のダウンロード（ut-dlp を使用） ###
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

### 2️⃣ Xeon Phi に HandBrake をインストール（なければビルド） ###
echo "=== Xeon Phi の HandBrake 確認 ==="

# Xeon Phi に HandBrake があるか確認
ssh mic0 'if [ ! -f "/home/mic/HandBrakeCLI" ]; then echo "HandBrake が見つかりません。ビルドを開始します..."; exit 1; else echo "HandBrake は既にインストール済み"; exit 0; fi'
if [ $? -eq 1 ]; then
    echo "=== HandBrake のビルドを開始 ==="

    # 必要なライブラリをインストール（ホスト側）
    sudo apt update
    sudo apt install -y yasm nasm libx264-dev libx265-dev libfdk-aac-dev libmp3lame-dev cmake gcc g++ make

    # ソースコードを取得 & ビルド
    git clone https://github.com/HandBrake/HandBrake.git
    cd HandBrake
    ./configure --enable-x264 --enable-x265 --enable-openmp
    make -j$(nproc)
    cd ..

    # ビルドした HandBrakeCLI を Xeon Phi に転送
    scp HandBrake/build/HandBrakeCLI mic0:/home/mic/
    echo "=== HandBrake のインストール完了 ==="
fi

### 3️⃣ Xeon Phi で HandBrake によるエンコード実行 ###
echo "=== Xeon Phi でエンコードを実行 ==="
ssh mic0 << 'EOF'
    echo "=== HandBrake を使用してエンコード開始 ==="

    # H.264 エンコード
    /home/mic/HandBrakeCLI -i /home/mic/downloaded_video.mp4 -o /home/mic/output_h264.mp4 --encoder x264 --preset fast --quality 20 --threads 240

    # H.265 (HEVC) エンコード
    /home/mic/HandBrakeCLI -i /home/mic/downloaded_video.mp4 -o /home/mic/output_h265.mp4 --encoder x265 --preset medium --quality 22 --threads 240

    echo "=== エンコード完了 ==="
EOF

### 4️⃣ エンコード後の動画をホストに取得 ###
echo "=== エンコード済み動画を取得 ==="
scp mic0:/home/mic/output_h264.mp4 .
scp mic0:/home/mic/output_h265.mp4 .
echo "=== すべての処理が完了しました！ ==="
