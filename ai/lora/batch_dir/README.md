## 一括でLORA学習する方法

### 画像の準備

batch_dirに [学習用画像データ](https://drive.google.com/drive/folders/1oyR1-1H64l7Veyb5ybYUB0K9FTz7j5NN) からダウンロードした画像を配置します。

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

### 一括でLORA学習をする

```bash
bash batch_train_lora.sh
```
