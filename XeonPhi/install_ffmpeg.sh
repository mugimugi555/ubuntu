#!/bin/bash

echo "=== Xeon Phi で yt-dlp & FFmpeg を使用する準備 ==="

### 1️⃣ yt-dlp のビルド（静的リンク） & 転送 ###
echo "=== yt-dlp を静的リンクでビルド & 転送 ==="

# 必要なライブラリをホストPCにインストール
sudo apt update
sudo apt install -y build-essential python3 python3-pip zip

# yt-dlp のビルド（Python のスタンドアロン実行ファイルとして生成）
pip3 install --upgrade pip
pip3 install pyinstaller
pip3 install yt-dlp

# yt-dlp を静的リンクバイナリ化
pyinstaller --onefile $(which yt-dlp)
mv dist/yt-dlp yt-dlp_static

# Xeon Phi に転送
scp yt-dlp_static mic0:/home/mic/yt-dlp

# 動作確認
ssh mic0 "/home/mic/yt-dlp --version"

echo "=== yt-dlp のビルド & 転送完了 ==="

---

### 2️⃣ YouTube から動画をダウンロード & 転送 ###
echo "=== yt-dlp を使用して動画をダウンロード ==="

# ダウンロードする動画 URL
VIDEO_URL="https://www.youtube.com/watch?v=EPJe3FqMSy0"

# YouTube から動画をダウンロード
./yt-dlp -f "best" "$VIDEO_URL" -o "downloaded_video.mp4"

# Xeon Phi に動画をアップロード
scp downloaded_video.mp4 mic0:/home/mic/
echo "=== 動画のダウンロード & アップロード完了 ==="

---

### 3️⃣ FFmpeg のビルド（静的リンク） & 転送 ###
echo "=== FFmpeg を静的リンクでビルド & 転送 ==="

# 必要なライブラリをホストPCにインストール
sudo apt update
sudo apt install -y yasm nasm libx264-dev libx265-dev libfdk-aac-dev libmp3lame-dev

# ソースコードを取得 & ビルド
cd /tmp
git clone https://github.com/FFmpeg/FFmpeg.git
cd FFmpeg

# FFmpeg を静的リンクでビルド
./configure --prefix=/home/mic/ffmpeg --enable-gpl --enable-libx264 --enable-libx265 --enable-libfdk-aac --enable-libmp3lame \
            --enable-openmp --arch=x86_64 --target-os=linux --enable-avx512 --disable-shared --enable-static LDFLAGS="-static"
make -j$(nproc)
make install

# ビルドした FFmpeg を Xeon Phi に転送
scp -r /home/mic/ffmpeg mic0:/home/mic/

# 動作確認
ssh mic0 "/home/mic/ffmpeg/bin/ffmpeg -version"

echo "=== FFmpeg のビルド & 転送完了 ==="

---

### 4️⃣ Xeon Phi で FFmpeg によるエンコード実行 ###
echo "=== Xeon Phi でエンコードを実行 ==="
ssh mic0 << 'EOF'
    echo "=== FFmpeg を使用してエンコード開始 ==="

    # H.264 エンコード
    /home/mic/ffmpeg/bin/ffmpeg -i /home/mic/downloaded_video.mp4 -c:v libx264 -preset fast -crf 23 -threads 240 /home/mic/output_h264.mp4

    # H.265 (HEVC) エンコード
    /home/mic/ffmpeg/bin/ffmpeg -i /home/mic/downloaded_video.mp4 -c:v libx265 -preset medium -crf 22 -threads 240 /home/mic/output_h265.mp4

    echo "=== エンコード完了 ==="
EOF

---

### 5️⃣ エンコード後の動画をホストに取得 ###
echo "=== エンコード済み動画を取得 ==="
scp mic0:/home/mic/output_h264.mp4 .
scp mic0:/home/mic/output_h265.mp4 .
echo "=== すべての処理が完了しました！ ==="
