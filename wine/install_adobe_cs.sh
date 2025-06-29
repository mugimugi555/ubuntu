#!/bin/bash
set -e

echo "🔹 Adobe CS インストールセットアップ開始"

# === カレントディレクトリをスキャン ===
echo "🔎 カレントディレクトリ内を検索中..."
CS_DIRS=()
while IFS= read -r -d '' dir; do
  CS_DIRS+=("$dir")
done < <(find . -maxdepth 1 -type d -name "Adobe CS*" -print0 | sort -z)

NUM_DIRS=${#CS_DIRS[@]}

if [ "$NUM_DIRS" -eq 0 ]; then
  echo "❌ カレントディレクトリに 'Adobe CS*' フォルダが見つかりません。"
  echo "📌 例: 'Adobe CS5' というフォルダを置いてください。"
  exit 1
elif [ "$NUM_DIRS" -eq 1 ]; then
  SELECTED_DIR="${CS_DIRS[0]}"
  echo "✅ フォルダを自動選択: $SELECTED_DIR"
else
  echo "🔹 複数の Adobe CS フォルダが見つかりました。番号を選んでください:"
  for i in "${!CS_DIRS[@]}"; do
    echo "  $((i+1)): ${CS_DIRS[$i]}"
  done
  read -p "番号を入力 [1-$NUM_DIRS]: " SELECTION
  if ! [[ "$SELECTION" =~ ^[1-9][0-9]*$ ]] || [ "$SELECTION" -lt 1 ] || [ "$SELECTION" -gt "$NUM_DIRS" ]; then
    echo "❌ 無効な選択です。終了します。"
    exit 1
  fi
  SELECTED_DIR="${CS_DIRS[$((SELECTION-1))]}"
  echo "✅ 選択したフォルダ: $SELECTED_DIR"
fi

# === バージョン抽出 ===
CS_VERSION=$(basename "$SELECTED_DIR" | grep -o 'CS[0-9]\+')
if [ -z "$CS_VERSION" ]; then
  echo "❌ フォルダ名からバージョンが認識できません。"
  exit 1
fi

INSTALLER_PATH="$SELECTED_DIR/Set-up.exe"
WINEPREFIX="$HOME/.wine-$CS_VERSION"

# === インストーラーの存在確認 ===
if [ ! -f "$INSTALLER_PATH" ]; then
  echo "❌ インストーラーが見つかりません: $INSTALLER_PATH"
  echo "📌 '$SELECTED_DIR' に Set-up.exe を配置してください。"
  exit 1
fi

echo "✅ バージョン: $CS_VERSION"
echo "✅ インストーラーパス: $INSTALLER_PATH"

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

# === 起動案内 ===
echo ""
echo "✅ Adobe $CS_VERSION の Wine セットアップが完了しました！"
echo "📂 Wine 環境: $WINEPREFIX"
echo ""
echo "📌 次のコマンドで Photoshop を起動できます:"
echo ""
echo "export WINEPREFIX=\"$WINEPREFIX\""
echo "wine \"\$WINEPREFIX/drive_c/Program Files/Adobe/Adobe Photoshop $CS_VERSION (64 Bit)/Photoshop.exe\""
echo ""
echo "📝 または、以下のエイリアスで簡単に起動できます:"

# === エイリアス追加 ===
ALIAS_NAME="photoshop$CS_VERSION"
CMD_PATH="$WINEPREFIX/drive_c/Program Files/Adobe/Adobe Photoshop $CS_VERSION (64 Bit)/Photoshop.exe"
if ! grep -q "alias $ALIAS_NAME=" "$HOME/.bashrc"; then
  echo "alias $ALIAS_NAME='export WINEPREFIX=$WINEPREFIX && wine \"$CMD_PATH\"'" >> "$HOME/.bashrc"
  echo "✅ .bashrc にエイリアス '$ALIAS_NAME' を追加しました。"
  echo "➡️ ターミナルで '$ALIAS_NAME' と打てば Photoshop を起動できます。"
else
  echo "ℹ️ エイリアス '$ALIAS_NAME' はすでに存在しています。"
fi
