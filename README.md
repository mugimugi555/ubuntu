# Ubuntu Setup Scripts

![タイトル画像](assets/images/header.png)

このリポジトリは、Ubuntu環境のセットアップや各種ソフトウェアのインストールを自動化するシェルスクリプトを集めたものです。
各スクリプトは特定の目的に対応しており、必要なものを選択して使用できます。

## 目次

- [使用方法](#使用方法)
- [含まれるスクリプト](#含まれるスクリプト)
- [注意事項](#注意事項)
- [ライセンス](#ライセンス)

## 使用方法

1. **リポジトリのクローン**
   ```sh
   git clone https://github.com/mugimugi555/ubuntu.git
   cd ubuntu
   ```

2. **スクリプトの実行**
   ```sh
   chmod +x script_name.sh
   ./script_name.sh
   ```
   *`script_name.sh` は実行したいスクリプトの名前に置き換えてください。*

## 含まれるスクリプト

- `install.sh` - 基本的なセットアップ
- `install_adobeCS.sh` - Adobe Creative Suite のインストール
- `install_chrome_remotedesktop.sh` - Chrome リモートデスクトップのセットアップ
- `install_chromedriver.sh` - ChromeDriver のインストール
- `install_composer.sh` - PHP Composer のインストール
- `install_crystaldiskmark.sh` - CrystalDiskMark のインストール
- `install_lamp.sh` - LAMP 環境（Linux, Apache, MySQL, PHP）のセットアップ
- `install_laravel.sh` - Laravel のインストール
- `install_mysql_benchmark.sh` - MySQL のベンチマークテスト
- `install_nodejs.sh` - Node.js のインストール
- `install_openapi.sh` - OpenAPI 関連ツールのセットアップ
- `install_opencv.sh` - OpenCV のインストール
- `install_openvino.sh` - OpenVINO のインストール
- `install_phoenix.sh` - Phoenix（Elixir フレームワーク）のインストール
- `install_photoshop.sh` - Photoshop のインストール
- `install_power_save.sh` - 省電力設定
- `install_printer.sh` - プリンタのセットアップ
- `install_sas_hpa.sh` - SAS HPA のインストール
- `install_swapfile.sh` - スワップファイルの作成
- `install_tv.sh` - テレビ視聴関連のソフトウェアインストール
- `install_ubuntu22.sh` - Ubuntu 22.04 のセットアップ
- `install_us_jis_keyboard.sh` - US配列キーボードをJIS配列として設定

*各スクリプトの詳細については、スクリプト内のコメントを参照してください。*

## 注意事項

- **実行前の確認**: スクリプトの内容を確認し、必要に応じて編集してください。
- **権限**: 一部のスクリプトは管理者権限（sudo）が必要です。
- **互換性**: スクリプトは特定の Ubuntu バージョンや環境に依存する場合があります。

## ライセンス

このリポジトリの内容は、特に明記がない限り、MIT ライセンスの下で提供されています。
詳細は [LICENSE](LICENSE) ファイルをご確認ください。

![タイトル画像](assets/images/footer.png)
