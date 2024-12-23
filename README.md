# Arch install
#### Check system clock is correct
```
$ timedatectl
```
#### Internet access.
```
$ rfkill unblock all
$ iwctl
```
#### Partition the disks
```
$ cgdisk /dev/nvme0n1
  1 /boot 1G EFI partition # Hex code ef00
  2 / 100% size partiton # (to be encrypted) Hex code 8300
```
#### Prepare the encrypted root partition
```
$ cryptsetup luksFormat /dev/nvme0n1p2
$ cryptsetup open /dev/nvme0n1p2 cryptroot
$ mkfs.ext4 /dev/mapper/cryptroot
$ mount /dev/mapper/cryptroot /mnt
```
#### Prepare the boot partition
```
$ mkfs.fat -F32 /dev/nvme0n1p1
$ mount --mkdir /dev/nvme0n1p1 /mnt/boot
```
#### Select mirrors
```
pacman -Syy
reflector --latest 5 --sort rate --country Australia --save /etc/pacman.d/mirrorlist
```
#### Install the base system.
```
$ pacman-key --init
$ pacman-key --populate
$ pacstrap /mnt base base-devel intel-ucode linux linux-firmware bash-completion cryptsetup neovim reflector sudo iwd mesa vulkan-intel
```
#### Generate an fstab file
```
$ genfstab -U /mnt >> /mnt/etc/fstab
```
#### Chroot
```
$ arch-chroot /mnt
```
#### Time zone
```
$ ln -sf /usr/share/zoneinfo/Australia/Melbourne /etc/localtime
$ hwclock --systohc
```
#### Localization
```
$ echo en_AU.UTF-8 UTF-8 >> /etc/locale.gen
$ localectl set-locale LANG=en_AU.UTF-8
$ locale-gen
```
#### Hostname
```
echo 'hostname' > /etc/hostname
```
#### Set a system-wide default editor
```
echo "EDITOR=nvim" > /etc/environment && echo "VISUAL=nvim" >> /etc/environment
```
#### Configuring mkinitcpio and generate the initramfs
```
$ sed -i 's/^HOOKS=.*/HOOKS=(base udev keyboard autodetect modconf block encrypt filesystems fsck)/' /etc/mkinitcpio.conf
$ mkinitcpio -P
```
#### Users
```
$ passwd
$ useradd -m -G wheel -s /bin/bash foo
$ passwd foo
$ sed -i "s/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/" /etc/sudoers
$ echo "foo ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/sudoer_foo
```
#### Bootloader
#### Cleanup and reboot!
```
$ exit
$ umount -R /mnt
$ reboot
```
#### Check for errors
```
Failed systemd services
$ systemctl --failed
High priority errors in the systemd journal
$ journalctl -p 3 -xb
```
#### Mirrors
Set parameters in /etc/xdg/reflector/reflector.conf
```
--save /etc/pacman.d/mirrorlist
--protocol https
--country Australia
--latest 5
--sort rate
```
Reflector ships with a systemd service and timer: /usr/lib/systemd/system/reflector.{service,timer}
Enable and start the timer (default is weekly update, edit reflector.timer to change)
```
$ sudo systemctl enable --now reflector.timer
```
#### Pacman
Modify /etc/pacman.conf
```
# Misc options
Color
```
Update system
```
$ sudo pacman -Syu
```
#### Update systemd-boot
```
$ sudo mkdir /etc/pacman.d/hooks
```
Automatically update the boot manager whenever a new version of systemd-boot is reinstalled by creating /etc/pacman.d/hooks/100-systemd-boot.hook ...
```
[Trigger]
Type = Package
Operation = Upgrade
Target = systemd

[Action]
Description = Updating systemd-boot
When = PostTransaction
Exec = /usr/bin/bootctl update
```
#### Enable Time Synchronization
```
$ sudo systemctl enable systemd-timesyncd.service --now
```
#### Improve Power Management (on laptops)
```
$ sudo pacman -S tlp
$ sudo systemctl mask systemd-rfkill.service systemd-rfkill.socket
$ sudo systemctl enable tlp.service --now
$ sudo tlp-stat
```
#### Enable Scheduled fstrim
```
$ sudo systemctl enable fstrim.timer --now
```
#### Reduce Swappiness
```
$ echo 'vm.swappiness=10' | sudo tee /etc/sysctl.d/99-swappiness.conf
```
#### Install YAY
```
pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```
