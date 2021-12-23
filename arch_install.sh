# == MY ARCH SETUP INSTALLER == #
#part1
echo "Welcome to Arch Linux Magic Script"
pacman --noconfirm -Sy archlinux-keyring
loadkeys us
timedatectl set-ntp true
lsblk
echo "Enter the drive: "
read drive
cfdisk $drive 
lsblk
echo "Enter the linux partition: "
read partition
mkfs.ext4 $partition
read -p "Did you also create efi partition? [y/n]" answer
lsblk
if [[ $answer = y ]] ; then
  echo "Enter EFI partition: "
  read efipartition
  mkfs.vfat -F 32 $efipartition
fi
mount $partition /mnt 
pacstrap /mnt base base-devel linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab
sed '1,/^#part2$/d' arch-linux-magic > /mnt/arch_install2.sh
chmod +x /mnt/arch_install2.sh
arch-chroot /mnt ./arch_install2.sh
exit 

#part2
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=us" > /etc/vconsole.conf
echo "Hostname: "
read hostname
echo $hostname > /etc/hostname
echo "127.0.0.1       localhost" >> /etc/hosts
echo "::1             localhost" >> /etc/hosts
echo "127.0.1.1       $hostname.localdomain $hostname" >> /etc/hosts
mkinitcpio -P
passwd
pacman --noconfirm -S grub efibootmgr os-prober
echo "Enter EFI partition: " 
read efipartition
mkdir /boot/efi
mount $efipartition /boot/efi 
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=ARCH
sed -i 's/quiet/pci=noaer/g' /etc/default/grub
# Uncomment the above line, if you don't want grub timeout
# sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

pacman -S --noconfirm xorg-server xorg-xinit xorg-xkill xorg-xsetroot xorg-xbacklight xorg-xprop \
     noto-fonts noto-fonts-emoji noto-fonts-cjk ttf-jetbrains-mono ttf-joypixels ttf-font-awesome \
     sxiv mpv zathura zathura-pdf-mupdf ffmpeg imagemagick  \
     fzf man-db xwallpaper python-pywal youtube-dl unclutter xclip maim \
     zip unzip unrar p7zip xdotool papirus-icon-theme brightnessctl  \
     dosfstools ntfs-3g git sxhkd zsh pipewire pipewire-pulse \
     vim imwheel arc-gtk-theme rsync firefox dash \
     xcompmgr polkit-gnome libnotify dunst slock jq \
     dhcpcd networkmanager rsync pamixer cowsay

read -p "Select your GPU [ 1=>Intel 2=>AMD 3=>vmware ]" gpu
if [[ $gpu = 1 ]] ; then
  pacman -S xf86-video-intel
elif [[ $gpu = 2 ]] ; then
  pacman -S xf86-video-amdgpu
elif [[ $gpu = 3 ]] ; then
  pacman -S xf86-video-vmware
fi

systemctl enable NetworkManager.service 
rm /bin/sh
ln -s dash /bin/sh
echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
echo "Enter Username: "
read username
useradd -m -G wheel -s /bin/zsh $username
passwd $username
echo "Pre-Installation Finish Reboot now"
ai3_path=/home/$username/arch_install3.sh
sed '1,/^#part3$/d' arch_install2.sh > $ai3_path
chown $username:$username $ai3_path
chmod +x $ai3_path
su -c $ai3_path -s /bin/sh $username
exit

#part3
cd $HOME
git clone --separate-git-dir=$HOME/.dotfiles --branch dotfiles https://github.com/sarveshspatil111/arch-linux-magic.git tmpdotfiles
rsync --recursive --verbose --exclude '.git' tmpdotfiles/ $HOME/
rm -r tmpdotfiles
git clone --depth=1 --branch dwm https://github.com/sarveshspatil111/arch-linux-magic.git ~/.local/src/dwm
sudo make -C ~/.local/src/dwm install
git clone --depth=1 --branch st https://github.com/sarveshspatil111/arch-linux-magic.git ~/.local/src/st
sudo make -C ~/.local/src/st install
git clone --depth=1 --branch dmenu https://github.com/sarveshspatil111/arch-linux-magic.git ~/.local/src/dmenu
sudo make -C ~/.local/src/dmenu install
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -si
cd ..
rm -rf yay-bin
yay -S libxft-bgra-git update-grub
update-grub

ln -s ~/.config/x11/xinitrc .xinitrc
ln -s ~/.config/shell/profile .zprofile
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
mv ~/.oh-my-zsh ~/.config/zsh/oh-my-zsh
rm ~/.zshrc ~/.zsh_history
mkdir -p ~/dl ~/vids ~/music ~/dox ~/code ~/pix/ss ~/pix/wall ~/.cache/zsh
touch ~/.cache/zsh/history
cd ~/pix/wall
curl -LO https://raw.githubusercontent.com/sarveshspatil111/arch-linux-magic/master/wall/1.png
curl -LO https://raw.githubusercontent.com/sarveshspatil111/arch-linux-magic/master/wall/2.png
curl -LO https://raw.githubusercontent.com/sarveshspatil111/arch-linux-magic/master/wall/3.png
curl -LO https://raw.githubusercontent.com/sarveshspatil111/arch-linux-magic/master/wall/4.png
exit
