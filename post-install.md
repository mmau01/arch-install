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
sudo pacman -S mesa vulkan-intel acpi alsa-firmware alsa-utils alsa-plugins pulseaudio-alsa pulseaudio unzip
alsamixer
```

#### Install fonts
```
sudo pacman -S ttf-dejavu ttf-liberation noto-fonts
sudo ln -s /etc/fonts/conf.avail/70-no-bitmaps.conf /etc/fonts/conf.d
sudo ln -s /etc/fonts/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d
sudo ln -s /etc/fonts/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d

wget https://github.com/adobe-fonts/source-code-pro/archive/2.030R-ro/1.050R-it.zip
unzip 1.050R-it.zip
mkdir -p ~/.fonts
cp source-code-pro-*-it/OTF/*.otf ~/.fonts/
fc-cache -f -v
rm -rf source-code-pro-*-it
rm 1.050R-it.zip
```

#### Install WM
```
sudo pacman -S xorg-server xorg-xinit i3-gaps rofi
cd /etc/X11/xorg.conf.d/
wget https://github.com/mmau01/dotfiles/raw/master/xorg.conf.d/40-libinput.conf
```

#### Install apps
```
sudo pacman -S rxvt-unicode arandr chromium compton
```

#### dotfiles
```
cd /tmp
git clone https://github.com/mmau01/dotfiles
cd dotfiles
cp -r .config .gtk-3.0 ~
cp .xinitrc .bashrc .vimrc .Xresources .gtkrc-2.0 ~
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

#### Install theme packages
```
sudo pacman -S lxappearance gtk-engine-murrine arc-gtk-theme numix-gtk-theme  --noconfirm --needed
pacaur -S meson-git
pacaur -S paper-icon-theme-git
```
