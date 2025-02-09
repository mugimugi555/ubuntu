#!/bin/bash

echo "=== Xeon Phi で ImageMagick を使用する準備 ==="

### 1️⃣ Xeon Phi に ImageMagick があるか確認 ###
echo "=== Xeon Phi の ImageMagick 確認 ==="

# Xeon Phi で ImageMagick が存在するか確認
ssh mic0 'if [ ! -f "/home/mic/bin/imagemagick/bin/magick" ]; then exit 1; else exit 0; fi'
if [ $? -eq 1 ]; then
    echo "=== ImageMagick が見つかりません。ビルドを開始します... ==="

    # 必要なライブラリをホストPCにインストール
    sudo apt update
    sudo apt install -y build-essential libjpeg-dev libpng-dev libtiff-dev libwebp-dev

    # 作業ディレクトリの作成（ビルドは /tmp で実施）
    mkdir -p /tmp/imagemagick_build
    cd /tmp/imagemagick_build

    # ImageMagick のソースコードを取得
    git clone https://github.com/ImageMagick/ImageMagick.git
    cd ImageMagick

    # ImageMagick を静的リンクでビルド
    ./configure --prefix=$HOME/mic/bin/imagemagick --enable-openmp --disable-shared LDFLAGS="-static"
    make -j$(nproc)
    make install

    # ImageMagick を Xeon Phi に転送
    scp -r $HOME/mic/bin mic0:/home/mic/bin/

    # 動作確認
    ssh mic0 "/home/mic/bin/imagemagick/bin/magick -version"

    # 作業ディレクトリの削除（オプション）
    rm -rf /tmp/imagemagick_build

    echo "=== ImageMagick のビルド & 転送完了 ==="
else
    echo "=== ImageMagick は既にインストール済み ==="
fi

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

### 3️⃣ Xeon Phi で ImageMagick による動画 → 静止画変換 + エッジフィルタ ###
echo "=== Xeon Phi で動画を静止画に変換 & エッジフィルタ適用 ==="

ssh mic0 << 'EOF'
    echo "=== ImageMagick で動画を静止画に変換 ==="

    # 動画を静止画（1 秒ごと）に変換
    /home/mic/bin/imagemagick/bin/magick convert /home/mic/downloaded_video.mp4 -scene 1 /home/mic/frame_%04d.png

    echo "=== 静止画にエッジ検出フィルタを適用 ==="

    # すべてのフレームにエッジフィルターを適用
    export OMP_NUM_THREADS=240
    for file in /home/mic/frame_*.png; do
        /home/mic/bin/imagemagick/bin/magick convert "$file" -edge 1 "/home/mic/edge_$file"
    done

    echo "=== 静止画処理完了 ==="
EOF

---

### 4️⃣ 処理済み画像をホストに取得 ###
echo "=== 処理済み画像を取得 ==="
scp mic0:/home/mic/edge_frame_*.png .
echo "=== すべての処理が完了しました！ ==="
