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
#### archinstall
```
$ archinstall
```
#### Set a system-wide default editor
```
$ echo "EDITOR=helix" > /etc/environment && echo "VISUAL=helix" >> /etc/environment
```
#### Users
```
$ useradd -m -G wheel -s /bin/bash foo
$ passwd foo
$ sed -i "s/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/" /etc/sudoers
$ echo "foo ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/sudoer_foo
```
#### wifi
```
rfkill unblock wlan
systemctl enable iwd
systemctl start iwd
systemctl enable systemd-resolved
systemctl start systemd-resolved
```
/etc/iwd/main.conf
```
[General]
EnableNetworkConfiguration=true
[Network]
NameResolvingService=systemd
```
#### Select mirrors
```
sudo pacman -Syy
sudo pacman -S rsync
sudo reflector --latest 5 --sort rate --country Australia --save /etc/pacman.d/mirrorlist
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

#### AUR helper
```
sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -si
```
#### sound
Configure with wpctl
```
sudo pacman -S pipewire pipewire-audio pipewire-jack pipewire-pulse pipewire-session-manager wireplumber
```
#### apps
```
System packages - git, reflector
WM - Niri
Terminal - Alacritty
Text editor - Helix
File manager - Thunar
Browser - Firefox
GTK theming - nwg-look
Icon theme - Papirus
IDE - Zed
Spotify (themes - Spicetify)
Discord - https://github.com/Equicord/Equibop
Globalprotect - https://github.com/yuezk/GlobalProtect-openconnect
Proton Drive - https://github.com/rclone/rclone
Proton Pass - proton-pass-bin
VLC
bittorrent - transmission-cli
firewall - evilsocket
```
#### gaming
```
sudo pacman -S mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon vulkan-icd-loader lib32-vulkan-icd-loader --needed
sudo pacman -S gamemode
```
Add user to gamemode group
```
sudo pacman -S umu-launcher
```
#### graphics
```
sudo pacman -S base-devel linux-headers
sudo pacman -S mesa vulkan-radeon
```
#### zen kernel
Install kernel + microcode
```
sudo pacman -S linux-zen linux-zen-headers intel-ucode
```
Install / update systemd-boot
```
sudo bootctl install
sudo bootctl update
```
Get your root PARTUUID (copy it)
```
blkid
```
Create boot entry (replace YOUR_PARTUUID)
```
sudo tee /boot/loader/entries/arch-linux-zen.conf > /dev/null <<EOF
title   Arch Linux (zen)
linux   /vmlinuz-linux-zen
initrd  /intel-ucode.img
initrd  /initramfs-linux-zen.img
options root=PARTUUID=3d17e0bb-d621-4079-b886-24c392ac250e rw quiet mitigations=off nowatchdog transparent_hugepage=always split_lock_detect=off
EOF
```
Set as default
```
sudo bootctl set-default arch-linux-zen.conf
```
Reboot
#### Enable Scheduled fstrim
```
$ sudo systemctl enable fstrim.timer --now
```
#### Reduce Swappiness
```
$ echo 'vm.swappiness=10' | sudo tee /etc/sysctl.d/99-swappiness.conf
```
#### networking
TCP Congestion Control: BBR (Bottleneck Bandwidth and RTT) reduces latency compared to default Cubic:
```
echo "net.ipv4.tcp_congestion_control=bbr" | sudo tee -a /etc/sysctl.conf
echo "net.core.default_qdisc=fq" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```
Reduce network buffer bloat:
```
echo "net.ipv4.tcp_rmem = 4096 87380 16777216" | sudo tee -a /etc/sysctl.conf
echo "net.ipv4.tcp_wmem = 4096 65536 16777216" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```
Disable IPv6 if not used: IPv6 fallback attempts can introduce connection latency:
```
echo "net.ipv6.conf.all.disable_ipv6=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```
These optimizations typically reduce ping by 5-15ms and improve connection stability during network congestion.

#### Shader compilation optimization
Shader compilation represents a unique challenge in Linux gaming through Proton.
Windows games include pre-compiled DirectX shaders, while Linux translates these to Vulkan at runtime.
Enable Steam's shader pre-caching: 
Steam > Settings > Shader Pre-Caching > Enable Shader Pre-Caching
This downloads and compiles shaders before launching games, eliminating first-run stuttering.
Force RADV pipeline cache for AMD GPUs, add to Steam game launch options or shell profile:
```
RADV_PERFTEST=gpl %command%
```
The Graphics Pipeline Library allows runtime shader compilation without stuttering, dramatically improving initial gameplay smoothness on AMD hardware.

#### CPU governor
Linux CPU governors control frequency scaling and power management.
The default "schedutil" governor prioritizes power efficiency over performance, causing frame rate inconsistency.
Check current governor:
```
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
Set performance governor temporarily:
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
```
Permanent configuration > Install cpupower and configure systemd service:
```
sudo pacman -S cpupower
sudo cpupower frequency-set -g performance
```
