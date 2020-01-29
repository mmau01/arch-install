#!/bin/bash

#auracle install
mkdir -p ~/tmp/auracle_install
cd ~/tmp/auracle_install
wget https://aur.archlinux.org/cgit/aur.git/snapshot/auracle-git.tar.gz
tar -xzf auracle-git.tar.gz
cd auracle-git
makepkg PKGBUILD --skippgpcheck --noconfirm
sudo pacman -U auracle-git-*

#Install dependency packages we'll need to build Pacaur on Arch.
sudo pacman -S binutils make gcc fakeroot expac yajl git --noconfirm

#Create a temporary working directory for installing Pacaur.
mkdir -p ~/tmp/pacaur_install
cd ~/tmp/pacaur_install

#Install pacaur from AUR: Download the files from git and build a .tar.xz file then install it.
curl -o PKGBUILD https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=pacaur
makepkg -i PKGBUILD --noconfirm
sudo pacman -U pacaur*.tar.xz --noconfirm

#Now clean up system: deleting temporary directory.
rm -r ~/tmp/pacaur_install
cd -
