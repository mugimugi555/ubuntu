import json
import sys
from transformers import AutoModelForCausalLM, AutoTokenizer
import torch

# モデル名
model_name = "$MODEL_NAME"

# トークナイザーとモデルのロード
tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModelForCausalLM.from_pretrained(model_name, torch_dtype=torch.float16, device_map="auto")

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

# JSON 出力
response_json = {
    "model": model_name,
    "prompt": prompt,
    "response": response_text
}

print(json.dumps(response_json, ensure_ascii=False, indent=4))
