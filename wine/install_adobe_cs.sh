#!/bin/bash
set -e

# === Adobe CS バージョン選択 ===
echo "🔹 インストールする Adobe Creative Suite のバージョンを選択してください:"
echo "  1: CS4"
echo "  2: CS5"
echo "  3: CS6"
read -p "番号を入力 [1-3]（デフォルト: 2）: " VERSION

case "$VERSION" in
    1) CS_VERSION="CS4" ;;
    3) CS_VERSION="CS6" ;;
    *) CS_VERSION="CS5" ;;
esac

INSTALLER_PATH="$HOME/Downloads/Adobe $CS_VERSION/Set-up.exe"
WINEPREFIX="$HOME/.wine-$CS_VERSION"

# === インストーラーの存在確認 ===
if [ ! -f "$INSTALLER_PATH" ]; then
    echo "❌ Adobe $CS_VERSION のインストーラーが見つかりません: $INSTALLER_PATH"
    echo "📌 手動でダウンロードし、上記の場所に保存してください。"
    exit 1
fi

# === Ubuntu バージョンチェック + WineHQ ソース確認 ===
UBUNTU_CODENAME=$(lsb_release -cs)
WINEHQ_SOURCE_URL="https://dl.winehq.org/wine-builds/ubuntu/dists/${UBUNTU_CODENAME}/winehq-${UBUNTU_CODENAME}.sources"

echo "🔎 WineHQ リポジトリの確認中: $WINEHQ_SOURCE_URL ..."
if ! wget --spider -q "$WINEHQ_SOURCE_URL"; then
    echo "❌ WineHQ は Ubuntu $UBUNTU_CODENAME をまだサポートしていません。"
    echo "🔗 https://dl.winehq.org/wine-builds/ubuntu/dists/ を確認してください。"
    exit 1
fi
echo "✅ WineHQ はこの Ubuntu に対応しています。"

# === WineHQ リポジトリと鍵の追加 ===
sudo dpkg --add-architecture i386
sudo mkdir -pm755 /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
sudo wget -NP /etc/apt/sources.list.d/ "$WINEHQ_SOURCE_URL"

# === Wineと必要なフォント・ライブラリをインストール ===
sudo apt update
sudo apt install -y --install-recommends winehq-stable
sudo apt install -y wine64 wine32 winetricks wget cabextract \
  fonts-ipafont fonts-noto-cjk fonts-takao-gothic

# === 古い Wine セッション終了 ===
wineserver -k || true

# === WINEPREFIX の初期化・削除確認 ===
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

# === Wine 環境の初期化 ===
export WINEARCH=win64
export WINEPREFIX
echo "🔹 Wine 環境を初期化中..."
wineboot -i

# === ランタイムとフォントのインストール ===
echo "🔹 ランタイムとフォントをインストール中..."
winetricks --self-update -q
winetricks -q cjkfonts corefonts fakejapanese meiryo
winetricks -q vcrun2005 vcrun2008 vcrun2010 atmlib gdiplus msxml6

# === Adobe セットアップ起動 ===
echo "🔹 Adobe $CS_VERSION のインストーラーを起動します..."
wine "$INSTALLER_PATH"

# === 完了 ===
echo "✅ Adobe $CS_VERSION の Wine セットアップが完了しました！"
echo "📂 Wine 環境: $WINEPREFIX"
