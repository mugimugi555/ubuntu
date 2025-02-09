# Intel Xeon Phi (Knights Corner) 向け Ubuntu 環境構築ガイド

このリポジトリでは、Intel Xeon Phi（Knights Corner）向けの **Ubuntu 環境構築手順** を提供します。Python のインストール、OpenCV のビルド、YOLO（You Only Look Once）を使用した物体検出、ImageMagick の活用方法について解説しています。

---

## 📌 目次
- [前提条件](#前提条件)
- [Ubuntu のセットアップ](#ubuntu-のセットアップ)
- [必要なパッケージのインストール](#必要なパッケージのインストール)
- [Xeon Phi の認識と設定](#xeon-phi-の認識と設定)

---

## 📌 前提条件
Xeon Phi で Ubuntu を動作させる前に、以下の環境が必要です。

✅ **Intel Xeon Phi（Knights Corner）コプロセッサ**  
✅ **Ubuntu または類似の Linux 環境を実行できるホスト PC**  
✅ **基本的な Linux コマンドの知識**  
✅ **インターネット接続（パッケージのダウンロード用）**

---

## 📌 Ubuntu のセットアップ
1. **Ubuntu のイメージを Xeon Phi に書き込む**
   - Xeon Phi に対応した Ubuntu イメージを入手
   - USB またはネットワーク経由で Xeon Phi に書き込む

2. **Ubuntu の起動**
   - Xeon Phi を起動し、Ubuntu が動作することを確認

---

## 📌 必要なパッケージのインストール
以下のコマンドを実行して、必要なパッケージをインストールします。

```bash
sudo apt update
sudo apt install -y build-essential cmake git wget unzip pkg-config \
                    libjpeg-dev libpng-dev libtiff-dev libavcodec-dev \
                    libavformat-dev libswscale-dev libv4l-dev \
                    libxvidcore-dev libx264-dev libgtk-3-dev \
                    libatlas-base-dev gfortran python3-dev intel-mic-kmod intel-mic-tools
```

---

## 📌 Xeon Phi の認識と設定
### Xeon Phi が認識されているか確認
```bash
lspci | grep -i "co-processor"
```
✅ **Xeon Phi が認識されていれば表示されます。**

### Xeon Phi 用のドライバがロードされているか確認
```bash
lsmod | grep mic
```
✅ **`mic.ko` モジュールがロードされていれば OK**

### `mic0` が正しく作成されているか確認
```bash
ls /dev/mic*
```
✅ `/dev/mic0` が表示されていれば OK。

### SSH 接続確認
```bash
ssh mic0 "echo 'Xeon Phi に正常に接続できます。'"
```
✅ **接続成功なら OK。失敗した場合は `mic0` の IP 設定を確認**

---

## 📌 追加情報
詳細な手順やカスタマイズ方法については、各スクリプトのコメントをご確認ください。

Python スクリプトは `for_upload/` ディレクトリに格納し、シェルスクリプトから呼び出すことで、再利用しやすくなります。
