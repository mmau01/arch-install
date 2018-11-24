#### Install & enable power management
```
$ sudo pacman -S tlp x86_energy_perf_policy
$ sudo systemctl enable tlp.service
$ sudo systemctl enable tlp-sleep.service
$ sudo pacman -S tlp-rdw
$ sudo systemctl mask systemd-rfkill.service
$ sudo systemctl mask systemd-rfkill.socket
```
