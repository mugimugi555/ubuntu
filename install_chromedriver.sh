#!/bin/bash

# ================================
# ChromeDriver 自動インストール & 管理スクリプト
# ================================
# このスクリプトを実行すると ChromeDriver の自動インストールと PM2 での管理を行います。
# 1 日 1 回の自動更新を cron に登録します。
#
# ワンライナーでインストールする場合:
# wget https://raw.githubusercontent.com/mugimugi555/ubuntu/main/install_chromedriver.sh && bash install_chromedriver.sh
# ================================

# ================================
# 設定
# ================================
CHROME_DRIVER_DIR="$HOME/cmd/chromedriver"
SCRIPT_NAME="install_chromedriver.sh"
CHROME_DRIVER_PORT=5001

# ================================
# npmとpm2がインストールされているか確認
# ================================
if ! command -v npm &> /dev/null; then
  echo "npm is not installed. Please install it using: sudo apt install npm"
  exit 1
fi

if ! command -v pm2 &> /dev/null; then
  echo "PM2 is not installed. Please install it using: sudo npm install -g pm2"
  exit 1
fi

# ================================
# ChromeDriver が存在するか確認し、なければダウンロードを強制
# ================================
if [ ! -f "$CHROME_DRIVER_DIR/chromedriver" ]; then
  INSTALLED_DRIVER_VERSION="none"
else
  INSTALLED_DRIVER_VERSION=$("$CHROME_DRIVER_DIR/chromedriver" --version | awk '{print $2}' | cut -d '.' -f1)
fi

echo "Installed ChromeDriver version: $INSTALLED_DRIVER_VERSION"

# ================================
# 現在の Chrome のバージョンを取得
# ================================
CHROME_VERSION=$(google-chrome --version | awk '{print $3}' | cut -d '.' -f1)
echo "Current Chrome version: $CHROME_VERSION"

# ================================
# ChromeDriver の適合バージョンを取得
# ================================
API_URL="https://googlechromelabs.github.io/chrome-for-testing/latest-versions-per-milestone.json"
DRIVER_VERSION=$(curl -s "$API_URL" | jq -r --arg v "$CHROME_VERSION" '.milestones[$v].version')

if [ -z "$DRIVER_VERSION" ]; then
  echo "No matching ChromeDriver found for Chrome version $CHROME_VERSION"
  exit 1
fi

echo "Matching ChromeDriver version: $DRIVER_VERSION"

# ================================
# 既存の ChromeDriver のバージョンと比較し、差異がある場合のみダウンロード
# ================================
if [ "$INSTALLED_DRIVER_VERSION" != "$CHROME_VERSION" ]; then
  echo "Updating ChromeDriver..."
  DRIVER_URL="https://storage.googleapis.com/chrome-for-testing-public/${DRIVER_VERSION}/linux64/chromedriver-linux64.zip"
  
  wget -O "/tmp/chromedriver.zip" "$DRIVER_URL"
  unzip -o "/tmp/chromedriver.zip" -d "/tmp/"
  mkdir -p "$CHROME_DRIVER_DIR"
  rm -f "$CHROME_DRIVER_DIR/chromedriver"
  mv "/tmp/chromedriver-linux64/chromedriver" "$CHROME_DRIVER_DIR/chromedriver"
  chmod +x "$CHROME_DRIVER_DIR/chromedriver"
  rm "/tmp/chromedriver.zip"
  
  echo "ChromeDriver $DRIVER_VERSION installed successfully!"
else
  echo "ChromeDriver is up-to-date. No update needed."
fi

# ================================
# PM2 に登録（存在しない場合は追加）
# ================================
if ! pm2 list | grep -q "chromedriver"; then
  pm2 start "$CHROME_DRIVER_DIR/chromedriver" --name "chromedriver" -- --port=$CHROME_DRIVER_PORT
  pm2 save
  pm2 startup
else
  pm2 restart "chromedriver"
fi

pm2 list
pm2 save --force

if ! pm2 list | grep -q "chromedriver"; then
  echo "Process not found, re-registering with PM2"
  pm2 start "$CHROME_DRIVER_DIR/chromedriver" --name "chromedriver" -- --port=$CHROME_DRIVER_PORT
  pm2 save
fi

# ================================
# ChromeDriver が正常に起動しているか確認
# ================================
curl -s http://localhost:$CHROME_DRIVER_PORT/status | jq || echo "ChromeDriver failed to start, please check logs."

# ================================
# crontab に 1 日 1 回の実行を追加
# ================================
CURRENT_CRON=$(crontab -l 2>/dev/null)
if echo "$CURRENT_CRON" | grep -q "$CHROME_DRIVER_DIR/$SCRIPT_NAME"; then
  echo "Cron job already exists. No changes made."
else
  (echo "$CURRENT_CRON"; echo "0 3 * * * $CHROME_DRIVER_DIR/$SCRIPT_NAME > $HOME/chromedriver_update.log 2>&1") | crontab -
  echo "Cron job added to run daily at 3:00 AM."
fi
