#!/usr/bin/env bash
set -euo pipefail
read -p "Enter your disk (e.g. /dev/sdX): " DISK
BOOT_LABEL="BatarongEFI"
ROOT_LABEL="Bataroot"

[[ -b "$DISK" ]] || { echo "Device $DISK not found"; exit 1; }

echo "WIPING $DISK in 5 seconds (Ctrl+C to skedaddle)"
sleep 5

wipefs -a "$DISK"
sgdisk -Z "$DISK" || true
parted -s "$DISK" mklabel gpt
parted -s "$DISK" mkpart ESP fat32 1MiB 769MiB
parted -s "$DISK" set 1 esp on
parted -s "$DISK" set 1 boot on
parted -s "$DISK" mkpart primary ext4 769MiB 100%

if [[ "$DISK" == *"nvme"* || "$DISK" == *"mmcblk"* ]]; then
  P1="${DISK}p1"
  P2="${DISK}p2"
else
  P1="${DISK}1"
  P2="${DISK}2"
fi

mkfs.vfat -F32 -n "$BOOT_LABEL" "$P1"
mkfs.ext4 -F -L "$ROOT_LABEL" "$P2"

echo "random debug shit, also looks cool:"
lsblk "$DISK"

echo "mounting disks"
sudo mount "$P2" /mnt/
mkdir -p /mnt/boot
sudo mount "$P1" /mnt/boot

echo "copying data to new disk, (this fucks shit up, be patient)"

sudo rsync -aHAXS --info=progress2 --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found"} /* /mnt

echo "configuration of stuff"
genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt pacman -Syu --noconfirm grub sudo
arch-chroot /mnt grub-install # no failsafe, sadge :c high change could fail
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

echo "did the grub, yum yum."

read -p "Enter your silly username: " USERNAME
read -p "Enter your silly password: " PASSWORD
while [ "x`printf '%s' "$USERNAME" | tr -d "$IFS"`" = x ] && [ "x`printf '%s' "$PASSWORD" | tr -d "$IFS"`" = x ]; then
  echo "not very silly password/username, needs to be more silly :3 (empty or blank password/username)"
  read -p "Enter your silly username: " USERNAME
  read -p "Enter your silly password: " PASSWORD
else
  arch-chroot /mnt useradd -G wheel -m -U "$USERNAME"
  arch-chroot /mnt echo "$PASSWORD" && passwd "$USERNAME" --stdin
  echo "did it cutie! :3" # no failsafe if this fails, would be shitty for the user :(
fi
echo "maybe dummy but work please, reboot and done"


