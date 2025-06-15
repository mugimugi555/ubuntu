#!/bin/bash

#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# GRUBテーマ 自動インストールスクリプト
# Ubuntu / デュアルブート環境対応
#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# 必要なパッケージをインストール
echo "▶ 必要なパッケージをインストール中..."
sudo apt update && sudo apt install -y git

# 作業ディレクトリ作成
WORKDIR="$HOME/grub2-themes"
THEME_NAME="vimix"

# 既存のクローンがあれば削除
if [ -d "$WORKDIR" ]; then
  echo "▶ 既存のテーマディレクトリを削除: $WORKDIR"
  rm -rf "$WORKDIR"
fi

# テーマをクローン
echo "▶ GitHubからテーマを取得中..."
git clone https://github.com/vinceliuice/grub2-themes.git "$WORKDIR"

# インストール実行
cd "$WORKDIR"
echo "▶ テーマ '$THEME_NAME' をインストール..."
sudo ./install.sh -t "$THEME_NAME"

# GRUB設定にテーマパスを追加
GRUB_CONFIG="/etc/default/grub"
THEME_PATH="/boot/grub/themes/$THEME_NAME/theme.txt"

echo "▶ GRUB設定にテーマを追加: $THEME_PATH"
if grep -q "^GRUB_THEME=" "$GRUB_CONFIG"; then
  sudo sed -i "s|^GRUB_THEME=.*|GRUB_THEME=\"$THEME_PATH\"|" "$GRUB_CONFIG"
else
  echo "GRUB_THEME=\"$THEME_PATH\"" | sudo tee -a "$GRUB_CONFIG"
fi

# GRUBを更新
echo "▶ GRUBを更新中..."
sudo update-grub

# 完了メッセージ
echo "✅ GRUBテーマの設定が完了しました！再起動すると反映されます。"
