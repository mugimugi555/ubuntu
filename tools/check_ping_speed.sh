#!/bin/bash

# 測定対象のミラーサーバー（host:port）
servers=(
  "jp.archive.ubuntu.com:80"
  "ftp.jp.debian.org:80"
  "ftp.yz.yamagata-u.ac.jp:80"
  "mirror.rackspace.com:80"
  "ftp.riken.jp:80"
  "1.1.1.1:53"
  "8.8.8.8:53"
  "ntp.nict.jp:123"
)

echo "🌐 各ミラーサイトへのTCP接続レイテンシ（ms）"
echo "---------------------------------------------"

for entry in "${servers[@]}"; do
  host=$(echo "$entry" | cut -d':' -f1)
  port=$(echo "$entry" | cut -d':' -f2)

  # 計測開始時刻（ミリ秒）
  start=$(date +%s%3N)

  # タイムアウト1秒でTCP接続を試みる
  timeout 1 bash -c "</dev/tcp/$host/$port" 2>/dev/null

  if [ $? -eq 0 ]; then
    end=$(date +%s%3N)
    duration=$((end - start))
    echo "$entry → ${duration}ms"
  else
    echo "$entry → 接続失敗"
  fi
done
