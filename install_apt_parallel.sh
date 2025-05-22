#!/bin/bash

# 🔐 自動的に root 権限で再実行する
if [[ $EUID -ne 0 ]]; then
  echo "🔐 root 権限が必要です。sudo を使って再実行します..."
  exec sudo "$0" "$@"
  exit 1
fi

echo "🔄 APT の並列ダウンロードを有効化中..."

# `apt` の並列ダウンロード設定
cat <<EOF | tee /etc/apt/apt.conf.d/90parallel
Acquire::Queue-Mode "access";
Acquire::http::Pipeline-Depth "10";
Acquire::http::No-Cache "true";
Acquire::Retries "5";
EOF

echo "🚀 APT を並列ダウンロードで更新中..."
apt update -y
apt upgrade -y

echo "✅ インストールと設定が完了しました！"
