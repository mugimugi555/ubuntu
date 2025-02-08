## 一括でLORA学習する方法

### 画像の準備

batch_dirに [学習用画像データ](https://drive.google.com/drive/folders/1oyR1-1H64l7Veyb5ybYUB0K9FTz7j5NN) からダウンロードした画像を配置します。

```
batch_dir/
  ├── itako/*.png
  ├── kiritan/*.png
  ├── metan/*.png
  ├── sora/*.png
  ├── usagi/*.png
  ├── zundamon/*.png
  └── zunko/*.png
```

### 一括でLORA学習をする

```bash
bash batch_train_lora.sh
```
