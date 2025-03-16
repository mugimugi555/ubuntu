#!/bin/bash

# スクリプトを root で実行する必要がある
if [[ $EUID -ne 0 ]]; then
    echo "このスクリプトは root 権限が必要です。sudo をつけて実行してください。" >&2
    exit 1
fi

echo "🔄 APT の並列ダウンロードを有効化中..."

# `apt` の並列ダウンロードを有効化
cat <<EOF | tee /etc/apt/apt.conf.d/90parallel
Acquire::Queue-Mode "access";
Acquire::http::Pipeline-Depth "10";
Acquire::http::No-Cache "true";
Acquire::Retries "5";
EOF

# APTリポジトリの更新とアップグレード
echo "🚀 APT を並列ダウンロードで更新中..."
apt update -y
apt upgrade -y

echo "✅ インストールと設定が完了しました！"
