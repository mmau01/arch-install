# Arch install

#### Laptop module blacklist
```
$ echo "blacklist ideapad_laptop" >> /etc/modprobe.d/blacklist.conf
$ echo "blacklist wacom" >> /etc/modprobe.d/blacklist.conf
$ rfkill unblock all
```

#### Internet access.
```
$ wifi-menu
```
#### Create partitions for EFI, boot, and root.
```
$ cgdisk /dev/nvme0n1
  1 100MB EFI partition # Hex code ef00
  2 250MB Boot partition # Hex code 8300
  3 100% size partiton # (to be encrypted) Hex code 8300
$ mkfs.vfat -F32 /dev/nvme0n1p1
$ mkfs.ext4 /dev/nvme0n1p2
```
#### Create and mount the encrypted root filesystem.
```
$ cryptsetup -c aes-xts-plain64 -h sha512 -s 512 --use-random luksFormat /dev/nvme0n1p3
$ cryptsetup luksOpen /dev/nvme0n1p3 luks-lvm
$ pvcreate /dev/mapper/luks-lvm
$ vgcreate arch /dev/mapper/luks-lvm
$ lvcreate -L 8G arch -n swap
$ lvcreate -l +100%FREE arch -n root
$ mkswap -L swap /dev/mapper/arch-swap
$ mkfs.btrfs /dev/mapper/arch-root
$ mount /dev/mapper/arch-root /mnt
$ swapon /dev/mapper/arch-swap
$ mkdir /mnt/boot
$ mount /dev/nvme0n1p2 /mnt/boot
$ mkdir /mnt/boot/efi
$ mount /dev/nvme0n1p1 /mnt/boot/efi
```
#### Install the base system.
```
$ pacstrap /mnt base base-devel efibootmgr networkmanager grub-efi-x86_64 btrfs-progs intel-ucode vim wget net-tools
```
#### Generate and verify fstab.
```
$ genfstab -Up /mnt >> /mnt/etc/fstab
```
#### Change root into the base install and perform base configuration tasks.
```
$ arch-chroot /mnt /bin/bash
$ cd /tmp
$ wget https://github.com/mmau01/arch-install/raw/master/base-config.sh
$ chmod +x base-config.sh
$ ./base-config.sh
```
#### Cleanup and reboot!
```
$ exit
$ umount -R /mnt
$ reboot
```
