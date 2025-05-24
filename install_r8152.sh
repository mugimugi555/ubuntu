#!/bin/bash
set -e

echo "🛠️ Realtek r8152 ドライバをインストールします..."

# --- ドライバディレクトリを確認 ---
DRIVER_DIR="$HOME/Downloads/r8152-2.20.1"
if [ ! -d "$DRIVER_DIR" ]; then
  echo "❌ ドライバディレクトリが見つかりません: $DRIVER_DIR"
  echo "🔍 GitHubなどから r8152 ソースを取得してください。"
  exit 1
fi

# --- 1. cdc_ncm / cdc_ether を無効化（blacklist） ---
echo "🔧 cdc_ncm / cdc_ether を無効化します..."
echo "blacklist cdc_ncm"   | sudo tee /etc/modprobe.d/blacklist-cdc_ncm.conf
echo "blacklist cdc_ether" | sudo tee /etc/modprobe.d/blacklist-cdc_ether.conf

# --- 2. 古い r8152 モジュールを削除（もしあれば） ---
echo "🧹 古い r8152 モジュールを削除します..."
sudo rmmod r8152 2>/dev/null || true

# --- 3. ソースディレクトリに移動しビルド ---
echo "🔨 ドライバをビルド中..."
cd "$DRIVER_DIR"
make clean
make

# --- 4. インストール ---
echo "📦 ドライバをインストール中..."
sudo make install
sudo depmod -a

# --- 5. モジュールを有効化 ---
echo "🔌 r8152 モジュールをロード中..."
sudo modprobe r8152

# --- 6. 成功メッセージと再起動提案 ---
echo "✅ r8152 のインストール完了！再接続または再起動をおすすめします。"
