#!/bin/bash

# 必要なパッケージをインストール
echo "🔹 必要なパッケージをインストール中..."
sudo apt update
sudo apt install -y aria2 curl git software-properties-common

# `apt-fast` を GitHub からダウンロード & インストール
echo "🔹 apt-fast を GitHub からインストール..."
cd /usr/local/src
sudo git clone https://github.com/ilikenwf/apt-fast.git
cd apt-fast

# `apt-fast` をシステムにインストール
sudo install -m 755 apt-fast /usr/local/bin/
sudo install -m 755 apt-fast.conf /etc/
sudo install -m 755 man/apt-fast.8 /usr/share/man/man8/

# シンボリックリンクを作成
sudo ln -sf /usr/local/bin/apt-fast /usr/bin/apt-fast

# `apt-fast` の設定ファイルを作成・更新
echo "🔹 apt-fast の設定を適用..."
cat <<EOF | sudo tee /etc/apt-fast.conf
# apt-fast 設定ファイル
# aria2 を使用し、ダウンロードを最大化

DOWNLOADBEFORE=true
_MAXNUM=16
_MIRRORS=2
_DL_RATE=0
MIRRORS=(
    "http://ftp.riken.jp/Linux/ubuntu/"
    "http://ftp.jaist.ac.jp/pub/Linux/ubuntu/"
    "http://ftp.tsukuba.wide.ad.jp/Linux/ubuntu/"
)
EOF

# `apt` の並列ダウンロードを有効化
echo "🔹 apt の並列ダウンロードを有効化..."
sudo mkdir -p /etc/apt/apt.conf.d
cat <<EOF | sudo tee /etc/apt/apt.conf.d/99parallel
# apt の並列ダウンロード設定
APT::Acquire::Queue-Mode "access";
APT::Acquire::Retries "3";
APT::Get::AllowUnauthenticated "true";
Acquire::http { Pipeline-Depth "5"; };
Acquire::Retries "5";
EOF

# 設定が反映されたか確認
echo "🔹 apt-fast の設定:"
cat /etc/apt-fast.conf
echo "🔹 apt の並列ダウンロード設定:"
cat /etc/apt/apt.conf.d/99parallel

# `.bashrc` にエイリアスを追加（重複を防ぐ）
BASHRC_FILE="$HOME/.bashrc"
ALIAS_CMD="alias apt='function _apt() { case \"\$1\" in install|update|upgrade|dist-upgrade|full-upgrade) apt-fast \"\$@\";; *) command apt \"\$@\";; esac; }; _apt'"

if ! grep -q "alias apt=" "$BASHRC_FILE"; then
    echo "$ALIAS_CMD" >> "$BASHRC_FILE"
    echo "✅ .bashrc にエイリアスを追加しました。"
else
    echo "ℹ️ 既にエイリアスが設定されています。変更は不要です。"
fi

# エイリアスを即時適用
echo "🔄 エイリアスを適用中..."
source "$BASHRC_FILE"

echo "✅ apt-fast のソースインストール & apt の並列化が完了しました！"
echo "🔹 高速ダウンロードの例:"
echo "   sudo apt-fast install <package-name>"
echo "   sudo apt update && sudo apt upgrade"
