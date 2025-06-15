#!/bin/bash

#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 複数テーマ対応 GRUB テーマインストーラ
#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e

ARCHIVE_URL="https://github.com/13atm01/GRUB-Theme/releases/download/v1.1/TQQ_Christmas.tar.gz"
ARCHIVE_NAME="TQQ_Christmas.tar.gz"
TMP_DIR="/tmp/grub-theme"
GRUB_THEME_DIR="/boot/grub/themes"
GRUB_CONFIG="/etc/default/grub"

# 必要パッケージ
sudo apt update
sudo apt install -y wget tar

# 作業準備
rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"
cd "$TMP_DIR"

# アーカイブのダウンロード
echo "▶ テーマをダウンロード中..."
wget -O "$ARCHIVE_NAME" "$ARCHIVE_URL"

# 解凍
echo "▶ テーマを展開中..."
tar -xzf "$ARCHIVE_NAME"

# theme.txt を含むディレクトリを検索
echo "▶ テーマ候補を検索中..."
mapfile -t THEME_PATHS < <(find . -type f -name theme.txt -exec dirname {} \;)

if [ "${#THEME_PATHS[@]}" -eq 0 ]; then
  echo "❌ theme.txt を含むディレクトリが見つかりません。"
  exit 1
fi

# 一覧表示
echo "🖼️ インストール可能なテーマ一覧："
for i in "${!THEME_PATHS[@]}"; do
  echo "  [$i] ${THEME_PATHS[$i]}"
done

# 選択
read -p "▶ インストールするテーマの番号を選んでください: " SELECTED
THEME_SRC="${THEME_PATHS[$SELECTED]}"

if [ -z "$THEME_SRC" ]; then
  echo "❌ 無効な選択です。"
  exit 1
fi

# コピー
THEME_NAME=$(basename "$THEME_SRC")
THEME_DEST="$GRUB_THEME_DIR/$THEME_NAME"

echo "▶ テーマを $THEME_DEST にコピー中..."
sudo mkdir -p "$THEME_DEST"
sudo cp -r "$THEME_SRC/"* "$THEME_DEST"

# GRUB設定
echo "▶ GRUB にテーマを設定中..."
if grep -q "^GRUB_THEME=" "$GRUB_CONFIG"; then
  sudo sed -i "s|^GRUB_THEME=.*|GRUB_THEME=\"$THEME_DEST/theme.txt\"|" "$GRUB_CONFIG"
else
  echo "GRUB_THEME=\"$THEME_DEST/theme.txt\"" | sudo tee -a "$GRUB_CONFIG"
fi

# GRUB更新
echo "▶ GRUB を更新中..."
sudo update-grub

echo "✅ 完了！再起動でテーマ '$THEME_NAME' が適用されます。"
