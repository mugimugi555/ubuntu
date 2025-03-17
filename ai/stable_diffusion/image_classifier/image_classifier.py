import webuiapi
from PIL import Image
import sys
import json
import re

# WebUIApi のインスタンスを作成
api = webuiapi.WebUIApi()

# 画像のパスを取得
if len(sys.argv) < 2:
    print(json.dumps({"error": "画像ファイルのパスを指定してください"}))
    sys.exit(1)

image_path = sys.argv[1]
img = Image.open(image_path)

# === deepdanbooru で画像解析 ===
deepdanbooru_result = api.interrogate(image=img, model="deepdanbooru")
deepdanbooru_tags = deepdanbooru_result.info.split(", ")

# deepdanbooru のタグを整形
def clean_tags(tags):
    return [re.sub(r'[_-]', ' ', tag).strip() for tag in tags if tag]

deepdanbooru_tags = clean_tags(deepdanbooru_tags)

# === CLIP で画像解析 ===
clip_result = api.interrogate(image=img, model="clip")
clip_description = clip_result.info.lower()

# === 実写 or イラスト判定 ===
illustration_tags = {"illustration", "anime", "cartoon", "drawing", "manga", "comic"}
realistic_tags = {"photo", "realistic", "photography", "selfie", "book", "surgical mask", "covered mouth"}

# 判定ロジック
is_illustration = any(tag in illustration_tags for tag in deepdanbooru_tags) or "illustration" in clip_description
is_realistic = any(tag in realistic_tags for tag in deepdanbooru_tags) or "photo" in clip_description

# deepdanbooru_tags に "photo" が含まれる場合は強制的に実写と判定
if any("photo" in tag.lower() for tag in deepdanbooru_tags):
    classification = "photo"
elif is_realistic:
    classification = "photo"
elif is_illustration:
    classification = "illustration"
else:
    classification = "unknown"

# === JSON 出力 ===
output = {
    "image": image_path,
    "classification": classification,  # 実写 or イラスト
    "clip_description": clip_description,  # CLIP の詳細説明
    "deepdanbooru_tags": deepdanbooru_tags  # deepdanbooru のタグリスト
}

print(json.dumps(output, ensure_ascii=False, indent=4))
