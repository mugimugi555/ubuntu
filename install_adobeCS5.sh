#!/bin/bash

# インストール用の環境変数
INSTALLER_PATH="$HOME/Downloads/Adobe CS6/Set-up.exe"
WINEPREFIX="$HOME/.winecs6"
#WINEARCH="win32"
WINEARCH="win64"

#
echo "📌 既存の Wine を削除中..."
sudo apt remove --purge -y wine wine32 wine64 wine-stable wine-devel wine-staging winehq-stable winehq-devel winehq-staging winetricks fonts-wine
sudo rm -rf ~/.wine ~/.config/wine ~/.local/share/wine ~/.cache/winetricks
sudo apt autoremove -y

#
sudo dpkg --add-architecture i386
sudo mkdir -pm755 /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/$(lsb_release -cs)/winehq-$(lsb_release -cs).sources
sudo apt update
sudo apt install -y --install-recommends winehq-staging
sudo apt install  libgd3 libgd3:i386

#
echo "📌 Wine のインストール..."
sudo apt update
sudo apt install -y winetricks libfaudio0:i386

# Wine のバージョン確認
echo "✅ Wine のバージョン:"
wine --version

# Wine 64bit 環境の作成
echo "📌 Wine 64bit 環境をセットアップ..."
export WINEPREFIX=$WINEPREFIX
export WINEARCH=$WINEARCH
winecfg

# 必要なライブラリをインストール
echo "📌 Adobe CS5 に必要なランタイムをインストール..."
printf 'Y\n' | sudo winetricks --self-update
winetricks cjkfonts corefonts fakejapanese meiryo
WINEDEBUG=-all winetricks -q vcrun2005 vcrun2008 vcrun2010 atmlib gdiplus msxml6
cat <<EOF > wine-font-fix.reg
[HKEY_CURRENT_USER\Software\Wine\Fonts\Replacements]
"MS Shell Dlg"="MS Gothic"
"MS Shell Dlg 2"="MS Gothic"
EOF
wine regedit wine-font-fix.reg
fc-cache -fv
wineboot -r
wineserver -k && wineboot

# インストールファイルの存在チェック
if [ ! -f "$INSTALLER_PATH" ]; then
    echo "❌ Adobe CS5 のインストーラー ($INSTALLER_PATH) が見つかりません。"
    echo "📌 手動でダウンロードし、$HOME/Downloads に保存してください。"
    exit 1
fi

# Adobe CS5 のインストール
echo "📌 Adobe CS5 のインストーラーを起動します..."
wine "$INSTALLER_PATH"

# インストール後の実行ファイルのパスを取得
#ADOBE_DIR="$WINEPREFIX/drive_c/Program Files/Adobe"
#declare -A adobe_apps=(
#    ["photoshop"]="Adobe Photoshop CS5/Photoshop.exe"
#    ["photoshop"]="Adobe Photoshop CS5/Photoshop.exe"
#    ["illustrator"]="Adobe Illustrator CS5/Support Files/Contents/Windows/Illustrator.exe"
#    ["premiere"]="Adobe Premiere Pro CS5/Adobe Premiere Pro.exe"
#    ["aftereffects"]="Adobe After Effects CS5/Support Files/AfterFX.exe"
#)

#ADOBE_DIR="$WINEPREFIX/drive_c/Program Files \(x86\)/Adobe"
#declare -A adobe_apps=(
#    ["photoshop"]="Adobe Photoshop CS5/Photoshop.exe"
#    ["illustrator"]="Adobe Illustrator CS5/Support Files/Contents/Windows/Illustrator.exe"
#    ["premiere"]="Adobe Premiere Pro CS5/Adobe Premiere Pro.exe"
)

## 各アプリケーションのエイリアスを作成
#for app in "${!adobe_apps[@]}"; do
#    APP_PATH="$ADOBE_DIR/${adobe_apps[$app]}"
#    if [ -f "$APP_PATH" ]; then
#        echo "📌 $app のエイリアスを作成します..."
#        echo "alias $app='WINEPREFIX=$WINEPREFIX wine \"$APP_PATH\"'" >> ~/.bashrc
#    fi
#done

# 設定を反映
#source ~/.bashrc

echo "✅ Adobe CS5 のセットアップが完了しました！"
#echo "💡 ターミナルで 'photoshop', 'illustrator', 'premiere' などと入力すると起動できます。"
