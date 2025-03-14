#!/bin/bash

# スクリプトを root で実行する必要がある
if [[ $EUID -ne 0 ]]; then
    echo "このスクリプトは root 権限が必要です。sudo をつけて実行してください。" >&2
    exit 1
fi

echo "🔄 APT の並列ダウンロードを有効化中..."

# 1. `Acquire::Queue-Mode` を設定
echo 'Acquire::Queue-Mode "access";' | tee /etc/apt/apt.conf.d/90parallel
echo 'Acquire::http::Pipeline-Depth "10";' | tee -a /etc/apt/apt.conf.d/90parallel
echo 'Acquire::http::No-Cache "true";' | tee -a /etc/apt/apt.conf.d/90parallel
echo 'Acquire::Retries "5";' | tee -a /etc/apt/apt.conf.d/90parallel

# 2. `aria2` をインストール
echo "📥 aria2 をインストール中..."
apt update -y
apt install -y aria2

# 3. `apt-fast` をインストール
echo "📥 apt-fast をインストール中..."
add-apt-repository -y ppa:apt-fast/stable
apt update -y
apt install -y apt-fast

# 4. `apt-fast` の設定を最適化
echo 'Acquire::http::Dl-Limit "0";' | tee /etc/apt/apt.conf.d/99apt-fast
echo 'Acquire::http { Proxy ""; };' | tee -a /etc/apt/apt.conf.d/99apt-fast
echo 'Acquire::https { Proxy ""; };' | tee -a /etc/apt/apt.conf.d/99apt-fast
echo 'Acquire::ftp { Proxy ""; };' | tee -a /etc/apt/apt.conf.d/99apt-fast
echo 'Acquire::Retries "5";' | tee -a /etc/apt/apt.conf.d/99apt-fast

# 5. `apt-fast update` を実行
echo "🚀 並列ダウンロードで APT を更新中..."
apt-fast update -y

echo "✅ インストールと設定が完了しました！"
