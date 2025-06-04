#!/bin/bash
set -e

echo "🔰 Waydroid 自動インストールスクリプト (Wayland / X11 判別対応)"

# 1. ディスプレイサーバーの種類を判定
if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
  ENV_TYPE="wayland"
else
  ENV_TYPE="x11"
fi

echo "🖥️ 検出されたセッションタイプ: $ENV_TYPE"

# 2. Waydroid リポジトリ追加
echo "🔸 Waydroid リポジトリを追加します..."
sudo apt update
sudo apt install -y curl ca-certificates gnupg lsb-release wget
curl -s https://repo.waydro.id | sudo bash

# 3. Waydroid 本体のインストール
echo "📦 Waydroid をインストールします..."
sudo apt install -y waydroid

# 4. カーネルモジュールの確認と警告
echo "🔎 binder/ashmem モジュールの確認..."
if ! lsmod | grep -q binder_linux; then
  echo "⚠️ binder_linux が読み込まれていません。"
fi
if ! lsmod | grep -q ashmem_linux; then
  echo "⚠️ ashmem_linux が読み込まれていません。"
fi

# 5. Waydroid 初期化（GAPPSあり）
echo "🔧 Waydroid の初期化を行います..."
sudo waydroid init -s GAPPS -f

# 6. サービス起動
echo "🔃 Waydroid コンテナサービスを有効化・起動します..."
sudo systemctl enable waydroid-container
sudo systemctl start waydroid-container

# 7. 起動コマンド（環境によって変える）
if [ "$ENV_TYPE" = "wayland" ]; then
  echo "🚀 Wayland 用 Waydroid を起動します..."
  waydroid show-full-ui
else
  echo "🚀 X11 用 Waydroid を起動します..."
  waydroid show-full-ui
fi
