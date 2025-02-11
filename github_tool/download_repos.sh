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

# 取得したリポジトリを1つずつ ZIP でダウンロードして解凍
for repo in $REPOS; do
    echo "Downloading https://github.com/$USER/$repo/archive/refs/heads/main.zip..."
    wget -q "https://github.com/$USER/$repo/archive/refs/heads/main.zip" -O "$repo.zip"
    
    echo "Unzipping $repo.zip..."
    unzip -q "$repo.zip"
    
    echo "Removing $repo.zip..."
    rm "$repo.zip"
done
