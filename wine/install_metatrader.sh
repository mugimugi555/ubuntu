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

# === ブローカー名の入力 ===
read -p "証券会社名を英数字で入力してください（例: bigboss）: " BROKER
WINEPREFIX="$HOME/.wine-${MT_VERSION}-${BROKER}"
INSTALLER_PATH="$HOME/Downloads/${MT_VERSION}setup-${BROKER}.exe"

# === Ubuntu バージョン確認と Wine リポジトリ ===
UBUNTU_CODENAME=$(lsb_release -cs)
WINEHQ_SOURCE_URL="https://dl.winehq.org/wine-builds/ubuntu/dists/${UBUNTU_CODENAME}/winehq-${UBUNTU_CODENAME}.sources"

echo "🔎 WineHQ リポジトリの存在確認中: $WINEHQ_SOURCE_URL ..."
if ! wget --spider -q "$WINEHQ_SOURCE_URL"; then
    echo "❌ WineHQ は Ubuntu $UBUNTU_CODENAME をまだサポートしていません。"
    echo "🔗 https://dl.winehq.org/wine-builds/ubuntu/dists/ をご確認ください。"
    exit 1
fi

echo "✅ Ubuntu $UBUNTU_CODENAME に対応した Wine リポジトリを使用"
sudo dpkg --add-architecture i386
sudo mkdir -pm755 /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
sudo wget -NP /etc/apt/sources.list.d/ "$WINEHQ_SOURCE_URL"

# === Wine & 必要パッケージのインストール ===
sudo apt update
sudo apt install -y --install-recommends winehq-stable
sudo apt install -y wine64 wine32 winetricks wget cabextract \
  fonts-ipafont fonts-noto-cjk fonts-takao-gothic

# === 古い Wine セッションの停止 ===
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
wineboot -i

# === フォントと必要ランタイムのインストール ===
winetricks -q corefonts cjkfonts allfonts vcrun6 vcrun2010 gdiplus

# === インストーラーのダウンロードと起動 ===
echo "🔹 ${MT_VERSION^^} インストーラーをダウンロード中..."
wget -O "$INSTALLER_PATH" "$MT_URL"

echo "🔹 インストーラーを起動します..."
wine "$INSTALLER_PATH"

# === 起動エイリアスの追加 ===
CMD_NAME="${MT_VERSION}-${BROKER}"
TARGET_PATH="$WINEPREFIX/drive_c/Program Files/MetaTrader ${MT_VERSION^^:2}/terminal64.exe"

if ! grep -q "alias $CMD_NAME=" "$HOME/.bashrc"; then
    echo "alias $CMD_NAME='export WINEPREFIX=$WINEPREFIX && wine \"$TARGET_PATH\"'" >> "$HOME/.bashrc"
    echo "✅ .bashrc にエイリアス '$CMD_NAME' を追加しました。"
fi

echo "✅ Wine 環境 '$CMD_NAME' のセットアップが完了しました！"
echo "📌 起動方法: source ~/.bashrc の後、 $CMD_NAME で起動可能です。"
