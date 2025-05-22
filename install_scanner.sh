#!/bin/bash

# Canon PIXMA MP610 スキャナセットアップスクリプト
# 対応環境：Ubuntu 22.04 / 24.04

set -e

echo "🔧 パッケージ更新と SANE 関連パッケージのインストール..."
sudo apt update
sudo apt install -y sane-utils libsane-common simple-scan

echo "🔍 接続済みスキャナの検出..."
SCAN_ID=$(scanimage -L 2>/dev/null | sed -n "s/^device \`\(pixma:[^']*\)'.*/\1/p")

if [ -z "$SCAN_ID" ]; then
  echo "❌ スキャナが見つかりませんでした。USB接続・電源を確認してください。"
  exit 1
fi

echo "✅ 検出されたスキャナID: $SCAN_ID"

echo "🧪 テストスキャンを実行中（ホームディレクトリに scan_test.png を保存）..."
scanimage -d "$SCAN_ID" --format=png --output-file="$HOME/scan_test.png" 2>/dev/null

echo "✅ スキャン成功: $HOME/scan_test.png に保存されました"

echo "⚙️ scan エイリアスを ~/.bashrc に追加..."

# SCAN_ID を直接埋め込んだ短いエイリアスに修正
ALIAS_CMD="alias scan='TS=\$(date +%Y%m%d_%H%M%S); FNAME=\$HOME/scan_\$TS.png; scanimage -d \"$SCAN_ID\" --format=png --output-file=\"\$FNAME\" 2>/dev/null && echo \"✅ スキャン完了: \$FNAME\" && (xdg-open \"\$FNAME\" >/dev/null 2>&1 &)'"

# エイリアスが未登録なら追加
if ! grep -Fq "$ALIAS_CMD" "$HOME/.bashrc"; then
  echo "$ALIAS_CMD" >> "$HOME/.bashrc"
  echo "✅ エイリアスを追加しました。次回のシェルから 'scan' コマンドでスキャン可能です。"
else
  echo "ℹ️ 既にエイリアスが登録されています。"
fi

echo ""
echo "🚀 セットアップ完了！以下を実行してすぐ使えます："
echo "  source ~/.bashrc"
echo "  scan"