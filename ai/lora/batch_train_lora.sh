#!/bin/bash

# ============================
# LoRA Batch Training Script
# ============================

# ✅ 学習対象の親ディレクトリ
BATCH_DIR="batch_dir"

# ✅ `batch_dir` が存在しない場合は作成
if [ ! -d "$BATCH_DIR" ]; then
  echo "🔹 $BATCH_DIR が存在しません。新しく作成します..."
  mkdir -p "$BATCH_DIR"
fi

# ✅ batch_dir 内のサブフォルダを自動取得 (ディレクトリのみ)
TRAIN_FOLDERS=($(find "$BATCH_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \;))

# ✅ フォルダが空の場合、メッセージを表示して終了
if [ ${#TRAIN_FOLDERS[@]} -eq 0 ]; then
  echo "⚠ $BATCH_DIR 内に学習対象フォルダがありません。"
  echo "🔹 画像フォルダを作成し、その中に学習用画像を配置してください。"
  echo "🔹 例: mkdir $BATCH_DIR/zunko && mv *.jpg $BATCH_DIR/zunko/"
  exit 1
fi

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
