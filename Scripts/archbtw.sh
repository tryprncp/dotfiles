#!/bin/bash

set -e

function msg {
    echo -e "\n$1\n"
}

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

msg "Setting timezone to Asia/Manila..."
timedatectl set-timezone Asia/Manila

msg "Initializing pacman keyring..."
pacman-key --init
pacman-key --populate archlinux

msg "Partitioning the disk..."
parted /dev/nvme0n1 --script mklabel gpt
parted /dev/nvme0n1 --script mkpart primary fat32 1MiB 500MiB
parted /dev/nvme0n1 --script set 1 esp on
parted /dev/nvme0n1 --script mkpart primary ext4 500MiB 100%

msg "Creating filesystems..."
mkfs.fat -F 32 /dev/nvme0n1p1
mkfs.ext4 /dev/nvme0n1p2

msg "Updating package databases..."
pacman -Syy

msg "Installing reflector to update mirrorlist..."
pacman -S --noconfirm reflector
reflector -c "SG" -f 10 -l 10 -n 10 --save /etc/pacman.d/mirrorlist

msg "Mounting the filesystem..."
mount /dev/nvme0n1p2 /mnt

msg "Installing base system and packages..."
pacstrap /mnt base base-devel linux linux-firmware sof-firmware intel-ucode grub efibootmgr sudo networkmanager git neovim man-db --needed

msg "Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

msg "Creating chroot script..."
cat <<EOF_CHROOT > /mnt/root/chroot_script.sh
#!/bin/bash
set -e

function msg {
    echo -e "\n\$1\n"
}

msg "Setting timezone to Asia/Manila..."
timedatectl set-timezone Asia/Manila

msg "Enabling NTP..."
timedatectl set-ntp true

msg "Configuring locale..."
sed -i 's/#en_PH.UTF-8 UTF-8/en_PH.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo LANG=en_PH.UTF-8 > /etc/locale.conf
export LANG=en_PH.UTF-8

msg "Setting hostname..."
echo $HOSTNAME > /etc/hostname
cat <<HOSTS > /etc/hosts
127.0.0.1  localhost
::1  localhost
127.0.0.1  $HOSTNAME
HOSTS

msg "Setting root password..."
echo -e "$ROOT_PASSWORD\n$ROOT_PASSWORD" | passwd

msg "Configuring bootloader..."
mount --mkdir /dev/nvme0n1p1 /boot/efi
grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi
grub-mkconfig -o /boot/grub/grub.cfg

msg "Creating user and setting password..."
useradd -m $USERNAME
echo -e "$USER_PASSWORD\n$USER_PASSWORD" | passwd $USERNAME
usermod -aG wheel,audio,video,storage $USERNAME
echo "$USERNAME ALL=(ALL) ALL" | sudo tee /etc/sudoers.d/$USERNAME

msg "Enabling NetworkManager service..."
systemctl enable NetworkManager
EOF_CHROOT

if [ "$TYPE" == "2" ]; then
    echo "su - $USERNAME" >> /root/chroot_script.sh
    echo "git clone --depth 1 https://github.com/tryprncp/hyprdots HyDE ; ./HyDE/Scripts/install.sh"
fi

msg "Entering chroot and running chroot script..."
arch-chroot /mnt /bin/bash /root/chroot_script.sh

msg "Cleaning up..."
rm /mnt/root/chroot_script.sh

msg "Unmounting filesystems..."
umount -l /mnt

msg "Shutting down..."
shutdown now
