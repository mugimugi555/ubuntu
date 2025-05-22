#!/usr/bin/env bash

# Ubuntu アップグレードスクリプト 🚀
# 対応バージョン: Ubuntu 22.04 → 次期バージョン（例: 24.04）
# 自動アップグレード後に再起動します

set -e  # 途中でエラーが発生したらスクリプトを終了

echo "🔐 sudo 権限を確認..."
if [[ $EUID -ne 0 ]]; then
  echo "❗ このスクリプトは root 権限が必要です。sudo を付けて再実行してください。"
  exit 1
fi

echo ""
echo "🌀 ステップ 1/5: パッケージリストの更新中..."
apt update

echo "⬆️ ステップ 2/5: システムアップグレード中..."
apt upgrade -y

echo "📦 ステップ 3/5: update-manager をインストール中（GUI/CLI対応）..."
apt install -y update-manager-core

echo "🔄 ステップ 4/5: ディストリビューション全体のアップグレードを実行します..."
apt dist-upgrade -y

echo "🚀 ステップ 5/5: 次期 Ubuntu リリースへのアップグレードを確認して開始します..."
do-release-upgrade -c -d -f DistUpgradeViewNonInteractive

echo ""
echo "✅ アップグレード処理が完了しました。再起動します。"

sleep 3
reboot
