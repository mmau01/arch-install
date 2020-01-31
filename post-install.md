#### Create user
```
pacman -S sudo
useradd -m -g users -G wheel -s /bin/bash mike
passwd mike
visudo
logout
```

#### Install pacaur
```
cd /tmp
wget https://github.com/mmau01/arch-install/raw/master/pacaur-install.sh
chmod +x pacaur-install.sh
./pacaur-install.sh
```

#### Install & enable power management
```
sudo pacman -S tlp tlp-rdw x86_energy_perf_policy
sudo systemctl enable tlp.service
sudo systemctl enable tlp-sleep.service
sudo systemctl mask systemd-rfkill.service
sudo systemctl mask systemd-rfkill.socket
```

#### Install system packages
```
sudo pacman -S mesa vulkan-intel acpi unzip
```

#### Install fonts
```
sudo pacman -S ttf-dejavu ttf-liberation noto-fonts ttf-hack ttf-font-awesome-4 adobe-source-code-pro-fonts adobe-source-sans-pro-fonts
sudo ln -s /etc/fonts/conf.avail/70-no-bitmaps.conf /etc/fonts/conf.d
sudo ln -s /etc/fonts/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d
sudo ln -s /etc/fonts/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d
```

#### Install WM
```
sudo pacman -S xorg-server xorg-xinit rofi polybar feh
cd /etc/X11/xorg.conf.d/
wget https://github.com/mmau01/dotfiles/raw/master/xorg.conf.d/40-libinput.conf
```

#### Install apps
```
sudo pacman -S alacritty
```

#### airline status bar
```
mkdir -p .local/share/nvim/site/pack/vim-airline/start/
cd .local/share/nvim/site/pack/vim-airline/start/
git clone https://github.com/vim-airline/vim-airline
```

#### Install theme packages
```
sudo pacman -S lxappearance gtk-engine-murrine arc-gtk-theme meson
pacaur -S paper-icon-theme-git
```

#### Git/Stow install/config
```
sudo pacman -S stow git
mkdir -p $HOME/dotfiles
cd $HOME/dotfiles
git pull......
```
