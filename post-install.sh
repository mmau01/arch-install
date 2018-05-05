#!/bin/sh -x

# Base config.
echo en_AU.UTF-8 UTF-8 >> /etc/locale.gen
locale-gen
echo LANG=en_AU.UTF-8 > /etc/locale.conf
export LANG=en_AU.UTF-8
ln -sf /usr/share/zoneinfo/Australia/Melbourne /etc/localtime
hwclock --systohc --utc
echo c642r > /etc/hostname
passwd
systemctl enable NetworkManager.service
echo "blacklist ideapad_laptop" >> /etc/modprobe.d/blacklist.conf
echo "blacklist wacom" >> /etc/modprobe.d/blacklist.conf

# Set your mkinitcpio encrypt/lvm2 hooks and rebuild.
sed -i 's/^MODULES=.*/MODULES=(ext4 i915)/' /etc/mkinitcpio.conf
sed -i 's/^HOOKS=.*/HOOKS=(base udev autodetect modconf block keymap encrypt lvm2 resume filesystems keyboard fsck)/' /etc/mkinitcpio.conf
mkinitcpio -p linux

# Install and configure GRUB.
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=ArchLinux --recheck
#sed -i 's/^#GRUB_ENABLE_CRYPTODISK=.*/GRUB_ENABLE_CRYPTODISK=y/' /etc/default/grub
echo 'GRUB_FORCE_HIDDEN_MENU="true"' >> /etc/default/grub
wget https://gist.githubusercontent.com/anonymous/8eb2019db2e278ba99be/raw/257f15100fd46aeeb8e33a7629b209d0a14b9975/gistfile1.sh -O /etc/grub.d/31_hold_shift
chmod a+x /etc/grub.d/31_hold_shift
ROOTUUID=$(blkid /dev/nvme0n1p3 | awk '{print $2}' | cut -d '"' -f2)
sed -i "s/^GRUB_CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX=\"cryptdevice=UUID=$ROOTUUID:lvm root=\/dev\/mapper\/arch-root resume=\/dev\/mapper\/arch-swap\"/" /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
