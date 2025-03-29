#!/bin/bash
set -e

# === 設定 ===
CS_VERSION="CS5"
INSTALLER_PATH="$HOME/Downloads/Adobe $CS_VERSION/Set-up.exe"
WINEPREFIX="$HOME/.wine-$CS_VERSION"

# === インストーラの存在確認 ===
if [ ! -f "$INSTALLER_PATH" ]; then
    echo "❌ Adobe $CS_VERSION のインストーラーが見つかりません: $INSTALLER_PATH"
    echo "📌 手動でダウンロードし、正しい場所に保存してください。"
    exit 1
fi

# === Ubuntu バージョン確認 ===
UBUNTU_CODENAME=$(lsb_release -cs)
SUPPORTED_CODENAMES=("bionic" "focal" "jammy" "kinetic" "lunar" "mantic")

if [[ ! " ${SUPPORTED_CODENAMES[*]} " =~ " ${UBUNTU_CODENAME} " ]]; then
    echo "❌ 未対応の Ubuntu バージョンです: ${UBUNTU_CODENAME}"
    exit 1
fi

echo "🔹 Ubuntu $UBUNTU_CODENAME に対応した WineHQ をセットアップします..."

# === WineHQ リポジトリと鍵の追加 ===
sudo dpkg --add-architecture i386
sudo mkdir -pm755 /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
sudo wget -NP /etc/apt/sources.list.d/ \
  "https://dl.winehq.org/wine-builds/ubuntu/dists/${UBUNTU_CODENAME}/winehq-${UBUNTU_CODENAME}.sources"

# === Wine + フォント・ランタイムのインストール ===
sudo apt update
sudo apt install -y --install-recommends winehq-stable
sudo apt install -y wine64 wine32 winetricks wget cabextract \
  fonts-ipafont fonts-noto-cjk fonts-takao-gothic

# === 古い Wine セッションを終了 ===
wineserver -k || true

# === 既存プレフィックスの確認と削除 ===
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

# === Wine 環境初期化 ===
export WINEARCH=win64
export WINEPREFIX
echo "🔹 Wine 環境を初期化中..."
wineboot -i

# === Winetricks による必要ランタイム & フォントのインストール ===
echo "🔹 ランタイムとフォントをインストール中..."
winetricks --self-update -q
winetricks -q cjkfonts corefonts fakejapanese meiryo
winetricks -q vcrun2005 vcrun2008 vcrun2010 atmlib gdiplus msxml6

# === Adobe セットアップ起動 ===
echo "🔹 Adobe $CS_VERSION のインストーラーを起動します..."
wine "$INSTALLER_PATH"

# === 完了メッセージ ===
echo "✅ Adobe $CS_VERSION の Wine セットアップが完了しました！"
echo "📂 インストール先: $WINEPREFIX"
