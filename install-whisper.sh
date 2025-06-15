#!/bin/bash

#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Whisper 自動インストールスクリプト（Ubuntu 24.04）
# 仮想環境 + エイリアス登録
#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e

WHISPER_DIR="$HOME/.local/whisper"
VENV_DIR="$WHISPER_DIR/whisper-env"
ALIAS_FILE="$HOME/.bashrc"  # または ~/.zshrc を使う場合は適宜変更

echo "▶ 必要なパッケージをインストール中..."
sudo apt update
sudo apt install -y python3-venv ffmpeg

echo "▶ Whisper用のディレクトリを作成: $WHISPER_DIR"
mkdir -p "$WHISPER_DIR"
cd "$WHISPER_DIR"

echo "▶ 仮想環境を作成中..."
python3 -m venv whisper-env
source "$VENV_DIR/bin/activate"

echo "▶ pipとWhisperをインストール中..."
pip install --upgrade pip
pip install git+https://github.com/openai/whisper.git

# aliasの設定を.bashrcなどに追加（既存確認つき）
if ! grep -q 'alias whisper=' "$ALIAS_FILE"; then
  echo "▶ エイリアスを $ALIAS_FILE に追加中..."
  {
    echo ''
    echo '# Whisper alias'
    echo "alias whisper='$VENV_DIR/bin/whisper'"
  } >> "$ALIAS_FILE"
else
  echo "ℹ️  すでに alias whisper が設定されています"
fi

echo "✅ Whisperのインストールとエイリアス設定が完了しました！"
echo "🔁 新しいターミナルを開くか、次を実行してから使ってください:"
echo ""
echo "  source $ALIAS_FILE"
echo ""
echo "📝 使用例:"
echo "  whisper input.mp4 --language Japanese --model medium"
