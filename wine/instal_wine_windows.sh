#!/bin/bash
set -e

# === Wine 環境を作成するバージョン ===
VERSIONS=("win7" "win8" "win10")
WINEARCH=win64
COMMON_TRICKS="corefonts cjkfonts meiryo vcrun6 vcrun2010 vcrun2015 gdiplus dotnet40 msxml6 atmlib"

# === Ubuntu バージョンチェックと WineHQ レポジトリ ===
UBUNTU_CODENAME=$(lsb_release -cs)
WINEHQ_SOURCE_URL="https://dl.winehq.org/wine-builds/ubuntu/dists/${UBUNTU_CODENAME}/winehq-${UBUNTU_CODENAME}.sources"

echo "🔍 Ubuntu バージョン: $UBUNTU_CODENAME"
if ! wget --spider -q "$WINEHQ_SOURCE_URL"; then
    echo "❌ WineHQ はこのバージョンの Ubuntu に未対応です: ${UBUNTU_CODENAME}"
    exit 1
fi

# === 必要なパッケージのインストール ===
sudo dpkg --add-architecture i386
sudo mkdir -pm755 /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
sudo wget -NP /etc/apt/sources.list.d/ "$WINEHQ_SOURCE_URL"

sudo apt update
sudo apt install -y --install-recommends winehq-stable
sudo apt install -y wine64 wine32 winetricks wget cabextract \
    fonts-ipafont fonts-noto-cjk fonts-takao-gothic

# === Wine バージョン表示 ===
echo "🔹 Wine バージョン: $(wine --version)"

# === Wine 環境の一括作成 ===
for VER in "${VERSIONS[@]}"; do
    PREFIX="$HOME/.wine-$VER"
    echo "🛠️ 環境作成: $PREFIX（Windows: $VER）"

    # 既存削除確認
    if [ -d "$PREFIX" ]; then
        read -p "⚠️ $PREFIX は既に存在します。削除して再作成しますか？ (y/N): " yn
        if [[ "$yn" =~ ^[Yy]$ ]]; then
            rm -rf "$PREFIX"
            echo "✅ 削除しました。"
        else
            echo "⏭️ スキップします。"
            continue
        fi
    fi

    export WINEPREFIX="$PREFIX"
    export WINEARCH

    echo "🔹 初期化: $WINEPREFIX"
    wineboot -i

    echo "🔹 Windows バージョンを設定: $VER"
    winetricks -q settings "$VER"

    echo "🔹 ランタイムをインストール..."
    winetricks -q $COMMON_TRICKS

    # エイリアスの追加
    CMD_NAME="wine-$VER"
    if ! grep -q "alias $CMD_NAME=" "$HOME/.bashrc"; then
        echo "alias $CMD_NAME='WINEPREFIX=$PREFIX winecfg'" >> "$HOME/.bashrc"
        echo "✅ エイリアス '$CMD_NAME' を追加しました。"
    else
        echo "✅ エイリアス '$CMD_NAME' は既に存在します。"
    fi
done

# === 反映メッセージ ===
echo "✅ Wine 環境の一括作成が完了しました！"
echo "📌 実行例:"
for VER in "${VERSIONS[@]}"; do
    echo "  wine-$VER  ← $HOME/.wine-$VER を winecfg で起動"
done
echo "🚀 新しいターミナルを開くか 'source ~/.bashrc' を実行してください。"
