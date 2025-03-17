#!/bin/bash

# 使用する Python 仮想環境のパス
PYTHON_ENV_DIR="$HOME/venvs/gemma3"

# チェック: 仮想環境が存在しない場合、エラー
if [ ! -d "$PYTHON_ENV_DIR" ]; then
    echo "❌ 仮想環境が見つかりません: $PYTHON_ENV_DIR"
    exit 1
fi

# チェック: 引数がない場合、プロンプトを求める
if [ -z "$1" ]; then
    echo "💬 プロンプトを入力してください:"
    read PROMPT
else
    PROMPT="$1"
fi

# 仮想環境を有効化
source "$PYTHON_ENV_DIR/bin/activate"

# Gemma にプロンプトを送信し、JSON 形式で結果を取得
RESPONSE_JSON=$(echo "$PROMPT" | python run_gemma.py)

# 仮想環境を無効化
deactivate

# JSON のまま出力
echo "$RESPONSE_JSON"

# 応答部分だけを取得 (jq を使用)
RESPONSE_TEXT=$(echo "$RESPONSE_JSON" | jq -r '.response')
echo "📝 AIの応答: $RESPONSE_TEXT"
