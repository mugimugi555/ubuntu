#!/bin/bash

#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 🧩 ChromeDriverのインストールとサービス設定スクリプト（日本語）
#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

#--------------------------------------------------
# 🔧 ChromeDriver のインストール先を指定
#--------------------------------------------------
CHROME_DRIVER_DIR="/usr/local/bin"

#--------------------------------------------------
# 📦 既存の ChromeDriver のバージョンを確認
#--------------------------------------------------
if [ ! -f "$CHROME_DRIVER_DIR/chromedriver" ]; then
  INSTALLED_DRIVER_VERSION="なし"
else
  INSTALLED_DRIVER_VERSION=$("$CHROME_DRIVER_DIR/chromedriver" --version | awk '{print $2}' | cut -d '.' -f1)
fi

echo "🕵️‍♂️ インストール済みの ChromeDriver バージョン: $INSTALLED_DRIVER_VERSION"

#--------------------------------------------------
# 🔍 現在の Google Chrome のバージョンを取得
#--------------------------------------------------
CHROME_VERSION=$(google-chrome --version | awk '{print $3}' | cut -d '.' -f1)
echo "🌐 現在の Chrome バージョン: $CHROME_VERSION"

#--------------------------------------------------
# 🔗 対応する ChromeDriver バージョンを取得
#--------------------------------------------------
API_URL="https://googlechromelabs.github.io/chrome-for-testing/latest-versions-per-milestone.json"
DRIVER_VERSION=$(curl -s "$API_URL" | jq -r --arg v "$CHROME_VERSION" '.milestones[$v].version')

if [ -z "$DRIVER_VERSION" ]; then
  echo "❌ Chrome バージョン $CHROME_VERSION に対応する ChromeDriver が見つかりませんでした。"
  exit 1
fi

echo "✅ 対応する ChromeDriver バージョン: $DRIVER_VERSION"

#--------------------------------------------------
# ⬇️ ChromeDriver のダウンロードとインストール
#--------------------------------------------------
if [ "$INSTALLED_DRIVER_VERSION" != "$CHROME_VERSION" ]; then
  echo "📥 ChromeDriver を更新します..."
  DRIVER_URL="https://storage.googleapis.com/chrome-for-testing-public/${DRIVER_VERSION}/linux64/chromedriver-linux64.zip"

  wget -O "/tmp/chromedriver.zip" "$DRIVER_URL"
  unzip -o "/tmp/chromedriver.zip" -d "/tmp/"
  sudo mkdir -p "$CHROME_DRIVER_DIR"
  sudo rm -f "$CHROME_DRIVER_DIR/chromedriver"
  sudo mv "/tmp/chromedriver-linux64/chromedriver" "$CHROME_DRIVER_DIR/chromedriver"
  sudo chmod +x "$CHROME_DRIVER_DIR/chromedriver"
  rm -rf "/tmp/chromedriver.zip" "/tmp/chromedriver-linux64"

  echo "🎉 ChromeDriver $DRIVER_VERSION を正常にインストールしました！"
else
  echo "🆗 ChromeDriver は最新です。更新は不要です。"
fi

#--------------------------------------------------
# 🛠️ systemd サービスファイルの作成
#--------------------------------------------------
SERVICE_NAME="chromedriver"
PORT="9515"
USER="www-data"
GROUP="www-data"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"

echo "🛠️ ChromeDriver 用の systemd サービスを作成中..."

sudo bash -c "cat > ${SERVICE_FILE}" <<EOF
[Unit]
Description=ChromeDriver Service
After=network.target

[Service]
ExecStart=${CHROME_DRIVER_DIR}/chromedriver --port=${PORT}
Restart=always
User=${USER}
Group=${GROUP}
Environment=DISPLAY=:0

[Install]
WantedBy=multi-user.target
EOF

#--------------------------------------------------
# 🚀 サービスを反映して起動
#--------------------------------------------------
echo "🚀 サービスを有効化して起動します..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable ${SERVICE_NAME}
sudo systemctl restart ${SERVICE_NAME}

#--------------------------------------------------
# 📋 サービスの状態を確認
#--------------------------------------------------
echo "📋 サービスのステータス:"
sudo systemctl status ${SERVICE_NAME} --no-pager
