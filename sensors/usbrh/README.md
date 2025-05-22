![タイトル画像](readme/header.png)

# 📘 README: USB温湿度センサ（Strawberry Linux製 52002）セットアップガイド

本プロジェクトでは、Strawberry Linux 製の USB温湿度センサ（商品コード: **52002**）を使用し、Ubuntu上で `usbrh` プログラムをビルド・インストール・使用する手順をまとめています。

📦 製品ページ: [https://strawberry-linux.com/catalog/items?code=52002](https://strawberry-linux.com/catalog/items?code=52002)

---

## 🔧 動作環境

* Ubuntu 22.04 / 24.04 以降
* USBポート搭載PC
* インターネット接続

---

## 🚀 セットアップ手順

### 1. 必要なパッケージのインストール

```bash
sudo apt update
sudo apt install -y build-essential libusb-dev
```

### 2. ローカルファイルから usbrh をビルド

```bash
cd sensors/usbrh
make
```

### 3. 一般ユーザーでのアクセスを許可する（udevルール設定）

```bash
sudo nano /etc/udev/rules.d/99-usbrh.rules
```

次の1行を貼り付けて保存：

```
SUBSYSTEM=="usb", ATTR{idVendor}=="1774", ATTR{idProduct}=="1001", MODE="0666"
```

ルールの再読み込みと適用：

```bash
sudo udevadm control --reload
sudo udevadm trigger
```

> ⚠️ **USBセンサーを一度抜き差しして反映を確認してください。**

---

## 🧪 使用方法

### JSON出力（デフォルト）

```bash
./usbrh
```

出力例：

```json
{
  "timestamp": "2025-05-22T12:34:56+0900",
  "temperature": 24.18,
  "humidity": 52.45
}
```

### CSV出力（追記モード）

```bash
./usbrh -c -o data.csv
```

出力例（data.csv に追記）：

```
2025-05-22T12:34:56+0900,24.18,52.45
```

---

## ⚙️ 自動セットアップスクリプト（ローカルファイル前提）

`sensors/usbrh/install.sh` に以下の内容で保存して使用できます：

```bash
#!/bin/bash

# USBRH センサーのセットアップスクリプト（ローカルファイル使用）

set -e

echo "📦 必要なパッケージをインストール中..."
sudo apt update
sudo apt install -y libusb-dev build-essential

echo "🔨 ビルド実行中..."
cd "$(dirname "$0")"
make

echo "📜 udev ルールを設定中..."
UDEV_RULE_FILE="/etc/udev/rules.d/99-usbrh.rules"
RULE='SUBSYSTEM=="usb", ATTR{idVendor}=="1774", ATTR{idProduct}=="1001", MODE="0666"'
echo "$RULE" | sudo tee "$UDEV_RULE_FILE" > /dev/null

echo "🔁 udev をリロード・反映中..."
sudo udevadm control --reload
sudo udevadm trigger

echo "🔌 USB デバイスを一度抜いて再接続してください！"
echo "✅ セットアップ完了後、以下のコマンドで確認できます："
echo ""
echo "    ./usbrh"
echo ""

read -p "デバイスを接続済みなら Enter を押してください（./usbrh を実行）..."

./usbrh || echo "⚠️ 実行失敗（udevがまだ反映されていない可能性）"
```

---

## 🛠 トラブルシューティング

| 症状                                 | 解決策                                                                |
| ---------------------------------- | ------------------------------------------------------------------ |
| `usb.h: No such file or directory` | `libusb-dev` がインストールされていない → `sudo apt install libusb-dev`         |
| `Operation not permitted`          | `udev` ルール未設定 または 再接続していない                                         |
| `Permission denied`                | 一般ユーザーでのアクセス権が無い → `MODE="0666"` のルール設定を再確認                        |
| `venv/bin/python: No such file`    | Python仮想環境が壊れている → `rm -rf venv && python3.10 -m venv venv` などで再作成 |

---

## 📂 参考リポジトリ

* [https://github.com/osapon/usbrh-linux](https://github.com/osapon/usbrh-linux)

---

## 📝 製品仕様（抜粋）

| 項目    | 内容                    |
| ----- | --------------------- |
| 接続方法  | USB 1.1/2.0           |
| 測定範囲  | 温度 -40～+80℃、湿度 0～100% |
| センサ精度 | 温度 ±0.5℃、湿度 ±3.0%RH   |
| 出力形式  | JSON / CSV（コマンドライン）   |
| ドライバ  | 不要（Linuxで libusb 使用）  |

---
![タイトル画像](readme/header.png)