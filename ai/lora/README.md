# LoRA Training Shell Script

## 概要

このスクリプトは、LoRA (Low-Rank Adaptation) モデルの学習を自動化するためのものです。
以下の機能を提供します。

- **環境のセットアップ**: 必要なライブラリやツールのインストール
- **DeepDanbooruを使用したキャプション生成**: 画像から自動でキャプションを作成
- **画像のリサイズ & 名前の統一**: LoRA学習用のデータセットを整理
- **LoRA モデルの学習**: 学習データを使ってLoRAをトレーニング
- **学習完了後のデータクリーンアップ**: `working_dataset/` を削除してクリーンな状態に戻す

## 動作環境

- Ubuntu またはその他の Linux 環境 (Windows でも WSL で動作可)
- Python 3.8 以上
- CUDA 環境 (GPUを使用する場合)

## 使い方

### 1. 画像データセットを準備

学習したい画像を zunko/ などのフォルダに配置します。

例）https://drive.google.com/drive/folders/1oyR1-1H64l7Veyb5ybYUB0K9FTz7j5NN からダウンロード

### 2. スクリプトを実行

```bash
bash train_lora.sh <画像フォルダ名>
```

例えば、"zunko" フォルダを学習させる場合:

```bash
bash train_lora.sh zunko
```

### 3. 学習結果の確認

学習が完了すると、以下のフォルダにモデルが出力されます。

```bash
output_loras/
```

## スクリプトの詳細

このスクリプトは、以下のプロセスを自動で実行します。

1. **環境のセットアップ**

    - 必要なパッケージをインストール（Python、仮想環境、ライブラリ）
    - `venv-lora` 仮想環境を作成・有効化
    - `DeepDanbooru` のモデルをダウンロードしてセットアップ

2. **キャプション生成 (****`generate_captions`****)**

    - 画像ごとに `DeepDanbooru` を使い `.caption.json` を生成
    - `.caption.json` が既にある場合はスキップ
    - スコア順にタグを並び替え、最も関連性の高いタグを選定

3. **画像のリサイズ & 名前統一 (****`process_images`****)**

    - 画像をリサイズして `working_dataset/1_<フォルダ名>/0001.png` のように変換
    - `.caption.json` を `.caption` ファイルに変換し、タグを保存
    - タグには**学習フォルダ名が最初に追加**される

4. **LoRA 学習 (****`run_training`****)**

    - `stable-diffusion-v1-5` を基に LoRA の学習を実行
    - `accelerate launch` を使用し、GPU最適化
    - 出力は `output_loras/` に保存
    - `.caption` ファイルは自動で学習データとして使用される

5. **クリーンアップ (****`cleanup`****)**

    - 学習完了後、`working_dataset/` を削除

## 注意事項

- `DeepDanbooru` のモデルを初回実行時にダウンロードするため、ネットワーク接続が必要です。
- Python 仮想環境を必ず有効にしてから実行してください。
- LoRA の学習は GPU 環境を推奨します。
- **学習完了後、****`working_dataset/`**** が自動削除されるため、必要に応じてバックアップを取ってください。**

## ライセンス

このスクリプトは MIT ライセンスのもとで提供されます。
