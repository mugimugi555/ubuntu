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
mv dist/yt-dlp $HOME/mic/bin/yt-dlp_static

# Xeon Phi に転送
scp -r $HOME/mic/bin mic0:/home/mic/bin/

# 動作確認
ssh mic0 "/home/mic/bin/yt-dlp_static --version"

echo "=== yt-dlp のビルド & 転送完了 ==="

---

### 2️⃣ YouTube から動画をダウンロード & 転送 ###
echo "=== yt-dlp を使用して動画をダウンロード ==="

# ダウンロードする動画 URL
VIDEO_URL="https://www.youtube.com/watch?v=EPJe3FqMSy0"

# YouTube から動画をダウンロード
$HOME/mic/bin/yt-dlp_static -f "best" "$VIDEO_URL" -o "downloaded_video.mp4"

# Xeon Phi に動画をアップロード
scp downloaded_video.mp4 mic0:/home/mic/
echo "=== 動画のダウンロード & アップロード完了 ==="

---

### 3️⃣ FFmpeg のビルド（静的リンク） & 転送 ###
echo "=== FFmpeg を静的リンクでビルド & 転送 ==="

# 必要なライブラリをホストPCにインストール
sudo apt update
sudo apt install -y yasm nasm libx264-dev libx265-dev libfdk-aac-dev libmp3lame-dev

# 作業用ディレクトリの作成（ビルドは /tmp で実施）
mkdir -p /tmp/ffmpeg_build
cd /tmp/ffmpeg_build

# ソースコードを取得
git clone https://github.com/FFmpeg/FFmpeg.git
cd FFmpeg

# FFmpeg を静的リンクでビルド
./configure --prefix=$HOME/mic/bin/ffmpeg --enable-gpl --enable-libx264 --enable-libx265 --enable-libfdk-aac --enable-libmp3lame \
            --enable-openmp --arch=x86_64 --target-os=linux --enable-avx512 --disable-shared --enable-static LDFLAGS="-static"
make -j$(nproc)
make install

# FFmpeg を Xeon Phi に転送
scp -r $HOME/mic/bin mic0:/home/mic/bin/

# 動作確認
ssh mic0 "/home/mic/bin/ffmpeg/bin/ffmpeg -version"

# 作業ディレクトリの削除（オプション）
rm -rf /tmp/ffmpeg_build

echo "=== ビルド用ファイルをクリーンアップしました ==="
echo "=== Xeon Phi に FFmpeg の静的リンクインストールが完了しました！ ==="

---

### 4️⃣ Xeon Phi で FFmpeg によるエンコード実行 ###
echo "=== Xeon Phi でエンコードを実行 ==="
ssh mic0 << 'EOF'
    echo "=== FFmpeg を使用してエンコード開始 ==="

    # H.264 エンコード
    /home/mic/bin/ffmpeg/bin/ffmpeg -i /home/mic/downloaded_video.mp4 -c:v libx264 -preset fast -crf 23 -threads 240 /home/mic/output_h264.mp4

    # H.265 (HEVC) エンコード
    /home/mic/bin/ffmpeg/bin/ffmpeg -i /home/mic/downloaded_video.mp4 -c:v libx265 -preset medium -crf 22 -threads 240 /home/mic/output_h265.mp4

    echo "=== エンコード完了 ==="
EOF

---

### 5️⃣ エンコード後の動画をホストに取得 ###
echo "=== エンコード済み動画を取得 ==="
scp mic0:/home/mic/output_h264.mp4 .
scp mic0:/home/mic/output_h265.mp4 .
echo "=== すべての処理が完了しました！ ==="
