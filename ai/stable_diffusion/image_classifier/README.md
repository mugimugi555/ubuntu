# 🚀 画像分類ツール (Image Classifier) - インストール & 使用方法

## 📚 はじめに
このツールは、`deepdanbooru` と `CLIP` を活用して、
画像が **実写 (photo) かイラスト (illustration)** かを分類するための Python スクリプトです。

## 🔧 インストール方法
### **1. スクリプトをダウンロード & 実行**
```bash
chmod +x install_image_classifier.sh
./install_image_classifier.sh
```

このスクリプトは以下を自動で行います:
- 必要なパッケージのインストール (`python3`, `pip`, `pillow`, `webuiapi`)
- Python 仮想環境のセットアップ

### **2. Python 仮想環境の有効化**
```bash
source ~/image_classifier/venv/bin/activate
```

## 🎯 使用方法
### **1. 画像を分類する**
```bash
python ~/image_classifier/image_classifier.py path_to_your_image.jpg
```

このコマンドを実行すると、次のような JSON 形式の出力が得られます:
```json
{
    "image": "path_to_your_image.jpg",
    "classification": "illustration",  
    "clip_description": "a beautiful anime girl with long hair",  
    "deepdanbooru_tags": [
        "anime", "long hair", "beautiful", "blue eyes"
    ]
}
```

| **項目** | **説明** |
|----------|---------|
| `image` | 解析した画像のファイルパス |
| `classification` | `photo` (実写) または `illustration` (イラスト) |
| `clip_description` | CLIP による画像の説明文 |
| `deepdanbooru_tags` | deepdanbooru によるタグリスト |

### **2. Python 仮想環境を終了する**
```bash
deactivate
```

## 🔥 画像分類の仕組み
1. **CLIP による画像解析**
    - 画像の内容をテキストとして出力 (`clip_description`)
    - 説明文に `photo` や `illustration` が含まれているかを判定

2. **deepdanbooru によるタグ解析**
    - 画像に関連するタグを抽出 (`deepdanbooru_tags`)
    - タグの中に `photo`, `realistic` が含まれていれば **実写**
    - `anime`, `illustration`, `manga` などが含まれていれば **イラスト**

## 🛠 トラブルシューティング
**問題:** `image_classifier.py` 実行時にエラーが発生する

✅ **解決策:**
1. Python 仮想環境を再起動
   ```bash
   source ~/image_classifier/venv/bin/activate
   ```
2. `pip` のパッケージをアップグレード
   ```bash
   pip install --upgrade pip pillow webuiapi
   ```
3. 仮想環境を終了して再度試す
   ```bash
   deactivate
   ```
