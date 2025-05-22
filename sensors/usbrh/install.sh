#!/bin/bash

# USBRH センサーのセットアップスクリプト（ローカルファイル使用）

set -e

echo "📦 必要なパッケージをインストール中..."
sudo apt update
sudo apt install -y libusb-dev build-essential

echo "🔨 ビルド実行中..."
cd "$(dirname "$0")"
make

echo "📜 udev ルールを設定中..."
UDEV_RULE_FILE="/etc/udev/rules.d/99-usbrh.rules"
RULE='SUBSYSTEM=="usb", ATTR{idVendor}=="1774", ATTR{idProduct}=="1001", MODE="0666"'
echo "$RULE" | sudo tee "$UDEV_RULE_FILE" > /dev/null

echo "🔁 udev をリロード・反映中..."
sudo udevadm control --reload
sudo udevadm trigger

echo "🔌 USB デバイスを一度抜いて再接続してください！"
echo "✅ セットアップ完了後、以下のコマンドで確認できます："
echo ""
echo "    ./usbrh"
echo ""

read -p "デバイスを接続済みなら Enter を押してください（./usbrh を実行）..."

./usbrh || echo "⚠️ 実行失敗（udevがまだ反映されていない可能性）"
