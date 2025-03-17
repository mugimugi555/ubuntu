#!/bin/bash

set -e  # エラー時にスクリプトを停止

# === 設定 ===
PYTHON_ENV_DIR="$HOME/venvs/gemma3"
MODEL_NAME="google/gemma-3-12b-it"
CUDA_VERSION=""

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
sudo apt install -y python3 python3-venv python3-pip git curl

# 2. CUDA バージョンの取得
get_cuda_version

# 3. Python 仮想環境の作成
if [ ! -d "$PYTHON_ENV_DIR" ]; then
    echo "🔹 Python 仮想環境を作成中..."
    python3 -m venv "$PYTHON_ENV_DIR"
else
    echo "✅ 既に仮想環境が存在します: $PYTHON_ENV_DIR"
fi

# 仮想環境を有効化
source "$PYTHON_ENV_DIR/bin/activate"

# 4. 必要な Python ライブラリのインストール
echo "🔹 必要な Python ライブラリをインストール中..."
pip install --upgrade pip setuptools wheel
pip install torch torchvision torchaudio --index-url "https://download.pytorch.org/whl/$CUDA_VERSION"
pip install transformers huggingface_hub accelerate

# 5. Hugging Face のモデルをダウンロード
echo "🔹 Google Gemma 3 のモデルをダウンロード中..."
pip install "huggingface_hub[hf_transfer]"
HF_HUB_ENABLE_HF_TRANSFER=1 huggingface-cli download $MODEL_NAME

# 6. Python スクリプトの作成
echo "🔹 Google Gemma 3 を実行するスクリプトを作成..."
cat <<EOF > run_gemma.py
from transformers import AutoModelForCausalLM, AutoTokenizer
import torch

model_name = "$MODEL_NAME"
tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModelForCausalLM.from_pretrained(model_name, torch_dtype=torch.float16, device_map="auto")

prompt = "こんにちは、自己紹介してください。"
inputs = tokenizer(prompt, return_tensors="pt").to("cuda")

output = model.generate(**inputs, max_length=100)
response = tokenizer.decode(output[0], skip_special_tokens=True)

print("Gemmaの応答:", response)
EOF

# 7. 実行テスト
echo "🔹 Google Gemma 3 の動作確認を開始..."
python run_gemma.py

# 仮想環境を終了
deactivate

echo "✅ Google Gemma 3 のセットアップが完了しました！"
echo "📌 仮想環境の場所: $PYTHON_ENV_DIR"
echo "🔹 仮想環境を有効化: source $PYTHON_ENV_DIR/bin/activate"
echo "🔹 実行: python run_gemma.py"
echo "🔹 終了: deactivate"
