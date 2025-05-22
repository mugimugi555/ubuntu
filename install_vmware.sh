#!/usr/bin/env bash

# VMware Workstation Player 17.0.2 のインストールスクリプト 🧰
# GitHub: https://github.com/mugimugi555/ubuntu

set -e  # エラーがあれば即中断

echo "🔧 必要な開発ツールをインストール中..."
sudo apt update
sudo apt install -y gcc build-essential unzip

echo "🌐 VMware Workstation Player の公式ダウンロードページを開きます。"
xdg-open "https://customerconnect.vmware.com/en/downloads/details?downloadGroup=WKST-PLAYER-1702&productId=1377&rPId=104734"

echo "⏳ インストーラーのダウンロードが完了したら、次のファイルを実行してください:"
echo "   sudo sh VMware-Player-Full-17.0.2-21581411.x86_64.bundle"
read -p "🔽 Enterキーで続行（インストーラーをダウンロードしてから）..." _

echo "🛠️ VMware Host Modules の取得とビルド..."
cd "$HOME"
wget https://github.com/mkubecek/vmware-host-modules/archive/workstation-17.0.2.tar.gz
tar -xzf workstation-17.0.2.tar.gz
cd vmware-host-modules-workstation-17.0.2

echo "📦 カーネルモジュールを作成..."
tar -cf vmmon.tar vmmon-only
tar -cf vmnet.tar vmnet-only
sudo cp -v vmmon.tar vmnet.tar /usr/lib/vmware/modules/source/

echo "🔁 モジュールのビルドとインストールを開始..."
sudo vmware-modconfig --console --install-all

echo "🚀 VMware Player を起動します..."
vmplayer &

echo "✅ インストール完了！"
