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
$ parted -s /dev/nvme0n1 mklabel gpt
$ parted -s /dev/nvme0n1 mkpart primary fat32 1MiB 513MiB
$ parted -s /dev/nvme0n1 set 1 boot on
$ parted -s /dev/nvme0n1 set 1 esp on
$ parted -s /dev/nvme0n1 mkpart primary 513MiB 1024MiB
$ parted -s /dev/nvme0n1 mkpart primary 1024MiB 100%
$ mkfs.vfat -F32 /dev/nvme0n1p1
```
#### Create and mount the encrypted root filesystem.
```
$ cryptsetup luksFormat /dev/nvme0n1p3
$ cryptsetup luksOpen /dev/nvme0n1p3 lvm
$ pvcreate /dev/mapper/lvm
$ vgcreate arch /dev/mapper/lvm
$ lvcreate -L 8G arch -n swap
$ lvcreate -l +100%FREE arch -n root
$ mkswap -L swap /dev/mapper/arch-swap
$ mkfs.ext4 /dev/mapper/arch-root
$ mount /dev/mapper/arch-root /mnt
$ swapon /dev/mapper/arch-swap
```
#### Encrypt the boot partition using a separate passphrase from the root partition, then mount the boot and EFI partitions.
```
$ cryptsetup luksFormat /dev/nvme0n1p2
$ cryptsetup luksOpen /dev/nvme0n1p2 cryptboot
$ mkfs.ext4 /dev/mapper/cryptboot
$ mkdir /mnt/boot
$ mount /dev/mapper/cryptboot /mnt/boot
$ mkdir /mnt/boot/efi
$ mount /dev/nvme0n1p1 /mnt/boot/efi
```
#### Install the base system.
```
$ pacstrap /mnt base base-devel efibootmgr networkmanager grub-efi-x86_64 intel-ucode vim wget net-tools
```
#### Generate and verify fstab.
```
$ genfstab -Up /mnt >> /mnt/etc/fstab
```
#### Change root into the base install and perform base configuration tasks.
```
$ arch-chroot /mnt /bin/bash
$ echo en_AU.UTF-8 UTF-8 >> /etc/locale.gen
$ locale-gen
$ echo LANG=en_AU.UTF-8 > /etc/locale.conf
$ export LANG=en_AU.UTF-8
$ ln -sf /usr/share/zoneinfo/Australia/Melbourne /etc/localtime
$ hwclock --systohc --utc
$ echo c642r > /etc/hostname
$ passwd
$ systemctl enable NetworkManager.service
$ echo "blacklist ideapad_laptop" >> /etc/modprobe.d/blacklist.conf
$ echo "blacklist wacom" >> /etc/modprobe.d/blacklist.conf
```
#### Set your mkinitcpio encrypt/lvm2 hooks and rebuild.
```
$ sed -i 's/^MODULES=.*/MODULES=(ext4 i915)/' /etc/mkinitcpio.conf
$ sed -i 's/^HOOKS=.*/HOOKS=(base udev keyboard autodetect modconf block encrypt lvm2 resume filesystems fsck)/' /etc/mkinitcpio.conf
$ sed -i 's/^FILES=.*/FILES=(\/crypto_keyfile.bin)/' /etc/mkinitcpio.conf
$ mkinitcpio -p linux
```
#### Add a keyfile to decrypt and mount the boot volume during startup.
```
$ dd bs=512 count=4 if=/dev/urandom of=/crypto_keyfile.bin
$ chmod 000 /crypto_keyfile.bin
$ chmod 600 /boot/initramfs-linux*
$ cryptsetup luksAddKey /dev/nvme0n1p2 /crypto_keyfile.bin
$ echo "cryptboot /dev/nvme0n1p2 /crypto_keyfile.bin luks" >> /etc/crypttab
$ mkinitcpio -p linux
```
#### Configure GRUB.
```
$ sed -i 's/^#GRUB_ENABLE_CRYPTODISK=.*/GRUB_ENABLE_CRYPTODISK=y/' /etc/default/grub
$ echo 'GRUB_FORCE_HIDDEN_MENU="true"' >> /etc/default/grub
$ wget https://gist.githubusercontent.com/anonymous/8eb2019db2e278ba99be/raw/257f15100fd46aeeb8e33a7629b209d0a14b9975/gistfile1.sh -O /etc/grub.d/31_hold_shift
$ chmod a+x /etc/grub.d/31_hold_shift
$ ROOTUUID=$(blkid /dev/nvme0n1p3 | awk '{print $2}' | cut -d '"' -f2)
$ sed -i "s/^GRUB_CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX=\"cryptdevice=UUID=$ROOTUUID:lvm:allow-discards root=\/dev\/mapper\/arch-root resume=\/dev\/mapper\/arch-swap\"/" /etc/default/grub
$ grub-mkconfig -o /boot/grub/grub.cfg
$ grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id="grub" --recheck
$ chmod -R g-rwx,o-rwx /boot
```
#### Cleanup and reboot!
```
$ exit
$ umount -R /mnt
$ reboot
```
#### Install & enable power management
```
$ sudo pacman -S tlp x86_energy_perf_policy
$ sudo systemctl enable tlp.service
$ sudo systemctl enable tlp-sleep.service
$ sudo pacman -S tlp-rdw
$ sudo systemctl mask systemd-rfkill.service
$ sudo systemctl mask systemd-rfkill.socket
```
