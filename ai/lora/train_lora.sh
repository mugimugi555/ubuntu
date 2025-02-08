#!/bin/bash

# ============================
# LoRA Training Shell Script
# venvで環境管理 + 画像リサイズ + LoRA学習 (日本ミラー & 並列ダウンロード対応)
# ============================

# ✅ 外部変数 (環境変数やスクリプト引数から設定可能)
SOURCE_FOLDER="zunko"    # 変換元フォルダ (デフォルト: zunko)

# ✅ 固定設定
TARGET_FOLDER="dataset"  # 変換後の保存先
VENV_DIR="venv-lora"     # 仮想環境ディレクトリ
IMAGE_SIZE=256           # 画像のサイズ (縦横共通)
EPOCHS=10                # エポック数
BATCH_SIZE=1             # バッチサイズ

# ✅ LoRA モデルの出力フォルダ (キャラ名に基づく)
OUTPUT_DIR="output_loras"  # LoRA モデルの出力フォルダ

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

  #
  env PIP_INDEX_URL="https://pypi.ngc.nvidia.com/simple"
  pip install --upgrade pip
  pip install \
      "numpy<1.25.0" scipy torch torchvision torchaudio tensorboard \
      tensorflow "accelerate>=0.26.0" transformers datasets matplotlib imagesize

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

  echo "🔹 sd-scripts の依存パッケージをインストール中..."
  cd sd-scripts
  uv pip install -r requirements.txt
  cd ..
  echo "✅ sd-scripts の依存パッケージをインストール完了！"
}

# =====================
# データセットのセットアップ
# =====================
setup_directory() {
  if [ ! -d "$OUTPUT_DIR" ]; then
    echo "⚠ LORA出力用ディレクトリが見つかりません: $OUTPUT_DIR"
    echo "🔹 ディレクトリを作成します..."
    mkdir -p "$OUTPUT_DIR"
  fi
  echo "✅ LORA出力用ディレクトリが準備されました: $OUTPUT_DIR"

  if [ ! -d "$TARGET_FOLDER" ]; then
    echo "⚠ データセットディレクトリが見つかりません: $TARGET_FOLDER"
    echo "🔹 ディレクトリを作成します..."
    mkdir -p "$TARGET_FOLDER"
  fi
  echo "✅ データセットディレクトリが準備されました: $TARGET_FOLDER"
}

# =====================
# 画像の整理 (リサイズ・ファイル名統一・キャプション作成)
# =====================
process_images() {
  TARGET_PATH="$TARGET_FOLDER/1_$SOURCE_FOLDER"  # 出力先フォルダ

  # ✅ 既存のデータを削除 (フォルダ内のファイルを全削除)
  if [ -d "$TARGET_PATH" ]; then
    echo "⚠ $TARGET_PATH の中身をクリアします..."
    rm -rf "$TARGET_PATH"/*
  fi

  # ✅ 出力先フォルダを作成
  mkdir -p "$TARGET_PATH"

  # ✅ 画像処理
  echo "🔹 画像をリサイズし、統一フォーマットでコピー中..."
  COUNT=1
  for img in "$SOURCE_FOLDER"/*.{jpg,png}; do
    if [ -f "$img" ]; then
      NEW_NAME=$(printf "%04d.png" "$COUNT")  # 0001.png のように統一
      NEW_PATH="$TARGET_PATH/$NEW_NAME"

      # 画像をリサイズしてコピー
      mogrify -resize "${IMAGE_SIZE}x${IMAGE_SIZE}!" -path "$TARGET_PATH" "$img"
      mv "$TARGET_PATH/$(basename "$img")" "$NEW_PATH"

      # キャプション作成
      echo "$SOURCE_FOLDER" > "${NEW_PATH%.png}.caption"

      echo "✅ $NEW_NAME を作成 (キャプション: $SOURCE_FOLDER)"
      COUNT=$((COUNT + 1))
    fi
  done
  echo "🎉 画像の整理が完了しました！"
}

# =====================
# データセットのクリア (学習完了後に削除)
# =====================
clean_dataset() {
  echo "🔹 学習完了！データセットフォルダを削除します..."
  rm -rf "$TARGET_FOLDER"
  echo "✅ データセットフォルダを削除しました: $TARGET_FOLDER"
}

# =====================
# LoRA 学習の実行
# =====================
run_training() {
  echo "🔹 LoRA学習開始..."
  export PYTORCH_CUDA_ALLOC_CONF="expandable_segments:True"

  accelerate launch \
    --mixed_precision="bf16" "sd-scripts/train_network.py"  \
    --pretrained_model_name_or_path="stable-diffusion-v1-5" \
    --train_data_dir="$TARGET_FOLDER" \
    --output_dir="$OUTPUT_DIR"        \
    --output_name=$SOURCE_FOLDER      \
    --resolution=$IMAGE_SIZE          \
    --train_batch_size=$BATCH_SIZE    \
    --max_train_epochs=$EPOCHS        \
    --learning_rate=5e-6              \
    --network_module=networks.lora

  echo "✅ 学習完了！モデルは $OUTPUT_DIR に保存されました。"

  # ✅ 学習完了後にデータセットを削除
  clean_dataset
}

# =====================
# メイン処理
# =====================
main() {
  setup_environment
  setup_training_repo
  download_pretrained_model
  setup_directory
  process_images
  run_training
  deactivate
}

main
