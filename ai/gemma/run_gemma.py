import json
import os
import sys
import re
import time
from datetime import datetime
from transformers import AutoModelForCausalLM, AutoTokenizer, AutoConfig
import torch

# === 設定（使用するモデルを明示的に指定） ===
MODEL_NAME = "google/gemma-3-1b-it"  # モデル名を明示的に指定
HF_CACHE_DIR = os.path.expanduser("~/.cache/huggingface/hub")

def list_local_models():
    """ Hugging Face のローカルキャッシュから利用可能なモデルを取得 """
    if not os.path.exists(HF_CACHE_DIR):
        return {"error": "Hugging Face のキャッシュディレクトリが存在しません。モデルをダウンロードしてください。"}

    models = []
    for entry in os.listdir(HF_CACHE_DIR):
        if entry.startswith("models--"):
            model_name = entry.replace("models--", "").replace("--", "/")
            models.append(model_name)

    return {"local_models": models} if models else {"error": "ローカルに保存されている Hugging Face モデルはありません。"}

def clean_response(response):
    """ 応答のテキストを整形（不要な `**` や改行を除去）"""
    response = re.sub(r'(\n\*\*)+', '', response)  # `\n**\n**...` を削除
    response = re.sub(r'\*\*+', '', response)  # 残っている `**` の連続を削除
    response = re.sub(r'\n+', '\n', response).strip()  # 連続する改行を1つにする
    return response

try:
    # 設定をロードして `vocab_size` があるか確認
    config = AutoConfig.from_pretrained(MODEL_NAME)
    if not hasattr(config, "vocab_size"):
        raise ValueError("モデル設定に vocab_size がありません。")

    # トークナイザーとモデルをロード
    tokenizer = AutoTokenizer.from_pretrained(MODEL_NAME)
    model = AutoModelForCausalLM.from_pretrained(MODEL_NAME, torch_dtype=torch.float16, device_map="auto")

except Exception as e:
    # エラーメッセージを JSON 形式で出力（他のテキスト出力なし）
    error_message = {
        "error": f"モデルのロードに失敗しました: {MODEL_NAME}",
        "reason": str(e),
        "solution": [
            "Hugging Face にログインし、適切なアクセストークンを設定してください。",
            "モデルの利用規約（アグリメント）に同意してください。",
            "以下のコマンドを実行し、モデルをダウンロードしてください。",
            f"  huggingface-cli login --token YOUR_HF_TOKEN",
            f"  huggingface-cli download {MODEL_NAME}"
        ],
        "huggingface_model_url": f"https://huggingface.co/{MODEL_NAME}",
        "local_models": list_local_models()
    }
    print(json.dumps(error_message, ensure_ascii=False, indent=4))
    sys.exit(1)

# 標準入力からプロンプトを取得
prompt = sys.stdin.read().strip()
if not prompt:
    print(json.dumps({"error": "プロンプトが空です。"}))
    sys.exit(1)

# === 応答生成の処理時間を計測 ===
start_time = time.time()

# 入力をトークン化
inputs = tokenizer(prompt, return_tensors="pt").to("cuda")

# 応答の生成
output = model.generate(**inputs, max_length=100)
response_text = tokenizer.decode(output[0], skip_special_tokens=True)

# 応答のクリーンアップ
response_text = clean_response(response_text)

# レスポンスにかかった時間
response_time = round(time.time() - start_time, 3)  # 秒単位（小数点3桁）

# タイムスタンプを取得（MySQL で管理しやすい形式）
timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

# JSON 出力フォーマット
response_json = {
    "timestamp": timestamp,
    "model": MODEL_NAME,
    "prompt": prompt,
    "response": response_text,
    "response_time": response_time  # レスポンス時間（秒）
}

# JSON 形式での出力のみ
print(json.dumps(response_json, ensure_ascii=False, indent=4))
