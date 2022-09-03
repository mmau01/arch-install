#!/bin/sh -x

# Sudo
echo "mike ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers.d/sudoer_mike > /dev/null

# Mirrors
Set parameters in /etc/xdg/reflector/reflector.conf
--save /etc/pacman.d/mirrorlist
--protocol https
--country Australia
--latest 5
--sort rate

# Reflector
sudo systemctl enable --now reflector.timer

# Pacman
Modify /etc/pacman.conf
Color

# Update system
sudo pacman -Syu --no-confirm

# Update systemd-boot
sudo mkdir /etc/pacman.d/hooks
sudo tee -a /etc/pacman.d/hooks/100-systemd-boot.hook > /dev/null <<EOT
[Trigger]
Type = Package
Operation = Upgrade
Target = systemd

[Action]
Description = Updating systemd-boot
When = PostTransaction
Exec = /usr/bin/bootctl update
EOT

# Set Up Sound
sudo pacman -S pipewire pipewire-pulse --no-confirm

# Enable Time Synchronization
sudo systemctl enable systemd-timesyncd.service --now

# Improve Power Management (on laptops)
sudo pacman -S tlp tlp-rdw --no-confirm
sudo systemctl enable tlp.service --now
sudo systemctl enable NetworkManager-dispatcher.service --now
sudo tlp-stat

# Enable Scheduled fstrim
sudo systemctl enable fstrim.timer --now

# Reduce Swappiness
echo 'vm.swappiness=10' | sudo tee /etc/sysctl.d/99-swappiness.conf

# Install YAY
sudo pacman -S --needed git base-devel --no-confirm
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

# Check for errors
echo "Failed systemd services"
systemctl --failed
echo "High priority errors in the systemd journal"
journalctl -p 3 -xb
