#!/bin/bash
set -e

echo "🔹 Waydroid インストール開始..."

# 必要な依存関係をインストール
echo "🔸 依存関係をインストール..."
sudo apt update
sudo apt install -y curl ca-certificates gnupg lsb-release wget jq

# Waydroid リポジトリの追加
echo "🔸 Waydroid リポジトリを追加..."
curl -fsSL https://repo.waydro.id | sudo bash

# Waydroid のインストール
echo "🔸 Waydroid をインストール..."
sudo apt update
sudo apt install -y waydroid

# カーネルモジュールの確認
echo "🔸 binder, ashmem の確認・有効化..."
sudo modprobe binder_linux || echo "⚠️ binder_linux がロードできません。"
sudo modprobe ashmem_linux || echo "⚠️ ashmem_linux がロードできません。"

# Waydroid 初期化
echo "🔸 Waydroid を初期化..."
sudo waydroid init

# Waydroid サービス起動
echo "🔸 Waydroid サービスを起動します..."
sudo systemctl enable waydroid-container
sudo systemctl start waydroid-container

# GUI起動方法案内
echo "✅ インストール完了！Waydroid を起動するには以下を実行してください："
echo ""
echo "  waydroid session start"
echo "  waydroid show-full-ui"
