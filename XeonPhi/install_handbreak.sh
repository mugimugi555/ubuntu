#!/bin/bash

echo "=== Xeon Phi で yt-dlp & HandBrake を使用する準備 ==="

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

### 3️⃣ HandBrake のビルド（静的リンク） & 転送 ###
echo "=== HandBrake を静的リンクでビルド & 転送 ==="

# 必要なライブラリをホストPCにインストール
sudo apt update
sudo apt install -y yasm nasm libx264-dev libx265-dev libfdk-aac-dev libmp3lame-dev cmake gcc g++ make

# 作業ディレクトリの作成（ビルドは /tmp で実施）
mkdir -p /tmp/handbrake_build
cd /tmp/handbrake_build

# ソースコードを取得
git clone https://github.com/HandBrake/HandBrake.git
cd HandBrake

# HandBrake を静的リンクでビルド
./configure --prefix=$HOME/mic/bin/handbrake --enable-x264 --enable-x265 --enable-openmp LDFLAGS="-static"
make -j$(nproc)

# HandBrake を Xeon Phi に転送
scp -r $HOME/mic/bin mic0:/home/mic/bin/

# 動作確認
ssh mic0 "/home/mic/bin/handbrake/bin/HandBrakeCLI --version"

# 作業ディレクトリの削除（オプション）
rm -rf /tmp/handbrake_build

echo "=== HandBrake のビルド & クリーンアップ完了 ==="

---

### 4️⃣ Xeon Phi で HandBrake によるエンコード実行 ###
echo "=== Xeon Phi でエンコードを実行 ==="
ssh mic0 << 'EOF'
    echo "=== HandBrake を使用してエンコード開始 ==="

    # H.264 エンコード
    /home/mic/bin/handbrake/bin/HandBrakeCLI -i /home/mic/downloaded_video.mp4 -o /home/mic/output_h264.mp4 --encoder x264 --preset fast --quality 20 --threads 240

    # H.265 (HEVC) エンコード
    /home/mic/bin/handbrake/bin/HandBrakeCLI -i /home/mic/downloaded_video.mp4 -o /home/mic/output_h265.mp4 --encoder x265 --preset medium --quality 22 --threads 240

    echo "=== エンコード完了 ==="
EOF

---

### 5️⃣ エンコード後の動画をホストに取得 ###
echo "=== エンコード済み動画を取得 ==="
scp mic0:/home/mic/output_h264.mp4 .
scp mic0:/home/mic/output_h265.mp4 .
echo "=== すべての処理が完了しました！ ==="
