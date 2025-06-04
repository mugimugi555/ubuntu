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

# 7. 起動コマンド（Wayland / X11 判定）
if [ "$ENV_TYPE" = "wayland" ]; then
  echo "🚀 Wayland 用 Waydroid を起動します..."
  ALIAS_CMD="alias waydroid_start='waydroid show-full-ui'"
  sed -i '/alias waydroid_start=/d' ~/.bashrc
  echo "$ALIAS_CMD" >> ~/.bashrc
  waydroid show-full-ui
else
  echo "🚀 X11 用 Weston 経由で Waydroid を起動します..."
  sudo apt install -y weston x11-xserver-utils

  # 解像度取得（現在の物理ディスプレイ）
  SCREEN_RES=$(xrandr | grep '*' | awk '{print $1}' | head -n1)
  SCREEN_WIDTH=$(echo $SCREEN_RES | cut -d'x' -f1)
  SCREEN_HEIGHT=$(echo $SCREEN_RES | cut -d'x' -f2)

  if [ "$SCREEN_WIDTH" -ge 1920 ] && [ "$SCREEN_HEIGHT" -ge 1080 ]; then
    WESTON_W=1920
    WESTON_H=1080
  else
    WESTON_W=$SCREEN_WIDTH
    WESTON_H=$SCREEN_HEIGHT
  fi

  echo "📐 使用する Weston 解像度: ${WESTON_W}x${WESTON_H}"

  # 起動エイリアスを ~/.bashrc に追加
  echo "🔗 Weston + Waydroid 起動用 alias を ~/.bashrc に登録します..."
  ALIAS_CMD="alias waydroid_start='dbus-run-session -- bash -c \"weston --backend=x11-backend.so --width=${WESTON_W} --height=${WESTON_H} & sleep 3; export WAYLAND_DISPLAY=\\\$(basename \\\$(find \\\$XDG_RUNTIME_DIR -name 'wayland-*')); echo ✅ WAYLAND_DISPLAY=\\\$WAYLAND_DISPLAY; waydroid show-full-ui\"'"

  sed -i '/alias waydroid_start=/d' ~/.bashrc
  echo "$ALIAS_CMD" >> ~/.bashrc

  echo "✅ 'waydroid_start' エイリアスを ~/.bashrc に登録しました。"
  echo "💡 今すぐ有効にするには 'source ~/.bashrc' を実行してください。"

  # 起動（初回のみ）
  dbus-run-session -- bash -c "
    weston --backend=x11-backend.so --width=$WESTON_W --height=$WESTON_H &
    sleep 3
    export WAYLAND_DISPLAY=\$(basename \$(find \$XDG_RUNTIME_DIR -name 'wayland-*'))
    echo '✅ WAYLAND_DISPLAY='\$WAYLAND_DISPLAY
    waydroid show-full-ui
  "
fi
