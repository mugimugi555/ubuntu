#!/bin/bash
set -e

echo "🔹 必要なパッケージをインストールします..."
sudo apt update
sudo apt install -y git grub2-common

# === 作業用ディレクトリを作成 ===
WORKDIR=$(mktemp -d)
cd "$WORKDIR"

echo "📥 GRUBテーマ(vimix) をGitHubからダウンロードします..."
git clone https://github.com/vinceliuice/grub2-themes.git

cd grub2-themes

# === インストール先ディレクトリの確認と作成 ===
GRUB_THEME_DIR="/boot/grub/themes/vimix"

if [ -d "$GRUB_THEME_DIR" ]; then
    echo "⚠️ すでに vimix テーマディレクトリが存在します。上書きします..."
    sudo rm -rf "$GRUB_THEME_DIR"
fi

echo "📂 テーマを $GRUB_THEME_DIR にコピーします..."
sudo mkdir -p "$GRUB_THEME_DIR"
sudo cp -r vimix/* "$GRUB_THEME_DIR"

# === grub 設定ファイルにテーマ指定を追加 ===
GRUB_CONFIG="/etc/default/grub"
THEME_LINE="GRUB_THEME=$GRUB_THEME_DIR/theme.txt"

echo "🔧 GRUB設定にテーマ指定を追加/修正します..."
if grep -q "^GRUB_THEME=" "$GRUB_CONFIG"; then
    sudo sed -i "s|^GRUB_THEME=.*|$THEME_LINE|" "$GRUB_CONFIG"
else
    echo "$THEME_LINE" | sudo tee -a "$GRUB_CONFIG"
fi

# === grubを更新 ===
echo "🔄 grub を更新します..."
sudo update-grub

# === 完了メッセージ ===
echo ""
echo "✅ GRUBテーマ (vimix) のインストールが完了しました！"
echo "🚀 次回起動時から、豪華なGRUBメニューが表示されます！"

# === 後片付け ===
echo "🧹 作業ディレクトリを削除します..."
rm -rf "$WORKDIR"
