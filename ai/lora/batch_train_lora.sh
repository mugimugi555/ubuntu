#!/bin/bash

# ============================
# LoRA Batch Training Script
# ============================

# ✅ 学習対象の親ディレクトリを指定 (フォルダをこの中から自動取得)
BATCH_DIR="batch_dir"

# ✅ batch_dir 内のサブフォルダを自動取得 (ディレクトリのみ)
TRAIN_FOLDERS=($(find "$BATCH_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \;))

# ✅ ループして各フォルダで train_lora.sh を実行
for folder in "${TRAIN_FOLDERS[@]}"; do
  echo "🔹 学習開始: $folder"

  # フォルダのパスを取得
  FOLDER_PATH="$BATCH_DIR/$folder"

  # フォルダが存在するかチェック
  if [ ! -d "$FOLDER_PATH" ]; then
    echo "⚠ フォルダが見つかりません: $FOLDER_PATH"
    continue
  fi

  # `train_lora.sh` を実行
  bash train_lora.sh "$FOLDER_PATH"

  echo "✅ 学習完了: $folder"
  echo "-----------------------------"
done

echo "🎉 すべての学習が完了しました！"
