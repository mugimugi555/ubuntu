#!/bin/bash

# スクリプトを root で実行する必要がある
if [[ $EUID -ne 0 ]]; then
    echo "このスクリプトは root 権限が必要です。sudo をつけて実行してください。" >&2
    exit 1
fi

echo "🔄 APT の並列ダウンロードを有効化中..."

# 1. `apt` の並列ダウンロードを有効化
cat <<EOF | tee /etc/apt/apt.conf.d/90parallel
Acquire::Queue-Mode "access";
Acquire::http::Pipeline-Depth "10";
Acquire::http::No-Cache "true";
Acquire::Retries "5";
EOF

# 2. `aria2` をインストールし、`apt` のダウンロードを並列化
echo "📥 aria2 をインストール中..."
apt update -y
apt install -y aria2

echo 'Acquire::http::Proxy "http://127.0.0.1:8123/";' | tee /etc/apt/apt.conf.d/99aria2proxy

# 3. `apt` を実行（並列ダウンロード有効化済み）
echo "🚀 APT を並列ダウンロードで更新中..."
apt update -y
apt upgrade -y

echo "✅ インストールと設定が完了しました！"
