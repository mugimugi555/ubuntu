#!/bin/bash

# ============================
# LoRA Batch Training Script
# ============================

# ✅ 学習するフォルダのリスト
TRAIN_FOLDERS=(
  "itako"
  "kiritan"
  "metan"
  "sora"
  "usagi"
  "zundamon"
  "zunko"
)

# ✅ ループして各フォルダで train_lora.sh を実行
for folder in "${TRAIN_FOLDERS[@]}"; do
  echo "🔹 学習開始: $folder"

  # フォルダが存在するかチェック
  if [ ! -d "$folder" ]; then
    echo "⚠ フォルダが見つかりません: $folder"
    continue
  fi

  # `train_lora.sh` を実行
  bash train_lora.sh "$folder"

  echo "✅ 学習完了: $folder"
  echo "-----------------------------"
done

echo "🎉 すべての学習が完了しました！"
