#!/bin/bash

# 引数がない場合はデフォルトの GitHub ユーザーを設定
USER=${1:-mugimugi555}

# 一時ファイルの作成
TMP_FILE=$(mktemp)

# GitHub のリポジトリ一覧ページを取得
echo "Fetching repository list for $USER..."
curl -s "https://github.com/$USER?tab=repositories" > "$TMP_FILE"

# リポジトリ名を抽出
REPOS=$(grep -oP '(?<=<a href="/'$USER'/)[^"]+(?=" itemprop="name codeRepository")' "$TMP_FILE")

# 一時ファイルを削除
rm -f "$TMP_FILE"

# 取得したリポジトリを1つずつクローン（HTTPS 版）
for repo in $REPOS; do
    echo "Cloning https://github.com/$USER/$repo.git..."
    git clone "https://github.com/$USER/$repo.git"
done
