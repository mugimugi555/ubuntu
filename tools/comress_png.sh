#!/bin/bash

# pngquant がインストールされているか確認
if ! command -v pngquant &> /dev/null; then
    echo "pngquant is not installed. Installing now..."

    # OS に応じたインストール（Debian系, macOS, Arch, Fedora）
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt &> /dev/null; then
            sudo apt update && sudo apt install -y pngquant
        elif command -v yum &> /dev/null; then
            sudo yum install -y pngquant
        elif command -v pacman &> /dev/null; then
            sudo pacman -Sy pngquant
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y pngquant
        else
            echo "Unsupported Linux distribution. Please install pngquant manually."
            exit 1
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew &> /dev/null; then
            brew install pngquant
        else
            echo "Homebrew is not installed. Please install Homebrew and rerun the script."
            exit 1
        fi
    else
        echo "Unsupported OS. Please install pngquant manually."
        exit 1
    fi
fi

echo "pngquant is installed."

# 圧縮対象のディレクトリ（デフォルト: カレントディレクトリ）
TARGET_DIR=${1:-.}

# 指定されたディレクトリ配下の全ての PNG ファイルを圧縮
find "$TARGET_DIR" -type f -name "*.png" | while read -r file; do
    echo "Compressing: $file"
    pngquant --quality=65-80 --speed 1 --ext .png --force "$file"
done

echo "Compression completed."
