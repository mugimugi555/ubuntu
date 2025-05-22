#!/bin/bash

# 🔐 Root権限チェック（必要に応じて再実行）
if [[ $EUID -ne 0 ]]; then
  echo "🔐 Root 権限が必要です。sudo を使って再実行します..."
  exec sudo "$0" "$@"
fi

echo ""
echo "🌐 Remmina Next (開発版) のインストールを開始します..."
echo ""

# 📦 PPA 追加
echo "➕ 1/3: PPA を追加中..."
apt-add-repository -y ppa:remmina-ppa-team/remmina-next

# 🔄 パッケージ更新
echo "🔄 2/3: APT キャッシュを更新中..."
apt update -y

# 📥 Remmina本体と必要なプラグインをインストール
echo "📥 3/3: Remmina 本体と RDP プラグイン、シークレット管理プラグインをインストール中..."
apt install -y remmina remmina-plugin-rdp remmina-plugin-secret

# ✅ 完了メッセージ
echo ""
echo "🎉 Remmina Next のインストールが完了しました！"
echo "🖥️ アプリケーションメニューから 'Remmina' を起動できます。"
