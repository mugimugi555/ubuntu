# clone_repos.sh および download_repos.sh の使い方

## 概要
このスクリプトは、指定した GitHub ユーザーのリポジトリ一覧を取得し、すべてのリポジトリを HTTPS 経由でクローンする `clone_repos.sh` と、リポジトリの ZIP をダウンロードして解凍する `download_repos.sh` の2つのスクリプトを提供します。
デフォルトでは、`mugimugi555` のリポジトリを対象とします。

## 必要な環境
- Linux または macOS
- `curl` コマンドが使用可能であること
- `git` がインストールされていること
- `unzip` コマンド（ZIP 解凍用）

## インストール
1. スクリプトをダウンロードまたは作成
   ```sh
   wget https://example.com/clone_repos.sh -O clone_repos.sh
   wget https://example.com/download_repos.sh -O download_repos.sh
   ```
   または、手動で `clone_repos.sh` と `download_repos.sh` を作成し、スクリプトを記述。

2. 実行権限を付与
   ```sh
   chmod +x clone_repos.sh download_repos.sh
   ```

## 使い方
### `clone_repos.sh`（Gitリポジトリをクローン）
#### デフォルト（mugimugi555 のリポジトリをクローン）
```sh
./clone_repos.sh
```

#### 他の GitHub ユーザーのリポジトリをクローン
```sh
./clone_repos.sh GitHubユーザー名
```
例:
```sh
./clone_repos.sh exampleuser
```

### `download_repos.sh`（リポジトリの ZIP をダウンロード & 解凍）
#### デフォルト（mugimugi555 のリポジトリをダウンロード）
```sh
./download_repos.sh
```

#### 他の GitHub ユーザーのリポジトリをダウンロード
```sh
./download_repos.sh GitHubユーザー名
```
例:
```sh
./download_repos.sh exampleuser
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
- GitHub の API 制限にかかる可能性があるため、多数のリポジトリを持つユーザーの場合は注意してください。
- 既存のディレクトリやファイルとリポジトリ名が重複する場合、エラーが発生する可能性があります。
- `download_repos.sh` で ZIP をダウンロードする場合、すべてのリポジトリがパブリックである必要があります。

## ライセンス
このスクリプトは MIT ライセンスの下で提供されます。

