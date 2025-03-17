#!/bin/bash

set -e  # エラー時にスクリプトを停止

# ======================================================
# Google Gemma 3シリーズ対応GPU & 必要VRAM一覧
# ======================================================
# | モデル名               | パラメータ数 | 必要VRAM (推定) | 推奨GPU            |
# |------------------------|-------------|----------------|--------------------|
# | google/gemma-3-1b-it   | 1B          | 約 4GB         | RTX 3050 以上      |
# | google/gemma-3-4b-it   | 4B          | 約 8GB         | RTX 3060 以上      |
# | google/gemma-3-12b-it  | 12B         | 約 16GB        | RTX 3090 / A6000  |
# | google/gemma-3-27b-it  | 27B         | 約 48GB        | A100 / H100       |
#
#  💡 VRAMが足りない場合は 4bit 量子化(QLoRA)などを検討してください。
# ======================================================

# === 設定 ===
PYTHON_ENV_DIR="$HOME/venvs/gemma3"
MODEL_NAME="google/gemma-3-12b-it"
CUDA_VERSION=""
REQUIRED_VRAM_GB=16  # 選択モデルの推定VRAM要件（float16）

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

# === VRAM 要件チェック ===
check_vram() {
    echo "🔹 GPU の VRAM 容量を取得中..."
    AVAILABLE_VRAM_GB=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits | awk '{print $1/1024}' | sort -nr | head -n1)
    
    if (( $(echo "$AVAILABLE_VRAM_GB < $REQUIRED_VRAM_GB" | bc -l) )); then
        echo "⚠️ 警告: このモデルには少なくとも ${REQUIRED_VRAM_GB}GB の VRAM が必要ですが、現在の VRAM は ${AVAILABLE_VRAM_GB}GB です。"
        echo "💡 モデルの量子化（8bit, 4bit）を検討してください。"
    else
        echo "✅ 必要な VRAM 容量が確保されています。（${AVAILABLE_VRAM_GB}GB）"
    fi
}

echo "🔹 Google Gemma 3 のセットアップを開始します..."

# 1. 必要なパッケージのインストール
echo "🔹 必要なパッケージをインストール中..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y python3 python3-venv python3-pip git curl bc

# 2. CUDA バージョンの取得
get_cuda_version

# 3. VRAM の確認
check_vram

# 4. Python 仮想環境の作成
if [ ! -d "$PYTHON_ENV_DIR" ]; then
    echo "🔹 Python 仮想環境を作成中..."
    python3 -m venv "$PYTHON_ENV_DIR"
else
    echo "✅ 既に仮想環境が存在します: $PYTHON_ENV_DIR"
fi

# 仮想環境を有効化
source "$PYTHON_ENV_DIR/bin/activate"

# 5. 必要な Python ライブラリのインストール
echo "🔹 必要な Python ライブラリをインストール中..."
pip install --upgrade pip setuptools wheel
pip install torch torchvision torchaudio --index-url "https://download.pytorch.org/whl/$CUDA_VERSION"
pip install transformers huggingface_hub accelerate

# 6. Hugging Face のモデルをダウンロード
echo "🔹 Google Gemma 3 のモデルをダウンロード中..."
pip install "huggingface_hub[hf_transfer]"
HF_HUB_ENABLE_HF_TRANSFER=1 huggingface-cli download $MODEL_NAME

# 7. Python スクリプトの作成
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

# 8. 実行テスト
echo "🔹 Google Gemma 3 の動作確認を開始..."
python run_gemma.py

# 仮想環境を終了
deactivate

echo "✅ Google Gemma 3 のセットアップが完了しました！"
echo "📌 仮想環境の場所: $PYTHON_ENV_DIR"
echo "🔹 仮想環境を有効化: source $PYTHON_ENV_DIR/bin/activate"
echo "🔹 実行: python run_gemma.py"
echo "🔹 終了: deactivate"
