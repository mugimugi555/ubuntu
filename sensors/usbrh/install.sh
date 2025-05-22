#!/bin/bash

# USBrH センサーのセットアップスクリプト
# 実行前に sudo 権限が必要（sudo 実行か先に sudo -v）

set -e

echo "🛠️ usbrh-linux をクローン中..."
git clone https://github.com/osapon/usbrh-linux.git
cd usbrh-linux

echo "📦 必要なパッケージをインストール中..."
sudo apt update
sudo apt install -y libusb-dev build-essential

echo "🔨 ビルド実行中..."
make

echo "📜 udev ルールを設定中..."
UDEV_RULE_FILE="/etc/udev/rules.d/99-usbrh.rules"
RULE='SUBSYSTEM=="usb", ATTR{idVendor}=="1774", ATTR{idProduct}=="1001", MODE="0666"'
echo "$RULE" | sudo tee $UDEV_RULE_FILE > /dev/null

echo "🔁 udev をリロード・反映中..."
sudo udevadm control --reload
sudo udevadm trigger

echo "🔌 USB デバイスを一度抜いて再接続してください！"
echo "✅ セットアップ完了後、以下のコマンドで確認できます："
echo ""
echo "    cd usbrh-linux"
echo "    ./usbrh"
echo ""

# 自動的に実行して確認
read -p "デバイスを接続済みなら Enter を押してください（./usbrh を実行）..."

./usbrh || echo "⚠️ 実行失敗（udevがまだ反映されていない可能性）"

