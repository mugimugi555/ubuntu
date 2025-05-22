#!/bin/bash
set -e

# === Ubuntu バージョンを取得 ===
UBUNTU_CODENAME=$(lsb_release -cs)
WINEHQ_SOURCE_URL="https://dl.winehq.org/wine-builds/ubuntu/dists/${UBUNTU_CODENAME}/winehq-${UBUNTU_CODENAME}.sources"

echo "🔍 Ubuntu バージョン: $UBUNTU_CODENAME"

# === WineHQ リポジトリの存在確認 ===
if ! wget --spider -q "$WINEHQ_SOURCE_URL"; then
    echo "❌ WineHQ はこの Ubuntu バージョン ($UBUNTU_CODENAME) に対応していません。"
    exit 1
fi

echo "🔹 WineHQ を追加します..."

# === WineHQ リポジトリ追加 ===
sudo dpkg --add-architecture i386
sudo mkdir -pm755 /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
sudo wget -NP /etc/apt/sources.list.d/ "$WINEHQ_SOURCE_URL"

# === パッケージ更新 & Wine 関連のインストール ===
sudo apt update
sudo apt install -y --install-recommends winehq-stable
sudo apt install -y wine64 wine32 winetricks wget cabextract \
  fonts-ipafont fonts-noto-cjk fonts-takao-gothic unzip lsb-release

# === Wine 環境チェック ===
echo
echo "✅ Wine のバージョン確認:"
wine --version || echo "⚠️ wine コマンドが見つかりません"

echo
echo "✅ Winetricks バージョン:"
winetricks --version || echo "⚠️ winetricks コマンドが見つかりません"

# === wineserver 停止 ===
echo
wineserver -k || true

echo
echo "🎉 Wine インストール完了！使い始めるには次のコマンドを試してください:"
echo "  winecfg      # Wine の設定画面を表示"
echo "  winetricks   # ランタイムや DLL を追加"
