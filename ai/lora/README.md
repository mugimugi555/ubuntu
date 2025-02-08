# LoRA Training Shell Script

## 概要
このスクリプトは、LoRA (Low-Rank Adaptation) モデルの学習を自動化するためのものです。
以下の機能を提供します。

- **環境のセットアップ**: 必要なライブラリやツールのインストール
- **DeepDanbooruを使用したキャプション生成**: 画像から自動でキャプションを作成
- **画像のリサイズ & 名前の統一**: LoRA学習用のデータセットを整理
- **LoRA モデルの学習**: 学習データを使ってLoRAをトレーニング

## 動作環境
- Ubuntu またはその他の Linux 環境 (Windows でも WSL で動作可)
- Python 3.8 以上
- CUDA 環境 (GPUを使用する場合)

## インストール & セットアップ

### 1. 必要なパッケージをインストール
```bash
sudo apt update && sudo apt install -y python3 python3-venv python3-pip git imagemagick pipx wget jq
```

### 2. 仮想環境の作成
```bash
python3 -m venv venv-lora
source venv-lora/bin/activate
```

### 3. 必要な Python ライブラリをインストール
```bash
pip install --upgrade pip
pip install numpy scipy torch torchvision torchaudio tensorboard \
    tensorflow tensorflow_io accelerate transformers datasets matplotlib imagesize deepdanbooru
```

### 4. DeepDanbooru のセットアップ
```bash
mkdir -p deepdanbooru
wget https://github.com/KichangKim/DeepDanbooru/releases/download/v3-20211112-sgd-e28/deepdanbooru-v3-20211112-sgd-e28.zip -O deepdanbooru/latest.zip
unzip -o deepdanbooru/latest.zip -d deepdanbooru/
```

## 使い方

### 1. 画像データセットを準備
学習したい画像を **zunko/** などのフォルダに配置します。

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

## スクリプトの主な処理

### 1. キャプション生成 (`generate_captions`)
- 画像ごとに DeepDanbooru を使い `.caption.json` を生成
- `.caption.json` が既にある場合はスキップ
- スコア順にタグを並び替え、最も関連性の高いタグを選定

### 2. 画像のリサイズ & 名前統一 (`process_images`)
- 画像をリサイズして `dataset/1_<フォルダ名>/0001.png` のように変換
- `.caption.json` を `.caption` ファイルに変換し、タグを保存
- タグには**学習フォルダ名が最初に追加**される

### 3. LoRA 学習 (`run_training`)
- `stable-diffusion-v1-5` を基に LoRA の学習を実行
- `accelerate launch` を使用し、GPU最適化
- 出力は `output_loras/` に保存

## 注意事項
- `DeepDanbooru` のモデルを初回実行時にダウンロードするため、ネットワーク接続が必要です。
- Python 仮想環境を必ず有効にしてから実行してください。
- LoRA の学習は GPU 環境を推奨します。

## ライセンス
このスクリプトは MIT ライセンスのもとで提供されます。
