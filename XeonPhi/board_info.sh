#!/bin/bash

echo "=== Xeon Phi のシステム情報を取得 ==="

# SSH で Xeon Phi に接続して情報を取得
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
EOF

echo "=== Xeon Phi の情報取得が完了しました！ ==="
