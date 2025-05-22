#!/bin/bash
set -e

echo "🛠 Wine 仮想環境の作成スクリプト (64bit 固定)"

# === WineHQ のインストール確認 & 自動導入 ===
if ! command -v wine &>/dev/null || ! command -v winetricks &>/dev/null; then
    echo "🔍 Wine または Winetricks が見つかりません。自動でインストールを行います..."

    UBUNTU_CODENAME=$(lsb_release -cs)
    WINEHQ_SOURCE_URL="https://dl.winehq.org/wine-builds/ubuntu/dists/${UBUNTU_CODENAME}/winehq-${UBUNTU_CODENAME}.sources"

    if ! wget --spider -q "$WINEHQ_SOURCE_URL"; then
        echo "❌ この Ubuntu バージョン ($UBUNTU_CODENAME) は WineHQ に対応していません。"
        exit 1
    fi

    sudo dpkg --add-architecture i386
    sudo mkdir -pm755 /etc/apt/keyrings
    sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
    sudo wget -NP /etc/apt/sources.list.d/ "$WINEHQ_SOURCE_URL"

    sudo apt update
    sudo apt install -y --install-recommends winehq-stable
    sudo apt install -y wine64 wine32 winetricks wget cabextract \
        fonts-ipafont fonts-noto-cjk fonts-takao-gothic unzip lsb-release
    echo "✅ WineHQ と関連パッケージをインストールしました。"
fi

# === プロジェクト名の入力 ===
read -p "📦 プロジェクト名を入力してください（例: photoshop, kindle）: " APP_NAME
if [ -z "$APP_NAME" ]; then
    echo "❌ プロジェクト名は必須です。"
    exit 1
fi

# === Windows バージョンの選択 ===
echo "💻 Windows バージョンを選択してください:"
select WINVER in "win7" "win8" "win10" "win11"; do
    case $WINVER in
        win7|win8|win10|win11) break;;
        *) echo "❌ 無効な選択です。もう一度選んでください。";;
    esac
done

# === 環境設定 ===
WINEPREFIX="$HOME/.wine-$APP_NAME"
WINEARCH="win64"
export WINEPREFIX
export WINEARCH

# === 既存環境の確認と削除 ===
if [ -d "$WINEPREFIX" ]; then
    echo "⚠️ $WINEPREFIX はすでに存在します。"
    read -p "❓ 削除して再作成しますか？ (y/N): " yn
    if [[ "$yn" =~ ^[Yy]$ ]]; then
        rm -rf "$WINEPREFIX"
        echo "✅ 削除完了。"
    else
        echo "❌ セットアップを中止しました。"
        exit 1
    fi
fi

# === 初期化 ===
echo "🔧 Wine 環境を初期化中（64bit）..."
wineboot -i

# === Windows バージョン設定 ===
echo "🔧 Windows バージョンを $WINVER に設定中..."
winetricks -q settings $WINVER

# === 必要ランタイム・フォントのインストール ===
echo "📦 ランタイムとフォントをインストール中..."
winetricks -q \
    corefonts cjkfonts meiryo \
    vcrun6 vcrun2010 vcrun2015 \
    gdiplus dotnet40 msxml6 atmlib

# === エイリアス追加 ===
ALIAS_NAME="$APP_NAME"
LAUNCH_CMD="export WINEPREFIX=$WINEPREFIX && winecfg"

if ! grep -q "alias $ALIAS_NAME=" "$HOME/.bashrc"; then
    echo "alias $ALIAS_NAME='$LAUNCH_CMD'" >> "$HOME/.bashrc"
    echo "✅ .bashrc にエイリアス '$ALIAS_NAME' を追加しました。"
else
    echo "✅ すでにエイリアス '$ALIAS_NAME' は .bashrc に存在します。"
fi

# === 完了メッセージ ===
echo
echo "✅ 仮想環境 '$APP_NAME' の作成が完了しました！"
echo "📁 WINEPREFIX: $WINEPREFIX"
echo "🧪 Windows: $WINVER / 64bit"
echo
echo "📌 起動方法:"
echo "source ~/.bashrc"
echo "$ALIAS_NAME"
