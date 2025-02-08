## 一括でフォルダを作成する方法（Linux/macOS）

batch_dirに
https://drive.google.com/drive/folders/1oyR1-1H64l7Veyb5ybYUB0K9FTz7j5NN
からダウンロードしたファイルを、フォルダ付きで画像を配置します。

```
batch_dir/
  ├── itako/*.jpg
  ├── kiritan/*.jpg
  ├── metan/*.jpg
  ├── sora/*.jpg
  ├── usagi/*.jpg
  ├── zundamon/*.jpg
  └── zunko/"*.jpg
```

一括でloraファイルの作成

```bash
bash batch_train_lora.sh
```
