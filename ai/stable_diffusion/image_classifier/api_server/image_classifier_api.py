from fastapi import FastAPI, File, UploadFile, HTTPException, Query
from PIL import Image
import webuiapi
import json
import re
import requests
import io

app = FastAPI()
api = webuiapi.WebUIApi()

def clean_tags(tags):
    """ deepdanbooru のタグを整形 """
    return [re.sub(r'[_-]', ' ', tag).strip() for tag in tags if tag]

def classify_image(clip_description, deepdanbooru_tags):
    """ 実写 or イラストを判定 """
    illustration_tags = {"illustration", "anime", "cartoon", "drawing", "manga", "comic"}
    realistic_tags = {"photo", "realistic", "photography", "selfie", "book", "surgical mask", "covered mouth"}

    is_illustration = any(tag in illustration_tags for tag in deepdanbooru_tags) or "illustration" in clip_description
    is_realistic = any(tag in realistic_tags for tag in deepdanbooru_tags) or "photo" in clip_description

    if any("photo" in tag.lower() for tag in deepdanbooru_tags):
        return "photo"
    elif is_realistic:
        return "photo"
    elif is_illustration:
        return "illustration"
    else:
        return "unknown"

def analyze_image(img):
    """ 画像を解析し、結果をJSONで返す """
    deepdanbooru_result = api.interrogate(image=img, model="deepdanbooru")
    deepdanbooru_tags = clean_tags(deepdanbooru_result.info.split(", "))

    clip_result = api.interrogate(image=img, model="clip")
    clip_description = clip_result.info.lower()

    classification = classify_image(clip_description, deepdanbooru_tags)

    return {
        "classification": classification,
        "clip_description": clip_description,
        "deepdanbooru_tags": deepdanbooru_tags
    }

@app.post("/analyze/")
async def analyze_uploaded_image(file: UploadFile = File(...)):
    """ アップロードされた画像を解析 """
    try:
        img = Image.open(io.BytesIO(await file.read()))
        result = analyze_image(img)
        return {"filename": file.filename, **result}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"画像解析に失敗しました: {str(e)}")

@app.get("/analyze/")
async def analyze_image_from_url(image_url: str = Query(..., description="解析する画像のURL")):
    """ URL経由で送信された画像を解析 """
    try:
        response = requests.get(image_url)
        response.raise_for_status()
        img = Image.open(io.BytesIO(response.content))
        result = analyze_image(img)
        return {"image_url": image_url, **result}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"画像解析に失敗しました: {str(e)}")

@app.get("/")
def root():
    return {"message": "Image Analysis API is running!"}
