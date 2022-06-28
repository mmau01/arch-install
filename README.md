# Arch install
#### Verify the boot mode
```
$ ls /sys/firmware/efi/efivars
```
If the command shows the directory without error, then the system is booted in UEFI mode.
#### Update the system clock
```
$ timedatectl set-ntp true
```
#### Internet access.
```
$ rfkill unblock all
$ wifi-menu
```
#### Partition the disks
```
$ cgdisk /dev/nvme0n1
  1 512MiB EFI partition # Hex code ef00
  2 8GiB Swap partition
  3 100% size partiton # (to be encrypted) Hex code 8300
```
```
Number  Start (sector)    End (sector)  Size       Code  Name
   1            2048         1050623   512.0 MiB   EF00  EFI system partition
   2    --swap--
   3         1050624        41943006    19.5 GiB   8300  Linux filesystem
```
#### Prepare the encrypted root partition
```
$ cryptsetup luksFormat /dev/sda2
$ cryptsetup open /dev/sda2 cryptroot
$ mkfs.ext4 /dev/mapper/cryptroot
$ mount /dev/mapper/cryptroot /mnt
```
#### Prepare the boot partition
```
$ mkfs.fat -F32 /dev/sda1
$ mkdir /mnt/boot
$ mount /dev/sda1 /mnt/boot
```
#### Generate an fstab file
```
$ genfstab -U /mnt >> /mnt/etc/fstab
```
#### Install the base system.
```
$ pacstrap /mnt base base-devel linux linux-firmware mkinitcpio networkmanager neovim dhcpcd wpa_supplicant 
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
$ locale-gen
$ localectl set-locale LANG=en_AU.UTF-8
```
#### Network configuration
```
echo 'hostname' > /etc/hostname
/etc/hosts:
    127.0.0.1  localhost
    ::1        localhost
    127.0.1.1  hostname.localdomain hostname
```
#### Configuring mkinitcpio
```
/etc/mkinitcpio.conf:
    HOOKS=(base udev autodetect modconf block keyboard encrypt filesystems fsck)
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
Replace the UUID (not PARTUUID) to the one mapping to /dev/sda2 (Run blkid to find out)
    title   Arch Linux
    linux   /vmlinuz-linux
    initrd  /intel-ucode.img
    initrd  /initramfs-linux.img
    options cryptdevice=UUID=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX:cryptroot root=/dev/mapper/cryptroot rw
```
#### Replace /boot/loader/loader.conf to
```
default      arch.conf
timeout      5
console-mode max
editor       no
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
#### Enable dhcpcd:
```
$ systemctl enable dhcpcd
```
#### Connect to Wi-Fi:
```
$ nmcli d wifi list
$ nmcli d wifi connect MY_WIFI password MY_PASSWORD
```
#### Add User
```
$ EDITOR=nvim visudo 
uncomment %wheel ALL=(ALL) NOPASSWD: ALL
$ useradd --create-home --groups wheel user
$ passwd user
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
