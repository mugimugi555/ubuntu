#!/bin/bash
set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔰 Waydroid 自動インストールスクリプト (Wayland / X11 判別対応)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 1. ディスプレイサーバーの種類を判定
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 セッションタイプの確認中..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
  ENV_TYPE="wayland"
else
  ENV_TYPE="x11"
fi
echo "🖥️  検出されたセッションタイプ: $ENV_TYPE"

# 2. Waydroid リポジトリ追加
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔸 Waydroid リポジトリを追加します..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
sudo apt update
sudo apt install -y curl ca-certificates gnupg lsb-release wget
curl -s https://repo.waydro.id | sudo bash

# 3. Waydroid 本体のインストール
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Waydroid をインストールします..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
sudo apt install -y waydroid

# 4. カーネルモジュールの確認
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔎 binder/ashmem モジュールの確認..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if ! lsmod | grep -q binder_linux; then
  echo "⚠️ binder_linux が読み込まれていません。"
fi
if ! lsmod | grep -q ashmem_linux; then
  echo "⚠️ ashmem_linux が読み込まれていません。"
fi

# 5. 初期化
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔧 Waydroid の初期化（GAPPS）..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
sudo waydroid init -s GAPPS -f

# 6. サービス起動
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔃 Waydroid コンテナサービスを起動中..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
sudo systemctl enable waydroid-container
sudo systemctl start waydroid-container

# 6.5 セッション停止
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🛑 既存の Waydroid セッションを停止中..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
waydroid session stop || true

# 7. 起動設定と初回起動
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 Waydroid 起動設定（$ENV_TYPE）..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$ENV_TYPE" = "wayland" ]; then

  echo "🔗 Wayland 用 alias を登録中..."
  ALIAS_CMD="alias waydroid_start='waydroid session stop || true && waydroid show-full-ui'"
  sed -i '/alias waydroid_start=/d' ~/.bashrc
  echo "$ALIAS_CMD" >> ~/.bashrc

  echo "🟢 Waydroid 起動（ウィンドウモード）..."
  waydroid show-full-ui &

else
  echo "🔗 X11 用 weston 経由の Waydroid 起動を準備中..."
  sudo apt install -y weston x11-xserver-utils

  if pgrep -f "weston --backend=x11-backend.so" > /dev/null; then
    echo "🛑 既存の Weston を終了します..."
    pkill -f "weston --backend=x11-backend.so"
    sleep 1
  fi

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

  echo "📐 Weston 解像度: ${WESTON_W}x${WESTON_H}"

  echo "🔗 alias を登録中..."
  ALIAS_CMD="alias waydroid_start='
    pkill -f \"weston --backend=x11-backend.so\" 2>/dev/null || true;
    waydroid session stop || true;
    dbus-run-session -- bash -c \"
      weston --backend=x11-backend.so --width=${WESTON_W} --height=${WESTON_H} &
      sleep 3;
      export WAYLAND_DISPLAY=\\\$(basename \\\$(find \\\\$XDG_RUNTIME_DIR -name 'wayland-*'));
      echo ✅ WAYLAND_DISPLAY=\\\$WAYLAND_DISPLAY;
      waydroid show-full-ui
    \"
  '"

  sed -i '/alias waydroid_start=/d' ~/.bashrc
  echo "$ALIAS_CMD" >> ~/.bashrc

  echo "🟢 初回起動中..."
  dbus-run-session -- bash -c "
    weston --backend=x11-backend.so --width=$WESTON_W --height=$WESTON_H &
    sleep 3
    export WAYLAND_DISPLAY=\$(basename \$(find \$XDG_RUNTIME_DIR -name 'wayland-*'))
    echo '✅ WAYLAND_DISPLAY='\$WAYLAND_DISPLAY
    waydroid show-full-ui
  " &
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 'waydroid_start' エイリアスを ~/.bashrc に登録しました。"
echo "💡 有効にするには次を実行してください: source ~/.bashrc"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
