#!/bin/bash

set -e  # エラーが発生したらスクリプトを停止

echo "🔹 Coral Edge TPU を Ubuntu 22.04 にセットアップします..."

# === 1. 必要なパッケージのインストール ===
echo "🔹 必要なパッケージをインストール中..."
sudo apt update
sudo apt install -y curl wget unzip python3-pip python3-venv

# === 2. TPU の種類を選択 ===
echo "🔹 使用する Coral TPU の種類を選択してください。"
echo "1) USB Accelerator"
echo "2) PCIe / M.2 TPU"
read -p "選択してください (1 または 2): " TPU_TYPE

if [ "$TPU_TYPE" == "1" ]; then
    echo "🔹 USB Accelerator を選択しました。"
    sudo apt install -y libedgetpu1-std
elif [ "$TPU_TYPE" == "2" ]; then
    echo "🔹 PCIe / M.2 TPU を選択しました。"
    sudo apt install -y gasket-dkms libedgetpu1-std
else
    echo "❌ 無効な選択肢です。1 または 2 を入力してください。"
    exit 1
fi

# === 3. Edge TPU Runtime のインストール ===
echo "🔹 Edge TPU Runtime をインストール中..."
mkdir -p ~/coral
cd ~/coral
wget https://packages.cloud.google.com/apt/pool/edge-tpu-std_15.0_arm64.deb
sudo dpkg -i edge-tpu-std_15.0_arm64.deb

# === 4. Edge TPU Python API のインストール ===
echo "🔹 Edge TPU Python API をインストール中..."
pip3 install --upgrade pip
pip3 install tflite-runtime
pip3 install pycoral

# === 5. TPU の動作確認 ===
echo "🔹 Coral TPU の認識を確認中..."
if [ "$TPU_TYPE" == "1" ]; then
    lsusb | grep Google || echo "⚠️ USB TPU が認識されていません！"
else
    lspci | grep Google || echo "⚠️ PCIe TPU が認識されていません！"
fi

echo "🔹 TPU を使ったテスト推論を実行..."
python3 -c "from pycoral.utils.edgetpu import list_edge_tpus; print(list_edge_tpus())"

echo "✅ Coral Edge TPU のセットアップが完了しました！"
echo "🚀 TPU が正しく認識されているか確認してください。"
