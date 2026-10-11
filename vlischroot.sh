#!/bin/bash
set -euo pipefail

echo "Setting up a user account..."
passwd
useradd -m -G wheel,network,video,input,_seatd ape
passwd ape
echo t14g2 > /etc/hostname
echo " done"

echo "Configuring time and locales..."
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "en_US.UTF-8 UTF-8" >> /etc/default/libc-locales
xbps-reconfigure -f glibc-locales
ln -sf /usr/share/zoneinfo/Etc/GMT-3 /etc/localtime
echo localtime > /etc/hwclock
echo " done"

echo "Configuring limine bootloader..."
mkdir -p boot/EFI/BOOT
cp /usr/share/limine/BOOTX64.EFI boot/EFI/BOOT/
uuid=$(blkid -s UUID -o value /dev/nvme0n1p2)
cat > boot/EFI/BOOT/limine.conf <<EOF
timeout: 5

/Void Linux (6.18.55)
    protocol: linux
    kernel_path: boot():/vmlinuz-6.18.55_1
    module_path: boot():/initramfs-6.18.55_1.img
    cmdline: root=/dev/mapper/luks-$uuid rd.luks.uuid=$uuid rw
EOF
echo " done, umount and reboot now."
