#!/bin/bash

# GNOMEのカスタムキー設定ベースパス
BASE="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings"

# 既存リストを取得
existing=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings)

echo "既存設定: $existing"

# 新しく作りたいもの
entries=""

for N in {1..4}; do
  ENTRY="$BASE/custom$N/"
  entries="$entries, '$ENTRY'"
done

# 先頭の , を除去
entries="[${entries#,}]"

echo "新しいエントリリスト: $entries"

# セット
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "$entries"

# 各カスタムショートカットを設定
for N in {1..4}; do
  ENTRY="$BASE/custom$N/"
  INDEX=$((N - 1))
  KEYBINDING="<Primary><Alt>$N"
  COMMAND="wmctrl -s $INDEX"
  NAME="Switch to Workspace $N"

  echo "設定: $ENTRY $NAME $COMMAND $KEYBINDING"

  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$ENTRY name "$NAME"
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$ENTRY command "$COMMAND"
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$ENTRY binding "$KEYBINDING"
done

echo "✅ カスタムショートカット設定完了"
