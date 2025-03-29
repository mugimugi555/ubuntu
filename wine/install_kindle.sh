#!/bin/bash
set -e

# === 基本設定 ===
APP_NAME="Kindle"
WINEPREFIX="$HOME/.wine-$APP_NAME"
INSTALLER_URL="https://www.amazon.co.jp/kindle-dbs/fd/kcp/download/KCPInstaller.exe"
INSTALLER_FILE="$HOME/Downloads/KCPInstaller.exe"

# === Ubuntu バージョン確認 ===
UBUNTU_CODENAME=$(lsb_release -cs)
SUPPORTED_CODENAMES=("bionic" "focal" "jammy" "kinetic" "lunar" "mantic")

if [[ ! " ${SUPPORTED_CODENAMES[*]} " =~ " ${UBUNTU_CODENAME} " ]]; then
    echo "❌ 未対応の Ubuntu バージョンです: ${UBUNTU_CODENAME}"
    exit 1
fi

echo "🔹 Ubuntu $UBUNTU_CODENAME に対応した WineHQ をセットアップします..."

# === WineHQ リポジトリ追加 ===
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

# === Wine 環境初期化 ===
export WINEARCH=win64
export WINEPREFIX
echo "🔹 Wine 環境を初期化中..."
wineboot -i

# === ランタイム & フォント ===
echo "🔹 必要なランタイムとフォントをインストール中..."
winetricks -q corefonts vcrun6 vcrun2010

# === Kindle インストーラーの取得と実行 ===
echo "🔹 Kindle インストーラーをダウンロード..."
wget -O "$INSTALLER_FILE" "$INSTALLER_URL"

echo "🔹 インストーラーを起動します..."
wine "$INSTALLER_FILE"

# === .bashrc にエイリアスを追加 ===
CMD_NAME="kindle"
TARGET_PATH="$WINEPREFIX/drive_c/Program Files (x86)/Amazon/Kindle/Kindle.exe"

if ! grep -q "alias $CMD_NAME=" "$HOME/.bashrc"; then
    echo "alias $CMD_NAME='export WINEPREFIX=$WINEPREFIX && wine \"$TARGET_PATH\"'" >> "$HOME/.bashrc"
    echo "✅ .bashrc にエイリアス '$CMD_NAME' を追加しました。"
    echo "➡️ 次回のシェルから 'kindle' コマンドで起動できます。"
else
    echo "✅ すでにエイリアス '$CMD_NAME' は設定済みです。"
fi

echo "✅ Kindle for PC のセットアップ完了！"
echo "📌 起動方法:"
echo "export WINEPREFIX=$WINEPREFIX"
echo "wine \"$TARGET_PATH\""
echo "または 'kindle' を実行してください。"
