import json
import os
import sys
from transformers import AutoModelForCausalLM, AutoTokenizer
import torch

# === モデル名を自動設定 ===
HF_CACHE_DIR = os.path.expanduser("~/.cache/huggingface/hub")
MODEL_CANDIDATES = [
    "google/gemma-3-27b-it",
    "google/gemma-3-12b-it",
    "google/gemma-3-4b-it",
    "google/gemma-3-1b-it"
]

def find_model():
    """ Hugging Face のキャッシュから利用可能なモデルを探す """
    for model in MODEL_CANDIDATES:
        model_path = os.path.join(HF_CACHE_DIR, f"models--{model.replace('/', '--')}")
        if os.path.exists(model_path):
            return model
    return None

# 環境変数が設定されていればそちらを使用
MODEL_NAME = os.getenv("MODEL_NAME", find_model())

if not MODEL_NAME:
    print(json.dumps({"error": "利用可能な Gemma モデルが見つかりませんでした。"}))
    sys.exit(1)

# モデルロードの開始
print(f"🔹 モデルをロード: {MODEL_NAME}", file=sys.stderr)
tokenizer = AutoTokenizer.from_pretrained(MODEL_NAME)
model = AutoModelForCausalLM.from_pretrained(MODEL_NAME, torch_dtype=torch.float16, device_map="auto")

# 標準入力からプロンプトを取得
prompt = sys.stdin.read().strip()
if not prompt:
    print(json.dumps({"error": "プロンプトが空です。"}))
    sys.exit(1)

# 入力をトークン化
inputs = tokenizer(prompt, return_tensors="pt").to("cuda")

# 応答の生成
output = model.generate(**inputs, max_length=100)
response_text = tokenizer.decode(output[0], skip_special_tokens=True)

# JSON 出力フォーマット
response_json = {
    "model": MODEL_NAME,
    "prompt": prompt,
    "response": response_text
}

# 通常のテキスト出力
print("Gemmaの応答:", response_text)

# JSON 形式での出力
print(json.dumps(response_json, ensure_ascii=False, indent=4))
