#!/bin/bash
set -e

# === 環境設定 ===
WINEPREFIX="$HOME/.wine-mt5"
MT5_URL="https://download.mql5.com/cdn/web/metaquotes.software.corp/mt5/mt5setup.exe"
MT5_INSTALLER="$HOME/Downloads/mt5setup.exe"

# === Ubuntu バージョンを取得 ===
UBUNTU_CODENAME=$(lsb_release -cs)
SUPPORTED_CODENAMES=("bionic" "focal" "jammy" "kinetic" "lunar" "mantic")

if [[ ! " ${SUPPORTED_CODENAMES[*]} " =~ " ${UBUNTU_CODENAME} " ]]; then
    echo "❌ 未対応の Ubuntu バージョンです: ${UBUNTU_CODENAME}"
    exit 1
fi

echo "🔹 Ubuntu: $UBUNTU_CODENAME に対応した WineHQ を追加します..."

# === WineHQ リポジトリ設定 ===
sudo dpkg --add-architecture i386
sudo mkdir -pm755 /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
sudo wget -NP /etc/apt/sources.list.d/ \
  "https://dl.winehq.org/wine-builds/ubuntu/dists/${UBUNTU_CODENAME}/winehq-${UBUNTU_CODENAME}.sources"

# === パッケージインストール ===
sudo apt update
sudo apt install -y --install-recommends winehq-stable
sudo apt install -y wine64 wine32 winetricks wget cabextract \
  fonts-ipafont fonts-noto-cjk fonts-takao-gothic

# === 古い wineserver を停止 ===
wineserver -k || true

# === 既存 Wine 環境の削除確認 ===
if [ -d "$WINEPREFIX" ]; then
    echo "⚠️ 既に Wine 環境が存在します: $WINEPREFIX"
    read -p "❓ 削除して再作成しますか？ (y/N): " yn
    if [[ "$yn" =~ ^[Yy]$ ]]; then
        rm -rf "$WINEPREFIX"
        echo "✅ 削除しました。"
    else
        echo "❌ セットアップを中止します。"
        exit 1
    fi
fi

# === Wine 環境初期化（64bit）===
export WINEARCH=win64
export WINEPREFIX
echo "🔹 Wine 環境を初期化中..."
wineboot -i

# === 必要なランタイムとフォント ===
echo "🔹 winetricks でランタイムとフォントをインストール中..."
winetricks -q corefonts cjkfonts allfonts vcrun6 vcrun2010 gdiplus

# （任意）古い方法：fakejapanese
# winetricks fakejapanese

# === MT5 インストーラーの取得と実行 ===
echo "🔹 MT5 インストーラーをダウンロード..."
mkdir -p "$(dirname "$MT5_INSTALLER")"
wget -O "$MT5_INSTALLER" "$MT5_URL"

echo "🔹 インストーラーを起動します..."
wine "$MT5_INSTALLER"

# === 完了案内 ===
echo "✅ MT5 Wine 環境セットアップ完了！"
echo "📌 起動コマンド:"
echo "export WINEPREFIX=$WINEPREFIX"
echo 'wine "$WINEPREFIX/drive_c/Program Files/MetaTrader 5/terminal64.exe"'
