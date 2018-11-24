sudo pacman -S binutils make gcc fakeroot pkg-config --noconfirm --needed
sudo pacman -S expac yajl git --noconfirm --needed
git clone https://aur.archlinux.org/cower.git && git clone https://aur.archlinux.org/pacaur.git && cd cower && makepkg -si --skippgpcheck && cd ../pacaur && makepkg -si && cd .. && rm -rf cower pacaur
