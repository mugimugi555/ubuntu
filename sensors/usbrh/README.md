# README.md

## 📘 README: USB温湿度センサ（Strawberry Linux製 52002）セットアップガイド

本プロジェクトでは、Strawberry Linux 製の USB温湿度センサ（商品コード: **52002**）を使用し、Ubuntu上で `usbrh` プログラムをビルド・インストール・使用する手順をまとめています。

📦 製品ページ: [https://strawberry-linux.com/catalog/items?code=52002](https://strawberry-linux.com/catalog/items?code=52002)

---

## 🔧 動作環境

- Ubuntu 22.04 / 24.04 以降
- USBポート搭載PC
- インターネット接続

---

## 🚀 セットアップ手順

### 1. 必要なパッケージのインストール

```bash
sudo apt update
sudo apt install -y git build-essential libusb-dev
```

### 2. usbrh ドライバのクローンとビルド

```bash
git clone https://github.com/osapon/usbrh-linux.git
cd usbrh-linux
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

```bash
cd usbrh-linux
./usbrh
```

出力例：

```
Temperature = 24.18 degC
Humidity    = 52.45 %
```

---

## 🛠 トラブルシューティング

| 症状 | 解決策 |
|------|--------|
| `usb.h: No such file or directory` | `libusb-dev` がインストールされていない → `sudo apt install libusb-dev` |
| `Operation not permitted` | `udev` ルール未設定 または 再接続していない |
| `Permission denied` | 一般ユーザーでのアクセス権が無い → `MODE="0666"` のルール設定を再確認 |

---

## 📂 参考リポジトリ

- [https://github.com/osapon/usbrh-linux](https://github.com/osapon/usbrh-linux)

---

## 📝 製品仕様（抜粋）

| 項目          | 内容                   |
|---------------|------------------------|
| 接続方法      | USB 1.1/2.0            |
| 測定範囲      | 温度 -40～+80℃、湿度 0～100% |
| センサ精度    | 温度 ±0.5℃、湿度 ±3.0%RH |
| 出力形式      | ASCII テキスト（コマンドライン） |
| ドライバ      | 不要（Linuxで libusb 使用） |

---
