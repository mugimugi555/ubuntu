#!/bin/bash

#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 🛠️ インタラクティブ GRUB 修復スクリプト（Live USB用）
#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e

# 📦 パッケージ確認・インストール
echo "📦 必要なパッケージを確認中..."
sudo apt update
sudo apt install -y mount efibootmgr grub-pc grub-efi-amd64 os-prober dialog

#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 🔍 ディスクとパーティションをスキャンして選択させる
#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# ディスク一覧の取得
DISKS=( $(lsblk -ndo NAME,TYPE | awk '$2=="disk" {print "/dev/"$1}') )
if [ ${#DISKS[@]} -eq 0 ]; then
  echo "❌ ディスクが見つかりませんでした。"
  exit 1
fi

# 選択肢の作成
MENU_DISKS=()
for disk in "${DISKS[@]}"; do
  DESC=$(lsblk -no SIZE,MODEL "$disk" | head -n1)
  MENU_DISKS+=("$disk" "$DESC")
  
  # 各ディスクのパーティションも追加
  while read -r part desc; do
    MENU_DISKS+=("/dev/$part" "  └ $desc")
  done < <(lsblk -ndo NAME,SIZE "$disk" | tail -n +2)
done

CHOICE=$(dialog --stdout --menu "修復したいルートパーティションを選んでください：" 20 60 12 "${MENU_DISKS[@]}")
clear

if [ -z "$CHOICE" ]; then
  echo "❌ キャンセルされました。"
  exit 1
fi

ROOT_PARTITION="$CHOICE"
DISK_DEVICE="$(lsblk -no PKNAME "$ROOT_PARTITION")"
DISK_DEVICE="/dev/$DISK_DEVICE"

MNT="/mnt/repair_root"
echo "📁 パーティション $ROOT_PARTITION を $MNT にマウント..."
sudo mount "$ROOT_PARTITION" "$MNT" || { echo "❌ マウントに失敗"; exit 1; }

# EFI パーティションのマウント（存在すれば）
if [ -d "$MNT/boot/efi" ]; then
  echo "💡 EFI モード検出。EFI パーティションをマウント..."
  EFI_PART=$(lsblk -no NAME,FSTYPE,MOUNTPOINT "$DISK_DEVICE" | grep -iE "efi|fat32" | awk '{print $1}' | head -n1)
  [ -n "$EFI_PART" ] && sudo mount "/dev/$EFI_PART" "$MNT/boot/efi"
fi

# システム関連を bind mount
for dir in /dev /proc /sys /run; do
  sudo mount --bind "$dir" "$MNT$dir"
done

#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 🔁 chroot による grub 修復
#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "🔧 chroot環境に入り GRUB を再インストールします..."
sudo chroot "$MNT" /bin/bash <<EOF

echo "🧱 GRUB インストール: grub-install $DISK_DEVICE"
grub-install "$DISK_DEVICE"

echo "🌀 GRUB 設定の再構築: update-grub"
update-grub

EOF

#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 🧹 アンマウントと完了
#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "✅ 修復完了。アンマウント中..."
sudo umount -l "$MNT/boot/efi" 2>/dev/null || true
for dir in /dev /proc /sys /run; do
  sudo umount -l "$MNT$dir" 2>/dev/null || true
done
sudo umount -l "$MNT"

echo "🎉 GRUB の修復が完了しました！再起動して動作を確認してください。"
