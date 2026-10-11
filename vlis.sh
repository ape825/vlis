#!/bin/bash
set -euo pipefail

echo "Encrypting the root partition..."
cryptsetup luksFormat /dev/nvme0n1p2
cryptsetup luksOpen /dev/nvme0n1p2 void
echo "done\n"

echo "Making filesystems..."
mkfs.ext4 /dev/mapper/void
mkfs.vfat -F32 /dev/nvme0n1p1
echo "done\n"

echo "Mounting partitions..."
mount /dev/mapper/void /mnt
mkdir -p /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot
echo "done\n"

echo "Copying keys for installation..."
mkdir -p /mnt/var/db/xbps/keys
cp /var/db/xbps/keys/* /mnt/var/db/xbps/keys/
echo "done\n"

echo "Installing base system and packages..."
xbps-install -Sy -R https://repo-default.voidlinux.org/current -r /mnt base-system cryptsetup limine emacs xorg git font-ibm-plex-ttf NetworkManager seatd turnstile
echo "done\n"

echo "Generating fstab..."
xgenfstab -U /mnt > /mnt/etc/fstab
echo "done\n "
