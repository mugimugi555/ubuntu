#!/bin/bash

# ============================
# LoRA Training Shell Script
# venvで環境管理 + 画像リサイズ + LoRA学習 (日本ミラー & 並列ダウンロード対応)
# ============================

# 設定
BASE_DIR="dataset"  # 学習データのベースディレクトリ
OUTPUT_BASE="output/lora_model"  # 出力ディレクトリ
RESIZE_WIDTH=256  # 画像の幅
RESIZE_HEIGHT=256 # 画像の高さ
EPOCHS=10  # エポック数
BATCH_SIZE=1  # バッチサイズ
VENV_DIR="lora-venv"  # 仮想環境ディレクトリ
MODEL_PATH="pretrained_model"  # 事前学習済みモデルのパス
TRAIN_REPO_DIR="sd-scripts"  # Kohya’s SS をダウンロードするディレクトリ

# =====================
# 事前学習済みモデルの取得
# =====================
download_pretrained_model() {
    if [ ! -d "$MODEL_PATH" ]; then
        echo "🔹 事前学習済みモデルが見つかりません。Hugging Face からダウンロードします..."
        git clone https://huggingface.co/stable-diffusion-v1-5/stable-diffusion-v1-5 "$MODEL_PATH"
    else
        echo "✅ 事前学習済みモデルが既に存在します。"
    fi
}

# =====================
# 環境のセットアップ
# =====================
setup_environment() {
    echo "🔹 システムパッケージをチェック..."
    sudo apt update && sudo apt install -y python3 python3-venv python3-pip git imagemagick

    echo "🔹 仮想環境をセットアップ: $VENV_DIR"
    if [ ! -d "$VENV_DIR" ]; then
        python3 -m venv "$VENV_DIR"
    fi
    source "$VENV_DIR/bin/activate"

    echo "🔹 pip のミラーを一時的に適用してパッケージをインストール..."
    env PIP_INDEX_URL="https://pypi.ngc.nvidia.com/simple" \
        pip install --upgrade pip \
        pip install pipx \
        pip install uv \
        uv pip install \
            "numpy<1.25.0" scipy torch torchvision torchaudio tensorboard \
            tensorflow accelerate transformers datasets matplotlib imagesize

    echo "✅ 仮想環境のセットアップ完了！"
}

# =====================
# 学習スクリプトの取得
# =====================
setup_training_repo() {
    if [ ! -d "$TRAIN_REPO_DIR" ]; then
        echo "🔹 Kohya’s SS スクリプトが見つかりません。GitHubからクローンします..."
        git clone https://github.com/kohya-ss/sd-scripts.git "$TRAIN_REPO_DIR"
    else
        echo "✅ 学習スクリプトは既に存在します。最新の状態に更新します..."
        cd "$TRAIN_REPO_DIR" && git pull && cd ..
    fi
}

# =====================
# メイン処理
# =====================
main() {
    setup_environment
    setup_training_repo
    download_pretrained_model

    # データセットのチェック
    for TRAIN_NAME in "outfit" "face"; do
        TRAIN_DIR="$BASE_DIR/$TRAIN_NAME"
        if [ ! -d "$TRAIN_DIR" ]; then
            echo "データセットディレクトリが見つかりません: $TRAIN_DIR"
            echo "ディレクトリを作成します..."
            mkdir -p "$TRAIN_DIR"
            echo "学習に使用する画像を $TRAIN_DIR に配置してください。"
            exit
        fi
    done

    # 学習モードの選択
    echo "学習タイプを選択してください:"
    echo "1: 衣装 (Outfit Training)"
    echo "2: 顔 (Face Training)"
    echo "3: 衣装＋顔 (Outfit + Face Training)"
    read -p "選択（1, 2, 3）: " TRAIN_TYPE

    case "$TRAIN_TYPE" in
        1) TRAIN_NAME="outfit" ;;
        2) TRAIN_NAME="face" ;;
        3) TRAIN_NAME="outfit_face" ;;
        *)
            echo "無効な選択です。1, 2, または 3 を入力してください。"
            exit 1
            ;;
    esac

    # ディレクトリ設定
    if [ "$TRAIN_TYPE" == "3" ]; then
        TRAIN_DIR="$BASE_DIR/combined"
        mkdir -p "$TRAIN_DIR"
        cp "$BASE_DIR/outfit"/* "$TRAIN_DIR/" 2>/dev/null
        cp "$BASE_DIR/face"/* "$TRAIN_DIR/" 2>/dev/null
    else
        TRAIN_DIR="$BASE_DIR/$TRAIN_NAME"
    fi
    OUTPUT_DIR="${OUTPUT_BASE}_$TRAIN_NAME"

    # 画像リサイズ処理
    echo "🔹 画像を ${RESIZE_WIDTH}x${RESIZE_HEIGHT} にリサイズ中..."
    find "$TRAIN_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" \) -exec mogrify -resize ${RESIZE_WIDTH}x${RESIZE_HEIGHT}\! {} \;
    echo "✅ リサイズ完了！"

    # 顔の学習時に顔部分をクロップ
    if [ "$TRAIN_TYPE" == "2" ] || [ "$TRAIN_TYPE" == "3" ]; then
        echo "🔹 顔の学習のため、画像を顔部分にクロップします..."
        mkdir -p "$TRAIN_DIR/cropped"
        python3 face_crop.py --input_dir "$TRAIN_DIR" --output_dir "$TRAIN_DIR/cropped"
        TRAIN_DIR="$TRAIN_DIR/cropped"
        echo "✅ 顔のクロップ処理が完了しました！"
    fi

    # `dataset` のフルパスを取得
    ABSOLUTE_BASE_DIR="$(pwd)/$BASE_DIR"
    ABSOLUTE_OUTPUT_DIR="$(pwd)/$OUTPUT_DIR"

    # LoRA学習開始
    echo "🔹 LoRA学習開始..."
    export PYTORCH_CUDA_ALLOC_CONF="expandable_segments:True"

    accelerate launch --mixed_precision="bf16" "$TRAIN_REPO_DIR/train_network.py" \
        --pretrained_model_name_or_path="$MODEL_PATH" \
        --train_data_dir="$ABSOLUTE_BASE_DIR" \
        --output_dir="$ABSOLUTE_OUTPUT_DIR" \
        --resolution=256 \
        --train_batch_size=1 \
        --max_train_epochs=$EPOCHS \
        --learning_rate=5e-6 \
        --network_module=networks.lora

    echo "✅ 学習完了！モデルは $OUTPUT_DIR に保存されました。"

    # 仮想環境の解除
    deactivate
}

main
