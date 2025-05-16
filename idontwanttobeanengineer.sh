#!/bin/bash

set -e

# Check if run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root."
    exit 1
fi

# List available drives
echo "Available drives:"
lsblk -dno name,size,type | grep disk

# Prompt user to select drive
read -p "Enter the drive to install Arch Linux on (e.g., /dev/sda): " DRIVE

# Confirm drive selection
read -p "Are you sure you want to install on $DRIVE? This will erase all data. [y/N] " CONFIRM
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    echo "Installation aborted."
    exit 1
fi

# Determine UEFI or BIOS
if [ -d "/sys/firmware/efi" ]; then
    UEFI=1
    echo "UEFI detected."
else
    UEFI=0
    echo "BIOS detected."
fi

# Partition the drive
echo "Partitioning $DRIVE..."
if [ $UEFI -eq 1 ]; then
    # UEFI: GPT with EFI and root partitions
    parted --script "$DRIVE" mklabel gpt
    parted --script "$DRIVE" mkpart primary fat32 1MiB 513MiB
    parted --script "$DRIVE" set 1 esp on
    parted --script "$DRIVE" mkpart primary ext4 513MiB 100%
    EFI_PARTITION="${DRIVE}1"
    ROOT_PARTITION="${DRIVE}2"
else
    # BIOS: MBR with root partition
    parted --script "$DRIVE" mklabel msdos
    parted --script "$DRIVE" mkpart primary ext4 1MiB 100%
    parted --script "$DRIVE" set 1 boot on
    ROOT_PARTITION="${DRIVE}1"
fi

# Format partitions
echo "Formatting partitions..."
if [ $UEFI -eq 1 ]; then
    mkfs.fat -F32 "$EFI_PARTITION"
fi
mkfs.ext4 "$ROOT_PARTITION"

# Mount partitions
echo "Mounting partitions..."
mount "$ROOT_PARTITION" /mnt
if [ $UEFI -eq 1 ]; then
    mkdir -p /mnt/boot
    mount "$EFI_PARTITION" /mnt/boot
fi

# Install base system
echo "Installing base system..."
pacstrap /mnt base linux linux-firmware nano networkmanager

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Prompt for passwords and username
read -s -p "Enter root password: " ROOT_PASSWORD
echo
read -s -p "Confirm root password: " ROOT_PASSWORD_CONFIRM
echo
if [ "$ROOT_PASSWORD" != "$ROOT_PASSWORD_CONFIRM" ]; then
    echo "Passwords do not match. Exiting."
    exit 1
fi

read -p "Enter username: " USERNAME
read -s -p "Enter user password: " USER_PASSWORD
echo
read -s -p "Confirm user password: " USER_PASSWORD_CONFIRM
echo
if [ "$USER_PASSWORD" != "$USER_PASSWORD_CONFIRM" ]; then
    echo "Passwords do not match. Exiting."
    exit 1
fi

# Configure the system via chroot
arch-chroot /mnt /bin/bash <<EOF
# Hostname
echo "arch" > /etc/hostname
echo "127.0.0.1   localhost" >> /etc/hosts
echo "::1         localhost" >> /etc/hosts
echo "127.0.1.1   arch.localdomain arch" >> /etc/hosts

# Locale
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Timezone
ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
hwclock --systohc

# Initramfs
mkinitcpio -P

# Bootloader
if [ $UEFI -eq 1 ]; then
    pacman -S --noconfirm efibootmgr
    bootctl install
    echo "default arch" > /boot/loader/loader.conf
    echo "timeout 3" >> /boot/loader/loader.conf
    echo "editor 0" >> /boot/loader/loader.conf
    cat <<END > /boot/loader/entries/arch.conf
title Arch Linux
linux /vmlinuz-linux
initrd /initramfs-linux.img
options root=UUID=$(blkid -s UUID -o value $ROOT_PARTITION) rw
END
else
    pacman -S --noconfirm grub
    grub-install --target=i386-pc $DRIVE
    grub-mkconfig -o /boot/grub/grub.cfg
fi

# Set root password
echo -e "$ROOT_PASSWORD\n$ROOT_PASSWORD" | passwd root

# Create user
useradd -m -G wheel -s /bin/bash $USERNAME
echo -e "$USER_PASSWORD\n$USER_PASSWORD" | passwd $USERNAME

# Install XFCE and enable services
pacman -S --noconfirm xfce4 xfce4-goodies lightdm lightdm-gtk-greeter network-manager-applet sudo
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
systemctl enable NetworkManager
systemctl enable lightdm
EOF

# Unmount and reboot
echo "Installation complete. Unmounting and rebooting..."
umount -R /mnt
reboot
