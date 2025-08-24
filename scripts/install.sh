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
if test -f "/sys/firmware/efi"; then
    parted -s "$DISK" mklabel gpt
    parted -s "$DISK" mkpart ESP fat32 1MiB 769MiB
    parted -s "$DISK" set 1 esp on
else
    parted -s "$DISK" mklabel msdos
    parted -s "$DISK" mkpart primary fat32 1MiB 769MiB
fi
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

echo "copying data to new disk, (this fucks shit up, be patient and hold still (especially if you are holding solder joints on your usb together))"

sudo rsync -aHAXS --info=progress2 --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found"} /* /mnt

echo "configuration of stuff"
genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt pacman -Syu --noconfirm grub sudo efibootmgr

arch-chroot /mnt pacman -R --noconfirm linux-zen
arch-chroot /mnt pacman -S --noconfirm linuz-zen

if test -f "/sys/firmware/efi"; then
    arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=BatarongOS --removable
else
    arch-chroot /mnt grub-install $DISK
fi

arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

echo "did the grub, yum yum."

read -p "Enter your silly username: " USERNAME
if [ "x`printf '%s' "$USERNAME" | tr -d "$IFS"`" = x ] && [ "x`printf '%s' "$PASSWORD" | tr -d "$IFS"`" = x ]; then
  echo "not very silly password/username, needs to be more silly :3 (empty or blank password/username)"
  read -p "Enter your silly username: " USERNAME
else
  arch-chroot /mnt useradd -G wheel -m -U "$USERNAME"
  arch-chroot /mnt passwd "$USERNAME"
  echo "did it cutie! :3" # no failsafe if this fails, would be shitty for the user :(
fi
echo "maybe dummy but work please, reboot and done"
