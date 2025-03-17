import json
import os
import re
import time
from datetime import datetime
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from transformers import AutoModelForCausalLM, AutoTokenizer, AutoConfig
import torch

app = FastAPI()
MODEL_NAME = "google/gemma-3-1b-it"
HF_CACHE_DIR = os.path.expanduser("~/.cache/huggingface/hub")

def clean_response(response):
    response = re.sub(r'(\n\*\*)+', '', response)
    response = re.sub(r'\*\*+', '', response)
    response = re.sub(r'\n+', '\n', response).strip()
    return response

try:
    config = AutoConfig.from_pretrained(MODEL_NAME)
    tokenizer = AutoTokenizer.from_pretrained(MODEL_NAME)
    model = AutoModelForCausalLM.from_pretrained(MODEL_NAME, torch_dtype=torch.float16, device_map="auto")
except Exception as e:
    raise RuntimeError(f"モデルのロードに失敗しました: {str(e)}")

class GenerateRequest(BaseModel):
    prompt: str

@app.get("/")
def root():
    return {"message": "Google Gemma 3 API is running!"}

@app.post("/generate")
def generate_response(request: GenerateRequest):
    prompt = request.prompt.strip()
    if not prompt:
        raise HTTPException(status_code=400, detail="プロンプトが空です。")

    start_time = time.time()
    inputs = tokenizer(prompt, return_tensors="pt").to("cuda")
    output = model.generate(**inputs, max_length=100)
    response_text = clean_response(tokenizer.decode(output[0], skip_special_tokens=True))
    response_time = round(time.time() - start_time, 3)
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    return {
        "timestamp": timestamp,
        "model": MODEL_NAME,
        "prompt": prompt,
        "response": response_text,
        "response_time": response_time
    }
