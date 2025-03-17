# Google Gemma 3 シリーズ セットアップ & 実行

![タイトル画像](readme/header.png)

## 🚀 はじめに
このリポジトリでは、Google Gemma 3 シリーズのモデルをローカル環境で実行するためのスクリプトを提供します。

### ⚠️ 重要: Hugging Face での認証が必要
Gemma 3 シリーズのモデルを使用するには、**Hugging Face のアクセストークン（READ 権限）** に加えて、**モデルページでの利用規約（アグリメント）に同意** する必要があります。

#### **1. Hugging Face アクセストークンの取得**
1. [Hugging Face トークン設定ページ](https://huggingface.co/settings/tokens) にアクセス
2. `Access Token (READ)` を新規作成
3. `HF_TOKEN` としてスクリプトで設定

#### **2. モデル利用規約（アグリメント）に同意**
各モデルのページにアクセスし、`Access Repository` ボタンをクリックして規約に同意してください。
- [Gemma 3-1B (it)](https://huggingface.co/google/gemma-3-1b-it)
- [Gemma 3-4B (it)](https://huggingface.co/google/gemma-3-4b-it)
- [Gemma 3-12B (it)](https://huggingface.co/google/gemma-3-12b-it)
- [Gemma 3-27B (it)](https://huggingface.co/google/gemma-3-27b-it)

## 📦 セットアップ手順
### **1. 事前準備（CUDA & Python）**
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y python3 python3-venv python3-pip git curl jq
```
CUDA を使用する場合、NVIDIA ドライバがインストールされていることを確認してください。

### **2. Gemma 3 のインストール**
```bash
bash install_gemma3.sh
```
このスクリプトは以下を行います:
- Hugging Face へのログイン（API トークン設定）
- Python 仮想環境の作成
- 必要なライブラリのインストール
- ダウンロード済みのモデルを検出し、最適なものを自動選択

## 🤖 Gemma 3 の実行方法

### **1. AI にプロンプトを送信**
```bash
bash send_gemma.sh "こんにちは、自己紹介してください。"
```
（シェルスクリプトを通じて Gemma にテキストを送信し、JSON 形式でレスポンスを取得できます）

### **2. Python スクリプトを直接実行**
```bash
source ~/venvs/gemma3/bin/activate
python run_gemma.py
```

## 🔧 設定変更

### **環境変数で使用するモデルを変更**
デフォルトではダウンロード済みの最適なモデルを自動選択しますが、特定のモデルを指定したい場合は以下のように設定できます。
```bash
export MODEL_NAME="google/gemma-3-4b-it"
bash send_gemma.sh "AIとは？"
```

## 📌 参考情報

### **対応 GPU & 必要 VRAM**
| モデル名                 | パラメータ数 | 必要 VRAM (推定) | 推奨 GPU |
|-------------------------|------------|----------------|----------|
| google/gemma-3-1b-it   | 1B         | 約 4GB        | RTX 3050 以上 |
| google/gemma-3-4b-it   | 4B         | 約 8GB        | RTX 3060 以上 |
| google/gemma-3-12b-it  | 12B        | 約 16GB       | RTX 3090 / A6000 |
| google/gemma-3-27b-it  | 27B        | 約 48GB       | A100 / H100 |

VRAM が不足する場合、量子化（4bit, 8bit）を検討してください。

## 🛠 トラブルシューティング

### **1. `403 Forbidden` エラーが発生する**
→ モデルの利用規約（アグリメント）に同意しているか確認してください。

### **2. `huggingface-cli login` でエラーが発生する**
→ `HF_TOKEN` を正しく設定し、再ログインしてください。
```bash
echo -n "your_huggingface_token" > ~/.cache/huggingface/token
huggingface-cli login --token your_huggingface_token
```

### **3. `CUDA out of memory` エラーが発生する**
→ モデルの VRAM 要件を満たしていない可能性があります。小さいモデルを試すか、量子化を行ってください。

## 📜 ライセンス
このプロジェクトは **MIT License** の下で提供されます。

![タイトル画像](readme/footer.png)
