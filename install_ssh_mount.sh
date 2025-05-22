#!/bin/bash
set -e

CONFIG="install_ssh_mount_config.json"

# jq チェック
if ! command -v jq &>/dev/null; then
    echo "❌ jq がインストールされていません。インストール中..."
    sudo apt update && sudo apt install -y jq
fi

# sshfs チェック
if ! command -v sshfs &>/dev/null; then
    echo "❌ sshfs がインストールされていません。インストール中..."
    sudo apt update && sudo apt install -y sshfs
fi

# 設定ファイルの存在確認
if [ ! -f "$CONFIG" ]; then
    echo "❌ 設定ファイル $CONFIG が見つかりません。"
    exit 1
fi

# JSONから情報取得
HOST=$(jq -r '.host' "$CONFIG")
USER=$(jq -r '.user' "$CONFIG")
COUNT=$(jq '.mounts | length' "$CONFIG")

echo "🔗 $USER@$HOST の $COUNT 件のマウント設定を処理中..."

# 各マウント処理
for ((i = 0; i < COUNT; i++)); do
  REMOTE=$(jq -r ".mounts[$i].remote" "$CONFIG")
  LOCAL=$(jq -r ".mounts[$i].local" "$CONFIG")

  if [ ! -d "$LOCAL" ]; then
    echo "📁 $LOCAL を作成します"
    sudo mkdir -p "$LOCAL"
    sudo chown $USER:$USER "$LOCAL"
  fi

  echo "🔗 $USER@$HOST:$REMOTE → $LOCAL にマウントします"
  sshfs "$USER@$HOST:$REMOTE" "$LOCAL" -o reconnect,ServerAliveInterval=15,ServerAliveCountMax=3

  # マウント確認（ls 実行）
  echo "📂 $LOCAL の内容:"
  ls -lah "$LOCAL"
  echo ""
done

echo "✅ すべてのマウントが完了し、確認も行いました。"
