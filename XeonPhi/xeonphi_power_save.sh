#!/bin/bash

echo "=== Xeon Phi 5110P の省電力設定を適用 & 確認 ==="

# SSH を使って Xeon Phi に設定を適用
ssh mic0 << 'EOF'
    echo "=== 省電力設定を適用中... ==="

    # CPU 周波数を 800MHz に制限（デフォルトは 1.1GHz～1.2GHz）
    echo "800000" | sudo tee /sys/devices/system/mic/mic0/cpu_max_frequency > /dev/null

    # 消費電力制限を 120W に設定（デフォルトは 300W 以上）
    echo "120" | sudo tee /sys/class/mic/mic0/power_limit > /dev/null

    # 省電力モード（powersave）に変更（デフォルトは performance）
    echo "powersave" | sudo tee /sys/devices/system/mic/mic0/cpufreq/scaling_governor > /dev/null

    echo "=== 省電力設定を確認 ==="
    echo "現在の CPU 周波数制限: $(cat /sys/devices/system/mic/mic0/cpu_max_frequency) Hz"
    echo "現在の 電力制限: $(cat /sys/class/mic/mic0/power_limit) W"
    echo "現在の CPU スケーリングモード: $(cat /sys/devices/system/mic/mic0/cpufreq/scaling_governor)"

    echo "=== Xeon Phi 5110P の省電力設定が適用されました ==="
EOF
