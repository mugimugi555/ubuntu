#!/bin/bash

# ============================
# LoRA Training Shell Script
# venvで環境管理 + 画像リサイズ + キャプション生成 + LoRA学習
# ============================

# ✅ 引数で画像フォルダを指定（デフォルトは "zunko"）
SOURCE_FOLDER=${1:-"zunko"}  # 変換元フォルダ

# ✅ LoRA モデルの出力フォルダ (キャラ名に基づく)
OUTPUT_DIR="output_loras"  # LoRA モデルの出力フォルダ

# ✅ 固定設定
TARGET_FOLDER="working_dataset" # 正規化画像とタグの保存先
VENV_DIR="venv-lora"            # 仮想環境ディレクトリ
IMAGE_SIZE=256                  # 画像のサイズ (縦横共通)
EPOCHS=10                       # エポック数
BATCH_SIZE=1                    # バッチサイズ

# =====================
# 環境のセットアップ
# =====================
setup_environment() {
  echo "🔹 システムパッケージをチェック..."
  sudo apt update && sudo apt install -y python3 python3-venv python3-pip git imagemagick pipx wget jq

  echo "🔹 仮想環境をセットアップ: $VENV_DIR"
  if [ ! -d "$VENV_DIR" ]; then
    python3 -m venv "$VENV_DIR"
  fi
  source "$VENV_DIR/bin/activate"

  echo "🔹 必要なライブラリをインストール..."
  pip install --upgrade pip
  pip install \
      "numpy<1.25.0" scipy torch torchvision torchaudio tensorboard \
      tensorflow tensorflow_io "accelerate>=0.26.0" transformers datasets matplotlib imagesize deepdanbooru

  echo "✅ 仮想環境のセットアップ完了！"
}

# =====================
# DeepDanbooru のセットアップ
# =====================
setup_deepdanbooru() {
  echo "🔹 DeepDanbooru モデルのセットアップ..."
  mkdir -p deepdanbooru

  if [ ! -f "deepdanbooru/model-resnet_custom_v3.h5" ]; then
    wget https://github.com/KichangKim/DeepDanbooru/releases/download/v3-20211112-sgd-e28/deepdanbooru-v3-20211112-sgd-e28.zip -O deepdanbooru/latest.zip
    unzip -o deepdanbooru/latest.zip -d deepdanbooru/
  fi

  echo "✅ DeepDanbooru のセットアップ完了！"
}

# =====================
# データセットのセットアップ
# =====================
setup_directory() {
  mkdir -p "$OUTPUT_DIR"
  mkdir -p "$TARGET_FOLDER"
}

# =====================
# キャプションを生成 (DeepDanbooru を使用) - **リサイズ前**
# =====================
generate_captions() {
  echo "🔹 DeepDanbooru でキャプションを生成中..."
  for img in "$SOURCE_FOLDER"/*.{jpg,png}; do
    if [ -f "$img" ]; then
      caption_json_file="${img%.*}.caption.json"

      # `.caption.json` が既にある場合はスキップ
      if [ -f "$caption_json_file" ]; then
        echo "⚠ キャプションが既に存在するためスキップ: $caption_json_file"
        continue
      fi

      # キャプション生成 (警告抑制)
      CUDA_VISIBLE_DEVICES=0 TF_CPP_MIN_LOG_LEVEL=3 python3 generate_captions.py "$img" 2>/dev/null

      # JSON の解析に失敗した場合のチェック
      if [ ! -s "$caption_json_file" ] || ! jq empty "$caption_json_file" > /dev/null 2>&1; then
        echo "⚠ キャプション生成に失敗: $img"
        rm -f "$caption_json_file"
        continue
      fi

      echo "✅ キャプション作成: $caption_json_file"
    fi
  done
  echo "✅ キャプションの生成が完了しました！"
}

# =====================
# 画像の整理 (リサイズ・ファイル名統一 & キャプション変換)
# =====================
process_images() {
  TARGET_PATH="$TARGET_FOLDER/1_$SOURCE_FOLDER"

  rm -rf "$TARGET_PATH"/*
  mkdir -p "$TARGET_PATH"

  echo "🔹 画像をリサイズし、統一フォーマットでコピー中..."
  COUNT=1
  for img in "$SOURCE_FOLDER"/*.{jpg,png}; do
    if [ -f "$img" ]; then
      NEW_NAME=$(printf "%04d.png" "$COUNT")
      NEW_PATH="$TARGET_PATH/$NEW_NAME"

      mogrify -resize "${IMAGE_SIZE}x${IMAGE_SIZE}!" -path "$TARGET_PATH" "$img"
      mv "$TARGET_PATH/$(basename "$img")" "$NEW_PATH"

      # キャプションファイルの変換と移動
      OLD_CAPTION_JSON="${img%.*}.caption.json"
      NEW_CAPTION_FILE="${NEW_PATH%.png}.caption"

      if [ -f "$OLD_CAPTION_JSON" ]; then
        # 学習ディレクトリ名をタグの最初に追加して `.caption` に保存（スコア順）
        echo -n "$SOURCE_FOLDER, " > "$NEW_CAPTION_FILE"
        jq -r 'to_entries | sort_by(-.value) | .[] | select(.value > 0.5) | .key' "$OLD_CAPTION_JSON" | paste -sd ", " - >> "$NEW_CAPTION_FILE"
        echo "✅ キャプション変換: $NEW_CAPTION_FILE"
      else
        echo "⚠ キャプションが見つかりません: $OLD_CAPTION_JSON"
      fi

      echo "✅ 画像変換完了: $NEW_NAME"
      COUNT=$((COUNT + 1))
    fi
  done
  echo "🎉 画像の整理が完了しました！"
}

# =====================
# LoRA 学習の実行
# =====================
run_training() {
  echo "🔹 LoRA学習開始..."
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
    --network_module=networks.lora    \
    --caption_extension caption

  echo "✅ 学習完了！モデルは $OUTPUT_DIR に保存されました。"
}

# =====================
# 後処理 (dataset の削除)
# =====================
cleanup() {
  echo "🗑️ データセットを削除中..."
  rm -rf "$TARGET_FOLDER"
  echo "✅ データセットの削除が完了しました！"
}

# =====================
# メイン処理
# =====================
main() {
  setup_environment
  setup_deepdanbooru
  setup_directory
  generate_captions
  process_images
  run_training
  cleanup
  deactivate
}

main
