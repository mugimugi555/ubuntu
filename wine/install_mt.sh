#!/bin/bash
set -e

# === MT バージョン選択 ===
echo "🔹 インストールするバージョンを選択してください:"
echo "  1: MetaTrader 4 (MT4)"
echo "  2: MetaTrader 5 (MT5)"
read -p "番号を入力 [1-2]（デフォルト: 2）: " VERSION

if [[ "$VERSION" == "1" ]]; then
    MT_VERSION="mt4"
    MT_URL="https://download.mql5.com/cdn/web/metaquotes.software.corp/mt4/mt4setup.exe"
else
    MT_VERSION="mt5"
    MT_URL="https://download.mql5.com/cdn/web/metaquotes.software.corp/mt5/mt5setup.exe"
fi

WINEPREFIX="$HOME/.wine-$MT_VERSION"
INSTALLER_PATH="$HOME/Downloads/${MT_VERSION}setup.exe"

# === Ubuntu バージョン確認 ===
UBUNTU_CODENAME=$(lsb_release -cs)
SUPPORTED_CODENAMES=("bionic" "focal" "jammy" "kinetic" "lunar" "mantic")
if [[ ! " ${SUPPORTED_CODENAMES[*]} " =~ " ${UBUNTU_CODENAME} " ]]; then
    echo "❌ 未対応の Ubuntu バージョンです: ${UBUNTU_CODENAME}"
    exit 1
fi

# === WineHQ リポジトリ追加 ===
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

# === 古い wineserver の停止 ===
wineserver -k || true

# === 既存環境削除の確認 ===
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

# === ランタイム・フォントのインストール ===
winetricks -q corefonts cjkfonts allfonts vcrun6 vcrun2010 gdiplus

# === MT インストーラーを取得 ===
echo "🔹 ${MT_VERSION^^} インストーラーをダウンロード中..."
mkdir -p "$(dirname "$INSTALLER_PATH")"
wget -O "$INSTALLER_PATH" "$MT_URL"

# === インストーラー起動 ===
echo "🔹 インストーラーを起動します..."
wine "$INSTALLER_PATH"

# === 起動エイリアスの追加 ===
BASENAME="${MT_VERSION^^}"
CMD_NAME="$MT_VERSION"
TARGET_PATH="$WINEPREFIX/drive_c/Program Files/MetaTrader ${BASENAME:2}/terminal64.exe"
if ! grep -q "alias $CMD_NAME=" "$HOME/.bashrc"; then
    echo "alias $CMD_NAME='export WINEPREFIX=$WINEPREFIX && wine \"$TARGET_PATH\"'" >> "$HOME/.bashrc"
    echo "✅ .bashrc にエイリアス '$CMD_NAME' を追加しました。"
fi

echo "✅ MetaTrader $BASENAME の Wine 環境セットアップ完了！"
echo "📌 起動方法:"
echo "export WINEPREFIX=$WINEPREFIX"
echo "wine \"$TARGET_PATH\""
echo "または 'source ~/.bashrc' 後に '$CMD_NAME' で起動できます。"
