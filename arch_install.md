Installing Arch Linux
=====================

Bios
----

Checks that:
- Secure boot is disabled (in security)
- Boot is UEFI only (in startup)


Initial install (boot medium)
-----------------------------

# Prepare

```
ping archlinux.org
timedatectl set-ntp true
```

# Partition disks

Check device with:
```
lsblk
```

Partition with:
```
cfdisk /dev/nvmen0n1
```
to get something like
```
Number   Size        Code  Name
   1     550.0 MiB   EF00  EFI System
   3     200.0 MiB   8300  Linux filesystem
   4     <remaining> 8E00  Linux LVM
```
Prepare encryption stuffs and initialize partitions:
```
cryptsetup luksFormat --type luks2 /dev/nvme0n1p3
cryptsetup open /dev/sda3 cryptlvm

pvcreate /dev/mapper/cryptlvm
vgcreate volGroup /dev/mapper/cryptlvm
lvcreate -L 8G volGroup -n swap
lvcreate -L 32G volGroup -n root
lvcreate -l 100%FREE volGroup -n home

mkfs.ext4 /dev/volGroup/root
mkfs.ext4 /dev/volGroup/home
mkswap /dev/volGroup/swap

mount /dev/volGroup/root /mnt
mkdir /mnt/home
mount /dev/volGroup/home /mnt/home
swapon /dev/volGroup/swap

mkfs.ext4 /dev/nvme0n1p2
mkdir /mnt/boot
mount /dev/nvme0n1p2 /mnt/boot

mkfs.fat -F32 /dev/nvme0n1p1
mkdir /mnt/boot/efi
mount /dev/nvme0n1p1 /mnt/boot/efi
```

# Install

Install the base system, chroot and configure base:
```
pacstrap /mnt base base-devel intel-ucode grub efibootmgr neovim wget

genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt

ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
hwclock --systohc
```
Uncomment `en_US.UTF-8 UTF-8` in `/etc/locale.gen` then:
```
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo "x1work" > /etc/hostname
echo -e "127.0.0.1\tlocalhost\n::1\t\tlocalhost\n127.0.1.1\tx1work.localdomain x1work" > /etc/hosts
```
Set proper network interface names by editing `/etc/udev/rules.d/10-network.rules` to something like:
```
SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="54:e1:ad:39:f5:2b", NAME="net0"
SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="40:a3:cc:c1:f7:0a", NAME="wifi0"
```
Install Network Manager:
```
pacman -S networkmanager
systemctl enable NetworkManager.service
```

Edit `/etc/mkinitcpio.conf` to get:
```
HOOKS=(base systemd autodetect keyboard sd-vconsole modconf block sd-encrypt sd-lvm2 filesystems fsck)
```
and run:
```
echo "KEYMAP=us" > /etc/vconsole.conf
mkinitcpio -p linux
```

Configure and prepare the boot loader:
Find the root file system UUID with:
```
blkid /dev/nvme0n1p3
```
Use that in updating `/etc/default/grub` with (`<UUID>` is that of the lvm):
```
GRUB_CMDLINE_LINUX="rd.luks.name=<UUID>=cryptlvm root=/dev/volGroup/root"
GRUB_ENABLE_CRYPTODISK=y
```
Then do:
```
grub-mkconfig -o /boot/grub/grub.cfg
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB --recheck
```

Finally edit the root password:
```
passwd
```
Then `exit` the chroot, `umount -R /mnt` and `reboot`.



Post first-reboot (boot medium)
-----------------------------

Log as root and install all-the-things:
```
pacman -S git zsh bc fzy xorg xf86-video-intel lightdm the_silver_searcher feh lxappearance-gtk3 faenza-icon-theme rofi ttf-font-awesome ttf-inconsolata xfce4-terminal dunst gimp network-manager-applet thunar xcursor-simpleandsoft pulseaudio pavucontrol acpid evince geeqie i3-gaps jdk8-openjdk lftp networkmanager-vpnc openssh otf-fira-code tk transmission-gtk ttf-fira-code gradle intellij-idea-community-edition compton python-virtualenvwrapper wireless_tools xbindkeys
```

Create user:
```
useradd -m -g wheel -s /bin/zsh pcmanus
passwd pcmanus
systemctl enable sshd.socket
```
then use `visudo` to make wheel sudoers.

Log back into pcmanus and:
```
mkdir Git
cd Git
```

Install yaourt:
```
git clone https://aur.archlinux.org/package-query.git
cd package-query
makepkg -si
cd ..
git clone https://aur.archlinux.org/yaourt.git
cd yaourt
makepkg -si
cd ..
```

And instal all-the-remaining-things:
```
yaourt --noconfirm -S flat-remix-git google-chrome gradle-autowrap gtk-theme-arc-grey-git i3-vim-syntax-git jdk8 lightdm-webkit2-greeter lightdm-webkit2-theme-material2 neovim-drop-in polybar slack-desktop spotify ttf-dejavu-sans-code universal-ctags-git pa-applet-git

```

Then pull configurations:
```
git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell
curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
git clone https://github.com/pcmanus/dotfiles
cd dotfiles
./install -f all
```
Then in a new shell, do:
```
base16_tomorrow-night
```
and start `vim` and do `:PlugInstall`

And do additional configuration by setting in `/etc/lightdm/lightdm.conf`:
```
greeter-session=lightdm-webkit2-greeter
```
and in `/etc/lightdm/lightdm-webkit2-greeter.conf`:
```
[greeter]
webkit_theme = material2
```
after which do:
```
systemctl enable lightdm.service
```

More config once in graphical environment:
- In `intellij`, set `Fira Code` as font with ligature.
- Launch `lxappearance` and set:
  - GTK: Arc-Grey-Darker
  - Icons: Flat Remix ( + Faenza)
  - Mouse cursor: Simple-and-Soft (or Breeze)
- In xfce4 terminal:
  - Remove scrollbar and set 50k lines.
  - Set Fira code as font
  - Set transparent background at 0.8
  - remove `Display menubar in new windows` & `Dispay borders around new windows`


Work stuffs
-----------

In `Git`:
```
git clone https://github.com/riptano/bdp dse
cd dse
mkdir ~/.gradle
cp gradle.properties.template ~/.gradle/gradle.properties
```
Edit `~/.gradle/gradle.properties` with expected values and run:
```
gradle jar
gradle cleanIdea idea
```

Git configuration:
```
git config --global core.excludesfile ~/.gitignore_global
git config --global user.email "lebresne@gmail.com"
git config --global user.name "Sylvain Lebresne"
```
Also create the `~/.gitignore_global` file and set `user.email` locally for work.
