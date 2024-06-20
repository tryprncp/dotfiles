#!/bin/bash

set -e

read -p "Enter hostname: " HOSTNAME
read -s -p "Enter root password: " ROOT_PASSWORD
echo
read -p "Enter username: " USERNAME
read -s -p "Enter password for $USERNAME: " USER_PASSWORD
echo

timedatectl set-timezone Asia/Manila

pacman-key --init

pacman-key --populate archlinux

parted /dev/nvme0n1 --script mklabel gpt
parted /dev/nvme0n1 --script mkpart primary fat32 1MiB 513MiB
parted /dev/nvme0n1 --script set 1 esp on
parted /dev/nvme0n1 --script mkpart primary ext4 513MiB 100%

mkfs.fat -F 32 /dev/nvme0n1p1

mkfs.ext4 /dev/nvme0n1p2

pacman -Syy

pacman -S --noconfirm reflector
reflector -c "SG, TW, JP" -f 12 -l 10 -n 12 --save /etc/pacman.d/mirrorlist

mount /dev/nvme0n1p2 /mnt

pacstrap /mnt base linux linux-firmware sof-firmware intel-ucode neovim man-db

genfstab -U /mnt >> /mnt/etc/fstab

cat <<EOF_CHROOT > /mnt/root/chroot_script.sh
#!/bin/bash
set -e

timedatectl set-timezone Asia/Manila
timedatectl set-ntp true

sed -i 's/#en_PH.UTF-8 UTF-8/en_PH.UTF-8 UTF-8/' /etc/locale.gen

locale-gen

echo LANG=en_PH.UTF-8 > /etc/locale.conf
export LANG=en_PH.UTF-8

echo $HOSTNAME > /etc/hostname

cat <<HOSTS > /etc/hosts
127.0.0.1  localhost
::1  localhost
127.0.0.1  $HOSTNAME
HOSTS

echo -e "$ROOT_PASSWORD\n$ROOT_PASSWORD" | passwd

pacman -S --noconfirm grub efibootmgr

mkdir /boot/efi

mount /dev/nvme0n1p1 /boot/efi

grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi

grub-mkconfig -o /boot/grub/grub.cfg

pacman -S --noconfirm sudo networkmanager git

useradd -m $USERNAME

echo -e "$USER_PASSWORD\n$USER_PASSWORD" | passwd $USERNAME

usermod -aG wheel,audio,video,storage $USERNAME

echo "$USERNAME ALL=(ALL:ALL) ALL" | (EDITOR="tee -a" visudo)

systemctl enable NetworkManager

EOF_CHROOT

arch-chroot /mnt /bin/bash /root/chroot_script.sh

rm /mnt/root/chroot_script.sh

umount -l /mnt

reboot
