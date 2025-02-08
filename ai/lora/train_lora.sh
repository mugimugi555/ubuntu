#!/bin/bash

# ============================
# LoRA Training Shell Script
# venvで環境管理 + 画像リサイズ + LoRA学習 (日本ミラー & 並列ダウンロード対応)
# ============================

# 設定
VENV_DIR="venv-lora"  # 仮想環境ディレクトリ
BASE_DIR="dataset"  # 学習データのベースディレクトリ
OUTPUT_DIR="output_lora_model"  # 出力ディレクトリ
IMAGE_SIZE=256  # 画像のサイズ (縦横共通)
EPOCHS=10  # エポック数
BATCH_SIZE=1  # バッチサイズ

# =====================
# 環境のセットアップ
# =====================
setup_environment() {
  echo "🔹 システムパッケージをチェック..."
  sudo apt update && sudo apt install -y python3 python3-venv python3-pip git imagemagick pipx

  echo "🔹 仮想環境をセットアップ: $VENV_DIR"
  if [ ! -d "$VENV_DIR" ]; then
    python3 -m venv "$VENV_DIR"
  fi
  source "$VENV_DIR/bin/activate"

  echo "🔹 `uv` のインストール"
  pipx install uv

  echo "🔹 `uv` を使用してライブラリを並列ダウンロード & インストール..."
  env PIP_INDEX_URL="https://pypi.ngc.nvidia.com/simple" \
    uv pip install --upgrade pip && \
    uv pip install \
      "numpy<1.25.0" scipy torch torchvision torchaudio tensorboard \
      tensorflow accelerate transformers datasets matplotlib imagesize

  echo "✅ 仮想環境のセットアップ完了！"
}

# =====================
# 事前学習済みモデルの取得
# =====================
download_pretrained_model() {
  if [ ! -d "stable-diffusion-v1-5" ]; then
    echo "🔹 事前学習済みモデルが見つかりません。Hugging Face からダウンロードします..."
    git clone https://huggingface.co/stable-diffusion-v1-5/stable-diffusion-v1-5
  else
    echo "✅ 事前学習済みモデルが既に存在します。"
  fi
}

# =====================
# 学習スクリプトの取得
# =====================
setup_training_repo() {
  if [ ! -d "sd-scripts" ]; then
    echo "🔹 Kohya’s SS スクリプトが見つかりません。GitHubからクローンします..."
    git clone https://github.com/kohya-ss/sd-scripts.git
  else
    echo "✅ 学習スクリプトは既に存在します。最新の状態に更新します..."
    cd "sd-scripts" && git pull && cd ..
  fi

  # `sd-scripts` の `requirements.txt` を `uv` でインストール
  echo "🔹 sd-scripts の依存パッケージをインストール中..."
  # shellcheck disable=SC2164
  cd sd-scripts
  uv pip install -r requirements.txt
  cd ..
  echo "✅ sd-scripts の依存パッケージをインストール完了！"
}

# =====================
# データセットのセットアップ
# =====================
setup_dataset() {
  if [ ! -d "$BASE_DIR" ]; then
    echo "❌ データセットディレクトリが見つかりません: $BASE_DIR"
    echo "ディレクトリを作成してください。"
    exit 1
  fi
  setup_captions
}
setup_captions() {
  FOLDER_NAME="Dariusz"
  for img in dataset/$FOLDER_NAME/*.{jpg,png}; do
    caption_file="${img%.*}.caption"
    if [ ! -f "$caption_file" ]; then
      echo "$FOLDER_NAME" > "$caption_file"
    fi
  done
  echo "✅ キャプションファイルを自動生成しました。"
}

# =====================
# 画像リサイズ処理
# =====================
resize_images() {
  echo "🔹 画像を ${IMAGE_SIZE}x${IMAGE_SIZE} にリサイズ中..."
  find "$BASE_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" \) -exec mogrify -resize ${IMAGE_SIZE}x${IMAGE_SIZE}\! {} \;
  echo "✅ リサイズ完了！"
}

# =====================
# LoRA 学習の実行
# =====================
run_training() {

  echo "🔹 LoRA学習開始..."
  export PYTORCH_CUDA_ALLOC_CONF="expandable_segments:True"

  accelerate launch --mixed_precision="bf16" "sd-scripts/train_network.py" \
    --pretrained_model_name_or_path="stable-diffusion-v1-5" \
    --train_data_dir="$BASE_DIR" \
    --output_dir="$OUTPUT_DIR" \
    --resolution=$IMAGE_SIZE \
    --train_batch_size=$BATCH_SIZE \
    --max_train_epochs=$EPOCHS \
    --learning_rate=5e-6 \
    --network_module=networks.lora

  echo "✅ 学習完了！モデルは $OUTPUT_DIR に保存されました。"
}

# =====================
# メイン処理
# =====================
main() {
  # 環境のセットアップ（仮想環境の作成・パッケージインストール）
  setup_environment

  # 学習スクリプト（sd-scripts）の取得・更新
  setup_training_repo

  # 事前学習済みモデルの取得（Hugging Face からクローン）
  download_pretrained_model

  # データセットのセットアップ（フォルダ構成の確認）
  setup_dataset

  # 画像サイズを統一するため、一括リサイズ処理
  resize_images

  # LoRA 学習を開始
  run_training

  # 仮想環境の解除
  deactivate
}

main
