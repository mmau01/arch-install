#!/bin/sh -x

# Base config.
echo en_AU.UTF-8 UTF-8 >> /etc/locale.gen
localectl set-locale LANG=en_AU.UTF-8
locale-gen
export LANG=en_AU.UTF-8
ln -sf /usr/share/zoneinfo/Australia/Melbourne /etc/localtime
hwclock --systohc --utc
echo c642r > /etc/hostname
echo "EDITOR=nvim" > /etc/environment && echo "VISUAL=nvim" >> /etc/environment
echo "blacklist ideapad_laptop" >> /etc/modprobe.d/blacklist.conf
echo "blacklist wacom" >> /etc/modprobe.d/blacklist.conf

# Set your mkinitcpio encrypt/lvm2 hooks and rebuild.
sed -i 's/^HOOKS=.*/HOOKS=(base udev keyboard autodetect modconf block encrypt filesystems fsck)/' /etc/mkinitcpio.conf
mkinitcpio -P

# Users
passwd
useradd -m -G wheel -s /bin/bash mike
passwd mike
sed -i "s/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/" /etc/sudoers
echo "mike ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/sudoer_mike

# Patch Intel microcode
pacman -S intel-ucode --noconfirm

# Bootloader
## !Replace the UUID (not PARTUUID) to the one mapping to /dev/nvme0n1p2 (Run blkid to find out)
bootctl install
echo "title   Arch Linux" >> /boot/loader/entries/arch.conf
echo "linux   /vmlinuz-linux" >> /boot/loader/entries/arch.conf
echo "initrd  /intel-ucode.img" >> /boot/loader/entries/arch.conf
echo "initrd  /initramfs-linux.img" >> /boot/loader/entries/arch.conf
echo "options cryptdevice=UUID=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX:cryptroot root=/dev/mapper/cryptroot rw" >> /boot/loader/entries/arch.conf
## !clear /boot/loader/loader.conf first
echo "default      arch.conf" >> /boot/loader/loader.conf
echo "timeout      3" >> /boot/loader/loader.conf
echo "console-mode max" >> /boot/loader/loader.conf
echo "editor       yes" >> /boot/loader/loader.conf
bootctl list

echo "exit the chroot, unmount, and reboot:"
echo "$ exit"
echo "$ umount -R /mnt"
echo "$ reboot"
