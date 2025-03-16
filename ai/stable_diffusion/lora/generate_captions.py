import deepdanbooru as dd
import tensorflow as tf
import numpy as np
import os
import sys
import json
from PIL import Image

# ✅ 引数のチェック
if len(sys.argv) != 2:
    print(json.dumps({"error": "Usage: python generate_captions.py <image_file>"}))
    sys.exit(1)

image_path = sys.argv[1]
output_json_path = os.path.splitext(image_path)[0] + ".caption.json"

# ✅ DeepDanbooru のモデルとタグのパス
project_path = "deepdanbooru/"
tags_path = os.path.join(project_path, "tags.txt")

if not os.path.exists(project_path):
    print(json.dumps({"error": "DeepDanbooru model not found!"}))
    sys.exit(1)

if not os.path.exists(tags_path):
    print(json.dumps({"error": "tags.txt not found!"}))
    sys.exit(1)

# ✅ モデルのロード
print("🔹 DeepDanbooru モデルをロード中...")
model = dd.project.load_model_from_project(project_path, compile_model=True)

# ✅ `tags.txt` を直接読み込む
with open(tags_path, "r", encoding="utf-8") as f:
    tags = [line.strip() for line in f.readlines()]

# ✅ 画像の前処理
image = Image.open(image_path).convert("RGB")
image = np.array(image).astype(np.float32) / 255.0  # 🔹 画像を正規化

# ✅ DeepDanbooru の画像変換関数を使用
target_width, target_height = model.input_shape[1], model.input_shape[2]
image = dd.image.transform_and_pad_image(image, target_width, target_height)

# ✅ 画像からタグを生成
image = np.expand_dims(image, axis=0)  # バッチ次元を追加
predictions = model.predict(image)[0]

# ✅ スコア 0.5 以上のタグを抽出し、スコア順に並び替え
tag_threshold = 0.5
tag_dict = {tags[i]: float(predictions[i]) for i in range(len(tags)) if predictions[i] > tag_threshold}

# ✅ スコア順に並び替え
sorted_tag_dict = dict(sorted(tag_dict.items(), key=lambda item: item[1], reverse=True))

# ✅ JSON で出力
json_output = json.dumps(sorted_tag_dict, indent=2, ensure_ascii=False)
print(json_output)

# ✅ ファイルに保存
with open(output_json_path, "w", encoding="utf-8") as f:
    f.write(json_output)

print(f"✅ キャプションを {output_json_path} に保存しました！")
