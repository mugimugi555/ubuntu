# 🧪 Wine 環境構築・Windowsアプリインストールスクリプト集

このリポジトリは、**Wine** を用いた Windows 環境の構築、および特定の Windows アプリケーション（Adobe CS, Kindle, MetaTrader 等）のインストールを自動化するシェルスクリプトを提供します。

## 📂 スクリプト一覧

| ファイル名                    | 内容                                                                 |
|-----------------------------|----------------------------------------------------------------------|
| `install_wine.sh`           | WineHQ 本体および必要なパッケージ・フォントのインストールスクリプト。Ubuntu に最適化。 |
| `install_wine_windows.sh`   | 任意の Windows バージョンに対応した仮想環境を作成（win7 / win10 など）。              |
| `install_wine_project.sh`   | プロジェクト名と Windows バージョンを選択し、Wine 仮想環境を構築。エイリアスも登録。   |
| `install_metatrader.sh`     | MetaTrader 4 または 5 を Wine 上にインストールし、起動エイリアスを追加。             |
| `install_adobe_cs.sh`       | Adobe CS4 / CS5 / CS6 のインストーラーを Wine で起動・環境構築（事前に入手が必要）。   |
| `install_kindle.sh`         | Kindle for PC を Wine 上にセットアップ。フォントやランタイムも自動導入。             |

---

## 🚀 使い方

### 1. Wine のインストール

```bash
bash install_wine.sh
```

### 2. プロジェクト別の仮想環境を作成

```bash
bash install_wine_project.sh
```

### 3. Wine仮想環境を Windows バージョン別に作成（例：win10）

```bash
bash install_wine_windows.sh
```

---

## 🛠 アプリ別セットアップ

| アプリ名       | コマンド例                          | 備考                                   |
|----------------|--------------------------------------|----------------------------------------|
| MetaTrader     | `bash install_metatrader.sh`         | MT4 または MT5 を選択してインストール |
| Kindle for PC  | `bash install_kindle.sh`             | 手動でインストーラーを用意            |
| Adobe CS4-6    | `bash install_adobe_cs.sh`           | `Set-up.exe` を手動で保存しておく     |

---

## 📎 補足

- `.bashrc` にエイリアスが自動で追加され、たとえば `mt5`, `kindle`, `photoshop` と入力するだけで環境が起動できます。
- すべての Wine 仮想環境は `$HOME/.wine-<アプリ名>` に作成されます。
- 各スクリプトは Ubuntu 22.04 (jammy) を想定していますが、他の LTS にも対応しています。

---

## 🧼 クリーンアップ

仮想環境を削除するには：

```bash
rm -rf ~/.wine-<アプリ名>
```

.bashrc のエイリアスを削除するには該当行を手動で削除してください。

---

## 📮 ライセンス

MIT License. スクリプトは自由に改変・再配布可能です。
