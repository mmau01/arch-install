#### Install & enable power management
```
sudo pacman -S tlp x86_energy_perf_policy
sudo systemctl enable tlp.service
sudo systemctl enable tlp-sleep.service
sudo pacman -S tlp-rdw
sudo systemctl mask systemd-rfkill.service
sudo systemctl mask systemd-rfkill.socket
```

#### Install system packages
```
sudo pacman -S mesa vulkan-intel acpi alsa-utils
```

#### Install theme packages
```
sudo pacman -S lxappearance gtk-engine-murrine arc-gtk-theme numix-gtk-theme  --noconfirm --needed
pacaur -S paper-icon-theme-git
```

#### Install fonts
```
sudo pacman -S ttf-dejavu ttf-liberation noto-fonts
sudo ln -s /etc/fonts/conf.avail/70-no-bitmaps.conf /etc/fonts/conf.d
sudo ln -s /etc/fonts/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d
sudo ln -s /etc/fonts/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d
```

#### vim color scheme and airline status bar
```
mkdir -p ~/.vim/autoload ~/.vim/bundle
mkdir /tmp/pathogen && cd /tmp/pathogen && git clone https://github.com/tpope/vim-pathogen
cp /tmp/pathogen/vim-pathogen/autoload/pathogen.vim ~/.vim/autoload/
rm -rf /tmp/pathogen/
cd ~/.vim/bundle
git clone https://github.com/dikiaap/minimalist
git clone https://github.com/vim-airline/vim-airline
```
