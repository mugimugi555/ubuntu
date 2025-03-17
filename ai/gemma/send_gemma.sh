#!/bin/bash

# 使用する Python 仮想環境のパス
PYTHON_ENV_DIR="$HOME/venvs/gemma3"
PYTHON_SCRIPT="run_gemma.py"

# チェック: 仮想環境が存在しない場合、エラー
if [ ! -d "$PYTHON_ENV_DIR" ]; then
    echo "❌ 仮想環境が見つかりません: $PYTHON_ENV_DIR" >&2
    exit 1
fi

# チェック: Python スクリプトが存在するか
if [ ! -f "$PYTHON_SCRIPT" ]; then
    echo "❌ Python スクリプトが見つかりません: $PYTHON_SCRIPT" >&2
    exit 1
fi

# jq の確認＆インストール
if ! command -v jq &> /dev/null; then
    echo "🔹 jq がインストールされていません。インストールを開始します..."
    sudo apt update && sudo apt install -y jq
    if ! command -v jq &> /dev/null; then
        echo "❌ jq のインストールに失敗しました。JSON のまま表示します。" >&2
        exit 1
    fi
fi

# 引数でプロンプトを受け取る
if [ -z "$1" ]; then
    echo "💬 プロンプトを入力してください:"
    read PROMPT
else
    PROMPT="$@"
fi

# 仮想環境を有効化
source "$PYTHON_ENV_DIR/bin/activate"

# Gemma にプロンプトを送信し、JSON 形式で結果を取得
RESPONSE_JSON=$(echo "$PROMPT" | python "$PYTHON_SCRIPT" 2>/dev/null)

# 仮想環境を無効化
deactivate

# JSON のまま出力
echo "$RESPONSE_JSON"

# 応答部分だけを取得
RESPONSE_TEXT=$(echo "$RESPONSE_JSON" | jq -r '.response' 2>/dev/null)

if [ -z "$RESPONSE_TEXT" ] || [[ "$RESPONSE_TEXT" == "null" ]]; then
    echo "⚠️ 応答が取得できませんでした。エラーの可能性があります。" >&2
    exit 1
fi

echo "📝 AIの応答: $RESPONSE_TEXT"
