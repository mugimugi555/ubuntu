#!/bin/bash

# 引数がない場合はデフォルトの GitHub ユーザーを設定
USER=${1:-mugimugi555}

# 一時ファイルの作成
TMP_FILE=$(mktemp)

# GitHub のリポジトリ一覧ページを取得
echo "Fetching repository list for $USER..."
curl -s "https://github.com/$USER?tab=repositories" > "$TMP_FILE"

# リポジトリ名を抽出
REPOS=($(grep -oP '(?<=<a href="/'$USER'/)[^"]+(?=" itemprop="name codeRepository")' "$TMP_FILE"))

# 一時ファイルを削除
rm -f "$TMP_FILE"

# 総リポジトリ数を取得
TOTAL_REPOS=${#REPOS[@]}

# 取得したリポジトリを1つずつ ZIP でダウンロードして解凍
for i in "${!REPOS[@]}"; do
    repo="${REPOS[$i]}"
    echo "[$((i+1))/$TOTAL_REPOS] Downloading $repo..."

    # ZIPのURLを構築
    ZIP_URL="https://github.com/$USER/$repo/archive/refs/heads/main.zip"

    # ZIP をダウンロード（プログレスバー付き）
    wget --progress=bar:force -O "$repo.zip" "$ZIP_URL"

    # ZIP を解凍
    echo "Unzipping $repo.zip..."
    if unzip -q "$repo.zip"; then
        echo "Successfully extracted $repo"

        # `-main` がついたフォルダをリネーム
        if [ -d "$repo-main" ]; then
            mv "$repo-main" "$repo"
            echo "Renamed folder: $repo-main → $repo"
        fi
    else
        echo "Error extracting $repo.zip"
    fi

    # ZIP ファイルを削除
    rm "$repo.zip"
done

echo "All repositories downloaded, extracted, and renamed."
