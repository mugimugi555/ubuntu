#!/bin/bash

set -e  # エラー時にスクリプトを停止

# ======================================================
# === 設定（変更可能な変数）
# ======================================================

# 仮想環境のディレクトリ
PYTHON_ENV_DIR="$HOME/venvs/gemma3"

# Hugging Face API トークン設定
HF_HOME="$HOME/.cache/huggingface"
HF_TOKEN="YOUR_HF_TOKEN_HERE"  # 必ずアクセストークンを設定

# ======================================================
# Google Gemma 3シリーズ対応GPU & 必要VRAM一覧
# ======================================================
declare -A GEMMA_MODELS
GEMMA_MODELS=(
    ["google/gemma-3-1b-it"]=4
    ["google/gemma-3-4b-it"]=8
    ["google/gemma-3-12b-it"]=16
    ["google/gemma-3-27b-it"]=48
)

# === VRAM 要件チェック & 適切なモデル選択 ===
echo "🔹 GPU の VRAM 容量を取得中..."
AVAILABLE_VRAM_GB=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits | awk '{print $1/1024}' | sort -nr | head -n1)

echo "✅ 使用可能な VRAM: ${AVAILABLE_VRAM_GB}GB"

# 使用可能な VRAM に応じて対応するモデルをリストアップ
echo "🔹 使用可能な Gemma モデル一覧:"
AVAILABLE_MODELS=()
for MODEL in "${!GEMMA_MODELS[@]}"; do
    if (( $(echo "$AVAILABLE_VRAM_GB >= ${GEMMA_MODELS[$MODEL]}" | bc -l) )); then
        AVAILABLE_MODELS+=("$MODEL")
        echo "   - $MODEL (推奨 VRAM: ${GEMMA_MODELS[$MODEL]}GB)"
    fi
done

# 最適なモデルを自動選択（最大のモデルを選択）
MODEL_NAME="${AVAILABLE_MODELS[-1]}"
REQUIRED_VRAM_GB="${GEMMA_MODELS[$MODEL_NAME]}"

echo "✅ 自動選択されたモデル: $MODEL_NAME (推定必要VRAM: ${REQUIRED_VRAM_GB}GB)"

# === CUDA バージョンの取得 ===
get_cuda_version() {
    echo "🔹 `nvcc` で CUDA のバージョンを取得..."
    if command -v nvcc &>/dev/null; then
        CUDA_VERSION=$(nvcc --version | grep "release" | awk '{print $NF}' | sed -E 's/[V,]//g' | cut -d'.' -f1,2)
        CUDA_VERSION="cu$(echo $CUDA_VERSION | tr -d '.')"
        echo "✅ 正しく検出された CUDA バージョン: $CUDA_VERSION"
    else
        echo "❌ `nvcc` コマンドが見つかりません！CUDA が正しくインストールされているか確認してください。"
        exit 1
    fi
}

echo "🔹 Google Gemma 3 のセットアップを開始します..."

# 1. 必要なパッケージのインストール
echo "🔹 必要なパッケージをインストール中..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y python3 python3-venv python3-pip git curl bc xdg-utils

# 2. CUDA バージョンの取得
get_cuda_version

# 3. Hugging Face にログイン（APIキーが必要）
echo "🔹 Hugging Face の認証を確認中..."
mkdir -p "$HF_HOME"

if [[ "$HF_TOKEN" == "YOUR_HF_TOKEN_HERE" || -z "$HF_TOKEN" ]]; then
    echo "⚠️ Hugging Face の API トークンが設定されていません。"
    echo "🌐 Hugging Face のトークン作成ページを開きます..."
    xdg-open "https://huggingface.co/settings/tokens"

    read -p "🔑 API トークンを入力してください: " HF_TOKEN
    if [ -z "$HF_TOKEN" ]; then
        echo "❌ API トークンが入力されませんでした。スクリプトを終了します。"
        exit 1
    fi
fi

echo -n "$HF_TOKEN" > "$HF_HOME/token"
huggingface-cli login --token "$HF_TOKEN"

# 4. モデル利用規約（アグリメント）の確認
echo "🔹 モデルの利用規約を確認中..."
AGREEMENT_CHECK=$(curl -s -H "Authorization: Bearer $HF_TOKEN" "https://huggingface.co/api/models/$MODEL_NAME")
if echo "$AGREEMENT_CHECK" | grep -q "error"; then
    echo "⚠️ モデルの利用規約に同意していません。"
    echo "🌐 モデルの利用許可ページを開きます..."
    xdg-open "https://huggingface.co/$MODEL_NAME"
    echo "🔹 ページを開いたら「Access Model」をクリックして承諾してください。"
    exit 1
fi

# 5. Python 仮想環境の作成
PYTHON_ENV_DIR="$HOME/venvs/${MODEL_NAME//\//-}"  # モデル名に応じた仮想環境ディレクトリ
if [ ! -d "$PYTHON_ENV_DIR" ]; then
    echo "🔹 Python 仮想環境を作成中..."
    python3 -m venv "$PYTHON_ENV_DIR"
else
    echo "✅ 既に仮想環境が存在します: $PYTHON_ENV_DIR"
fi

# 仮想環境を有効化
source "$PYTHON_ENV_DIR/bin/activate"

# 6. 必要な Python ライブラリのインストール
echo "🔹 必要な Python ライブラリをインストール中..."
pip install --upgrade pip setuptools wheel
pip install torch torchvision torchaudio --index-url "https://download.pytorch.org/whl/$CUDA_VERSION"
pip install --upgrade git+https://github.com/huggingface/transformers.git
pip install huggingface_hub accelerate

# 7. Hugging Face のモデルをダウンロード
echo "🔹 Google Gemma 3 のモデルをダウンロード中..."
HF_HUB_ENABLE_HF_TRANSFER=1 huggingface-cli download --token "$HF_TOKEN" $MODEL_NAME

# 8. Python スクリプトの作成
echo "🔹 Google Gemma 3 を実行するスクリプトを作成..."
cat <<EOF > run_gemma.py
import json
from transformers import AutoModelForCausalLM, AutoTokenizer
import torch

# モデル名
model_name = "$MODEL_NAME"

# トークナイザーとモデルのロード
tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModelForCausalLM.from_pretrained(model_name, torch_dtype=torch.float16, device_map="auto")

# 入力プロンプト
prompt = "こんにちは、自己紹介してください。"
inputs = tokenizer(prompt, return_tensors="pt").to("cuda")

# 応答の生成
output = model.generate(**inputs, max_length=100)
response_text = tokenizer.decode(output[0], skip_special_tokens=True)

# JSON 出力フォーマット
response_json = {
    "model": model_name,
    "prompt": prompt,
    "response": response_text
}

# 通常のテキスト出力
print("Gemmaの応答:", response_text)

# JSON 形式での出力
print(json.dumps(response_json, ensure_ascii=False, indent=4))
EOF

# 9. 実行テスト
echo "🔹 Google Gemma 3 の動作確認を開始..."
python run_gemma.py

# 仮想環境を終了
deactivate

echo "✅ Google Gemma 3 のセットアップが完了しました！"
echo "📌 仮想環境の場所: $PYTHON_ENV_DIR"
echo "🔹 仮想環境を有効化: source $PYTHON_ENV_DIR/bin/activate"
echo "🔹 実行: python run_gemma.py"
echo "🔹 終了: deactivate"
