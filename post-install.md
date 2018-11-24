#### Create user
```
pacman -S sudo
useradd -m -g users -G wheel -s /bin/bash mike
passwd mike
visudo wheel group
```

#### Install pacaur
```
cd /tmp
wget https://github.com/mmau01/arch-install/raw/master/pacaur-install.sh
chmod +x pacaur-install.sh
./pacaur-install.sh
```

