#!/bin/bash

echo "🔹 必要なパッケージをインストール中..."
sudo apt update
sudo apt install -y curl git software-properties-common debconf-utils

# Ubuntu バージョンを取得
UBUNTU_VERSION=$(lsb_release -rs)
UBUNTU_CODENAME=$(lsb_release -cs)

# PPA に Ubuntu のバージョンが対応しているか確認する関数
check_ppa_support() {
    local ppa_url="http://ppa.launchpad.net/apt-fast/stable/ubuntu/dists/$1/"
    if curl --head --silent --fail "$ppa_url" > /dev/null; then
        return 0  # PPA が存在する場合
    else
        return 1  # PPA が存在しない場合
    fi
}

echo "🔹 Ubuntu $UBUNTU_VERSION ($UBUNTU_CODENAME) の PPA サポートを確認中..."

if check_ppa_support "$UBUNTU_CODENAME"; then
    echo "✅ PPA が Ubuntu $UBUNTU_VERSION に対応しています。"

    # PPA を追加し、apt-fast をインストール
    echo "📥 apt-fast を PPA からインストール中..."
    sudo add-apt-repository -y ppa:apt-fast/stable
    sudo apt update -y

    # ウィザードを無効化する設定
    echo "🔹 apt-fast のデフォルト設定を適用..."
    echo "apt-fast apt-fast/maxdownloads string 5" | sudo debconf-set-selections
    echo "apt-fast apt-fast/dlmanager string apt" | sudo debconf-set-selections

    sudo apt install -y apt-fast aria2

else
    echo "⚠️ PPA が Ubuntu $UBUNTU_VERSION ($UBUNTU_CODENAME) ではサポートされていません。"
    echo "🔹 GitHub からソースインストールを実行します..."

    # `apt-fast` を GitHub からダウンロード & インストール
    cd /usr/local/src
    sudo git clone https://github.com/ilikenwf/apt-fast.git
    cd apt-fast

    # `apt-fast` をシステムにインストール
    sudo install -m 755 apt-fast /usr/local/bin/
    sudo install -m 755 apt-fast.conf /etc/
    sudo install -m 755 man/apt-fast.8 /usr/share/man/man8/

    # シンボリックリンクを作成
    sudo ln -sf /usr/local/bin/apt-fast /usr/bin/apt-fast
fi

# `apt-fast` の設定ファイルを作成・更新
echo "🔹 apt-fast の設定を適用..."
cat <<EOF | sudo tee /etc/apt-fast.conf
# apt-fast 設定ファイル
# aria2 を使用し、ダウンロードを最大化

DOWNLOADBEFORE=true
_MAXNUM=16
_MIRRORS=2
_DL_RATE=0
MIRRORS=(
    "http://ftp.riken.jp/Linux/ubuntu/"
    "http://ftp.jaist.ac.jp/pub/Linux/ubuntu/"
    "http://ftp.tsukuba.wide.ad.jp/Linux/ubuntu/"
)
EOF

# `.bashrc` にエイリアスを追加（重複を防ぐ）
BASHRC_FILE="$HOME/.bashrc"
ALIAS_CMD="alias apt='function _apt() { case \"\$1\" in install|update|upgrade|dist-upgrade|full-upgrade) apt-fast \"\$@\";; *) command apt \"\$@\";; esac; }; _apt'"

if ! grep -q "alias apt=" "$BASHRC_FILE"; then
    echo "$ALIAS_CMD" >> "$BASHRC_FILE"
    echo "✅ .bashrc にエイリアスを追加しました。"
else
    echo "ℹ️ 既にエイリアスが設定されています。変更は不要です。"
fi

# エイリアスを即時適用
echo "🔄 エイリアスを適用中..."
source "$BASHRC_FILE"

echo "✅ apt-fast のインストール & apt の並列化が完了しました！"
echo "🔹 高速ダウンロードの例:"
echo "   sudo apt install <package-name>  # 自動的に apt-fast を使用"
echo "   sudo apt update && sudo apt upgrade"
