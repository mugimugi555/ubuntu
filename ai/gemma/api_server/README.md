# 🚀 Google Gemma 3 API セットアップ & 使用方法

![タイトル画像](readme/header.png)

## 📚 はじめに
このリポジトリでは、Google Gemma 3 シリーズの言語モデルを **FastAPI + CUDA 最適化** でローカル環境に API サーバーとしてデプロイする方法を提供します。

## 🔒 重要: Hugging Face の認証
Google Gemma 3 シリーズのモデルを使用するには、**Hugging Face の API トークン（READ 権限）** に加えて、**モデルページでの利用規約（アグリメント）への同意** が必要です。

### **1. Hugging Face アクセストークンを取得**
1. [Hugging Face トークン設定ページ](https://huggingface.co/settings/tokens) にアクセス
2. `Access Token (READ)` を新規作成
3. 環境変数 `HF_TOKEN` に設定

### **2. モデル利用規約（アグリメント）に同意**
以下のモデルページにアクセスし、`Access Repository` ボタンをクリックしてください。

- [Gemma 3-1B (it)](https://huggingface.co/google/gemma-3-1b-it)
- [Gemma 3-4B (it)](https://huggingface.co/google/gemma-3-4b-it)
- [Gemma 3-12B (it)](https://huggingface.co/google/gemma-3-12b-it)
- [Gemma 3-27B (it)](https://huggingface.co/google/gemma-3-27b-it)

## 🛠 インストール手順
### **1. API サーバーのインストール**
```bash
chmod +x install_gemma_api.sh
./install_gemma_api.sh
```
このスクリプトは以下を自動で実行します:
- 必要なパッケージのインストール (`python3`, `pip`, `FastAPI`, `Torch`, `Transformers` など)
- CUDA バージョンを自動判定し、適切な `torch` をインストール
- `systemd` を利用した **自動起動 API サーバー** のセットアップ

### **2. API のステータス確認**
```bash
sudo systemctl status gemma_api
```

## 🌍 API の使用方法
### **1. API ステータス確認**
```bash
curl -X GET "http://localhost:8000/"
```

### **2. AI にプロンプトを送信**
```bash
curl -X POST "http://localhost:8000/generate" -H "Content-Type: application/json" -d '{"prompt": "こんにちは、自己紹介してください。"}'
```

## 🌐 VRAM 必要要件
| モデル名                 | パラメータ数 | 必要 VRAM (推定) | 推奨 GPU |
|-------------------------|------------|----------------|----------|
| google/gemma-3-1b-it   | 1B         | 約 4GB        | RTX 3050 以上 |
| google/gemma-3-4b-it   | 4B         | 約 8GB        | RTX 3060 以上 |
| google/gemma-3-12b-it  | 12B        | 約 16GB       | RTX 3090 / A6000 |
| google/gemma-3-27b-it  | 27B        | 約 48GB       | A100 / H100 |

![タイトル画像](readme/footer.png)
