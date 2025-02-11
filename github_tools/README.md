# GitHubレポジトリ一括取得ツールの使い方

![タイトル画像](assets/images/header.png)

## 概要
このスクリプトは、指定した GitHub ユーザーのリポジトリ一覧を取得し、
すべてのリポジトリを HTTPS 経由でクローンする `clone_repos.sh` と、
リポジトリの ZIP をダウンロードして解凍する `download_repos.sh` の2つのスクリプトを提供します。

## 必要な環境
- Linux または macOS
- `curl` コマンドが使用可能であること
- `git` がインストールされていること
- `unzip` コマンド（ZIP 解凍用）

## インストール

1. スクリプトをダウンロードまたは作成
   ```sh
   wget https://raw.githubusercontent.com/mugimugi555/ubuntu/refs/heads/main/github_tool/clone_repos.sh
   wget https://raw.githubusercontent.com/mugimugi555/ubuntu/refs/heads/main/github_tool/download_repos.sh
   ```
   または、手動で `clone_repos.sh` と `download_repos.sh` を作成し、スクリプトを記述。

## 使い方
### `clone_repos.sh`（Gitリポジトリをクローン）

#### 他の GitHub ユーザーのリポジトリをクローン
```sh
bash clone_repos.sh GitHubユーザー名
```

### `download_repos.sh`（リポジトリの ZIP をダウンロード & 解凍）

#### 他の GitHub ユーザーのリポジトリをダウンロード
```sh
bash download_repos.sh GitHubユーザー名
```

## 動作手順
### `clone_repos.sh`
1. GitHub のリポジトリ一覧ページを取得
2. 正規表現でリポジトリ名を抽出
3. 各リポジトリを `git clone` でクローン

### `download_repos.sh`
1. GitHub のリポジトリ一覧ページを取得
2. 正規表現でリポジトリ名を抽出
3. 各リポジトリの ZIP ファイルをダウンロード
4. ZIP を解凍

## 注意点
- クローン先またはダウンロード先のディレクトリには十分な書き込み権限があることを確認してください。
- 既存のディレクトリやファイルとリポジトリ名が重複する場合、エラーが発生する可能性があります。

## ライセンス
このスクリプトは MIT ライセンスの下で提供されます。

![タイトル画像](assets/images/footer.png)
