#!/bin/sh

parted -s /dev/nvme0n1 mklabel gpt
parted -s /dev/nvme0n1 mkpart primary fat32 1MiB 513MiB
parted -s /dev/nvme0n1 set 1 boot on
parted -s /dev/nvme0n1 set 1 esp on
parted -s /dev/nvme0n1 mkpart primary 513MiB 1024MiB
parted -s /dev/nvme0n1 mkpart primary 1024MiB 100%
mkfs.vfat -F32 /dev/nvme0n1p1

cryptsetup luksFormat /dev/nvme0n1p3
cryptsetup luksOpen /dev/nvme0n1p3 lvm
pvcreate /dev/mapper/lvm
vgcreate arch /dev/mapper/lvm
lvcreate -L 8G arch -n swap
lvcreate -l +100%FREE arch -n root
mkswap -L swap /dev/mapper/arch-swap
mkfs.ext4 /dev/mapper/arch-root
mount /dev/mapper/arch-root /mnt
swapon /dev/mapper/arch-swap

cryptsetup luksFormat /dev/nvme0n1p2
cryptsetup luksOpen /dev/nvme0n1p2 cryptboot
mkfs.ext4 /dev/mapper/cryptboot
mkdir /mnt/boot
mount /dev/mapper/cryptboot /mnt/boot
mkdir /mnt/boot/efi
mount /dev/nvme0n1p1 /mnt/boot/efi

echo ""
echo "Drive partitioning complete..."
echo "pacstrap /mnt base base-devel efibootmgr networkmanager grub-efi-x86_64 intel-ucode vim wget net-tools"
echo "genfstab -Up /mnt >> /mnt/etc/fstab"
echo "less /mnt/etc/fstab"
