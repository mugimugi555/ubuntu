#!/bin/bash
set -e

echo "🛠 No-IP Dynamic DNS クライアント (DUC) のセットアップを開始します..."

# === アカウント情報の入力または誘導 ===
read -p "🔑 No-IP アカウントをお持ちですか？ (y/N): " has_account
if [[ ! "$has_account" =~ ^[Yy]$ ]]; then
    echo "🌐 No-IP アカウント作成ページを開こうとしています..."

    if ! xdg-open "https://www.noip.com/sign-up" >/dev/null 2>&1; then
        echo "⚠️ GUI 環境がないためブラウザを開けませんでした。以下の URL をブラウザで開いてアカウントを作成してください:"
        echo "🔗 https://www.noip.com/sign-up"
    fi

    echo "✅ アカウント作成後、再度このスクリプトを実行してください。"
    exit 1
fi

# === 依存関係のインストール ===
echo "🔹 ビルドに必要なパッケージをインストールします..."
sudo apt update
sudo apt install -y build-essential libssl-dev wget tar

# === ダウンロード & 解凍 ===
WORKDIR="$HOME/.noip"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

echo "🔽 No-IP クライアントをダウンロードしています..."
wget -O noip.tar.gz https://www.no-ip.com/client/linux/noip-duc-linux.tar.gz

echo "📦 解凍中..."
tar xf noip.tar.gz
cd noip-*

# === make & インストール ===
echo "🔧 make を実行中..."
make
echo "🧾 No-IP クライアント初期設定 (アカウント情報などを入力してください)..."
sudo make install

# === アカウント情報を手動入力して設定 ===
#echo "🧾 No-IP クライアント初期設定 (アカウント情報などを入力してください)..."
#sudo /usr/local/bin/noip2 -C

# === 自動起動スクリプトの作成 ===
echo "📝 systemd サービスを作成しています..."
sudo tee /etc/systemd/system/noip2.service > /dev/null <<EOF
[Unit]
Description=No-IP Dynamic DNS Update Client
After=network.target

[Service]
ExecStart=/usr/local/bin/noip2
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable --now noip2

echo "✅ No-IP クライアントのインストールと自動起動設定が完了しました！"
echo "🔄 現在のIPアドレスは自動的にNo-IPへ更新されます。"
