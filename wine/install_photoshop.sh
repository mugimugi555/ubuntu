#!/bin/bash

# CS4/CS5/CS6 すべてに対応するインストールスクリプト

# インストール用の環境変数
CS_VERSION="CS5"  # CS4, CS5, CS6 を選択
INSTALLER_PATH="$HOME/Downloads/Adobe $CS_VERSION/Set-up.exe"
WINEPREFIX="$HOME/.wine-$CS_VERSION"

# インストールファイルの存在チェック
if [ ! -f "$INSTALLER_PATH" ]; then
    echo "❌ Adobe $CS_VERSION のインストーラー ($INSTALLER_PATH) が見つかりません。"
    echo "📌 手動でダウンロードし、$HOME/Downloads に保存してください。"
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

# === WineHQ リポジトリ設定 ===
sudo dpkg --add-architecture i386
sudo mkdir -pm755 /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
sudo wget -NP /etc/apt/sources.list.d/ \
  "https://dl.winehq.org/wine-builds/ubuntu/dists/${UBUNTU_CODENAME}/winehq-${UBUNTU_CODENAME}.sources"

# === パッケージのインストール ===
sudo apt update
sudo apt install -y --install-recommends winehq-stable
sudo apt install -y wine64 wine32 winetricks wget cabextract \
  fonts-ipafont fonts-noto-cjk fonts-takao-gothic

# === 古い wineserver の停止 ===
wineserver -k || true

# === 既存環境の削除確認 ===
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

# === 必要なランタイムとフォント ===
echo "🔹 ランタイムとフォントをインストール中..."
winetricks -q corefonts cjkfonts allfonts vcrun6 vcrun2010 gdiplus

# 必要なランタイムをインストール
echo "📌 Adobe $CS_VERSION に必要なランタイムをインストール..."
printf 'Y\n' | sudo WINEPREFIX=$WINEPREFIX winetricks --self-update
WINEPREFIX=$WINEPREFIX winetricks cjkfonts corefonts fakejapanese meiryo
WINEDEBUG=-all WINEPREFIX=$WINEPREFIX winetricks -q vcrun2005 vcrun2008 vcrun2010 atmlib gdiplus msxml6

# Adobe のインストール
echo "📌 Adobe $CS_VERSION のインストーラーを起動します..."
WINEPREFIX=$WINEPREFIX wine "$INSTALLER_PATH"

echo "✅ Adobe $CS_VERSION のセットアップが完了しました！"
