#!/bin/bash

# 📊 Netdata 監視ツール自動インストールスクリプト
# URL: https://my-netdata.io/kickstart.sh

#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 🚀 インストール開始
#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "📦 Netdata をインストール中..."
bash <(curl -SsL https://my-netdata.io/kickstart.sh) || { echo "❌ Netdataのインストールに失敗しました。"; exit 1; }

#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 🌐 自ホストの名前を取得してブラウザ起動
#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HOSTNAME=$(hostname -I | awk '{print $1}')
URL="http://${HOSTNAME}:19999/"
echo "🌐 Netdata にアクセス: $URL"

# xdg-openでブラウザを開く（バックグラウンド）
xdg-open "$URL" &>/dev/null &

#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 📋 セッションIDをクリップボードへコピー
#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SESSION_ID=$(sudo cat /var/lib/netdata/netdata_random_session_id 2>/dev/null)
if [ -n "$SESSION_ID" ]; then
  echo "🆔 セッションID: $SESSION_ID"
  if command -v xclip &>/dev/null; then
    echo -n "$SESSION_ID" | xclip -selection clipboard
    echo "📋 セッションIDをクリップボードにコピーしました（xclip）"
  elif command -v xsel &>/dev/null; then
    echo -n "$SESSION_ID" | xsel --clipboard --input
    echo "📋 セッションIDをクリップボードにコピーしました（xsel）"
  else
    echo "⚠️ xclip または xsel が見つかりません。クリップボードコピーをスキップします。"
  fi
else
  echo "⚠️ セッションIDが見つかりませんでした。"
fi
