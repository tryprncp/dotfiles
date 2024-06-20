#!/bin/bash

set -e

echo "Choose installation type:"
read -p "1) Clean install, 2) With HyDE (default is 1): " TYPE

# Default to 1 if the user presses Enter without input
TYPE="${TYPE:-1}"

# Validate input to ensure it's either 1 or 2
if [ "$TYPE" != "1" ] && [ "$TYPE" != "2" ]; then
    echo "Invalid input. Please choose 1 or 2."
    exit 1
fi

read -p "Enter hostname: " HOSTNAME
read -s -p "Enter root password: " ROOT_PASSWORD
echo
read -p "Enter username: " USERNAME
read -s -p "Enter password for $USERNAME: " USER_PASSWORD
echo

timedatectl set-timezone Asia/Manila
pacman-key --init
pacman-key --populate archlinux
pacman -Syy
pacman -S --noconfirm reflector
reflector -c "SG" -f 10 -l 10 -n 10 --save /etc/pacman.d/mirrorlist

parted /dev/nvme0n1 --script mklabel gpt
parted /dev/nvme0n1 --script mkpart primary fat32 1MiB 500MiB
parted /dev/nvme0n1 --script set 1 esp on
parted /dev/nvme0n1 --script mkpart primary ext4 500MiB 100%

mkfs.fat -F 32 /dev/nvme0n1p1
mkfs.ext4 /dev/nvme0n1p2
mount /dev/nvme0n1p2 /mnt

pacstrap /mnt base base-devel linux linux-firmware sof-firmware intel-ucode grub efibootmgr sudo networkmanager git neovim man-db --needed

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

mount --mkdir /dev/nvme0n1p1 /boot/efi
grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi
grub-mkconfig -o /boot/grub/grub.cfg

echo -e "$ROOT_PASSWORD\n$ROOT_PASSWORD" | passwd
useradd -m $USERNAME
echo -e "$USER_PASSWORD\n$USER_PASSWORD" | passwd $USERNAME
usermod -aG wheel,audio,video,storage $USERNAME
echo "$USERNAME ALL=(ALL) ALL" | sudo tee /etc/sudoers.d/$USERNAME

systemctl enable NetworkManager
EOF_CHROOT

if [ "$TYPE" == "2" ]; then
    echo "su - $USERNAME" >> /root/chroot_script.sh
    echo "git clone --depth 1 https://github.com/tryprncp/hyprdots HyDE && ./HyDE/Scripts/install.sh" >> /root/chroot_script.sh
fi

arch-chroot /mnt /bin/bash /root/chroot_script.sh
rm /mnt/root/chroot_script.sh

umount -l /mnt
shutdown now
