#!/bin/bash

echo "=== Xeon Phi のシステム情報を取得 & 必要なパッケージをインストール ==="

### 1️⃣ Xeon Phi が Ubuntu に認識されているか確認 ###
echo "=== Xeon Phi のデバイス確認 ==="
if ! lspci | grep -i "co-processor"; then
    echo "⚠ Xeon Phi が認識されていません。PCIe 接続を確認してください。"
    exit 1
else
    echo "✅ Xeon Phi が認識されています。"
fi

### 2️⃣ Xeon Phi 用のドライバがインストールされているか確認 ###
echo "=== Xeon Phi のドライバ確認 ==="
if ! dpkg -l | grep -q "intel-mic-kmod"; then
    echo "⚠ Intel Xeon Phi ドライバがインストールされていません。インストールを実行します。"
    sudo apt update
    sudo apt install -y intel-mic-kmod intel-mic-tools
else
    echo "✅ Intel Xeon Phi ドライバは既にインストール済みです。"
fi

### 3️⃣ mic0 デバイスが正しく作成されているか確認 ###
echo "=== mic0 デバイスの確認 ==="
if [ ! -e "/dev/mic0" ]; then
    echo "⚠ /dev/mic0 が見つかりません。modprobe を実行します。"
    sudo modprobe mic
else
    echo "✅ /dev/mic0 が正しく作成されています。"
fi

### 4️⃣ SSH 設定 & Xeon Phi への接続確認 ###
echo "=== Xeon Phi のネットワーク接続を確認 ==="
if ! ssh mic0 "echo '✅ Xeon Phi に正常に接続できます。'"; then
    echo "⚠ SSH 接続に失敗しました。`mic0` の IP 設定を確認してください。"
    exit 1
else
    echo "✅ Xeon Phi に正常に接続できます。"
fi

### 5️⃣ Xeon Phi の詳細情報を取得 ###
echo "=== Xeon Phi の詳細情報を取得 ==="
ssh mic0 << 'EOF'
    echo "=== CPU 情報 ==="
    cat /proc/cpuinfo | grep -E "model name|cpu cores|siblings" | uniq
    echo ""

    echo "=== メモリ情報 ==="
    free -h
    echo ""

    echo "=== ディスク情報 ==="
    df -h
    echo ""

    echo "=== ネットワークインターフェース情報 ==="
    ip a
    echo ""

    echo "=== OS バージョン ==="
    cat /etc/os-release || lsb_release -a
    echo ""

    echo "=== カーネルバージョン ==="
    uname -a
    echo ""

    echo "=== 利用可能なライブラリ ==="
    ldconfig -p | grep -E "libc|libstdc++|libm"
    echo ""

    echo "=== OpenMP サポート確認 ==="
    if command -v gcc &> /dev/null; then
        echo '#include <omp.h>\n#include <stdio.h>\nint main() { printf("OpenMP スレッド数: %d\\n", omp_get_max_threads()); return 0; }' > test_omp.c
        gcc test_omp.c -o test_omp -fopenmp && ./test_omp
        rm test_omp.c test_omp
    else
        echo "GCC が見つかりませんでした。"
    fi
    echo ""

    echo "=== インストール済みの開発ツール一覧 & バージョン情報 ==="
    
    echo "Python:"
    if command -v python3 &> /dev/null; then python3 --version; else echo "Python 未インストール"; fi
    echo ""

    echo "GCC:"
    if command -v gcc &> /dev/null; then gcc --version | head -n 1; else echo "GCC 未インストール"; fi
    echo ""

    echo "CMake:"
    if command -v cmake &> /dev/null; then cmake --version | head -n 1; else echo "CMake 未インストール"; fi
    echo ""

    echo "Make:"
    if command -v make &> /dev/null; then make --version | head -n 1; else echo "Make 未インストール"; fi
    echo ""

    echo "Git:"
    if command -v git &> /dev/null; then git --version; else echo "Git 未インストール"; fi
    echo ""

    echo "その他のインストール済みツール:"
    command -v g++ &> /dev/null && g++ --version | head -n 1
    command -v nasm &> /dev/null && nasm -v
    command -v yasm &> /dev/null && yasm --version
    command -v pkg-config &> /dev/null && pkg-config --version
    command -v perl &> /dev/null && perl -v | head -n 2
    command -v wget &> /dev/null && wget --version | head -n 1
    command -v curl &> /dev/null && curl --version | head -n 1
EOF

echo "=== Xeon Phi のセットアップ & 情報取得が完了しました！ ==="
