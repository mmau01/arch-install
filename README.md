# Arch install
#### Verify the boot mode
```
$ ls /sys/firmware/efi/efivars
```
If the command shows the directory without error, then the system is booted in UEFI mode.
#### Update the system clock
```
$ timedatectl set-ntp 1
```
#### Internet access.
```
$ rfkill unblock all
$ iwctl
```
#### Partition the disks
```
$ cgdisk /dev/nvme0n1
  1 512MiB EFI partition # Hex code ef00
  2 100% size partiton # (to be encrypted) Hex code 8300
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
$ mkdir /mnt/boot
$ mount /dev/nvme0n1p1 /mnt/boot
```
#### Select mirrors
```
pacman -Syy
reflector --verbose --protocol https --latest 5 --sort rate --country Australia --save /etc/pacman.d/mirrorlist
```
#### Install the base system.
```
$ pacstrap /mnt base base-devel intel-ucode linux linux-firmware bash-completion cryptsetup neovim reflector sudo iwd
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
Edit /etc/locale.gen and uncomment en_AU.UTF-8 UTF-8 and other needed locales. Generate the locales by running:
$ localectl set-locale LANG=en_AU.UTF-8
$ locale-gen
```
#### Network configuration
```
echo 'hostname' > /etc/hostname
/etc/hosts:
    127.0.0.1  localhost
    ::1        localhost
    127.0.1.1  hostname.localdomain hostname
```
#### Set a system-wide default editor
```
echo "EDITOR=nvim" > /etc/environment && echo "VISUAL=nvim" >> /etc/environment
```
#### Configuring mkinitcpio
```
/etc/mkinitcpio.conf:
    HOOKS=(base udev keyboard autodetect modconf block encrypt filesystems fsck)
```
#### Generate the initramfs
```
Since we have changed to /etc/mkinitcpio.conf manually, we have to re-generates the boot images (e.g., /boot/initramfs-linux.img).
$ mkinitcpio -P
```
#### Set the root password
```
$ passwd
```
#### Add user
```
useradd -m -G wheel -s /bin/bash foo
passwd foo
sed -i "s/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/" /etc/sudoers
```
#### Patch the CPU’s microcode
```
$ pacman -S intel-ucode
```
#### Install the EFI boot manager
```
$ bootctl install
```
#### Create /boot/loader/entries/arch.conf
```
Replace intel-ucode.img with amd-ucode.img if you have an AMD CPU
Replace the UUID (not PARTUUID) to the one mapping to /dev/nvme0n1p2 (Run blkid to find out)
    title   Arch Linux
    linux   /vmlinuz-linux
    initrd  /intel-ucode.img
    initrd  /initramfs-linux.img
    options cryptdevice=UUID=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX:cryptroot root=/dev/mapper/cryptroot rw
```
#### Replace /boot/loader/loader.conf
```
default      arch.conf
timeout      3
console-mode max
editor       yes
```
#### Review the configuration
```
$ bootctl list
Boot Loader Entries:
        title: Arch Linux (default)
           id: arch.conf
       source: /boot/loader/entries/arch.conf
        linux: /vmlinuz-linux
       initrd: /intel-ucode.img
               /initramfs-linux.img
      options: cryptdevice=UUID=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX:cryptroot root=/dev/mapper/cryptroot rw
```
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
#### Sudo
```
$ echo "foo ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/sudoer_foo
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
ILoveCandy
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
#### Set Up Sound
```
$ sudo pacman -S pipewire pipewire-pulse
```
#### Enable Time Synchronization
```
$ sudo systemctl enable systemd-timesyncd.service --now
```
#### Improve Power Management (on laptops)
```
$ sudo pacman -S tlp tlp-rdw
$ sudo systemctl enable tlp.service --now
$ sudo systemctl enable NetworkManager-dispatcher.service --now
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
#### Intel Graphics
Install `mesa` and `vulkan-intel`
