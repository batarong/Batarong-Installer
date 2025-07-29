#!/bin/bash
set -e -u

# Create user 'batarong' with home directory
useradd -m -G wheel,audio,video,optical,storage -s /bin/bash batarong

# Set password for user (you can change this)
echo "batarong:batarong" | chpasswd

# Configure sudo access for wheel group
echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/wheel

# Enable LightDM and NetworkManager service for graphical login
systemctl enable lightdm.service
systemctl enable NetworkManager.service

# Set graphical target as default
systemctl set-default graphical.target

# Create display-manager service link (standard practice)
ln -sf /usr/lib/systemd/system/lightdm.service /etc/systemd/system/lightdm.service

echo "INFO: Extra config can be placed here, type exit to exit and continue"
echo "INFO: Open a new tty and ssh into localhost with x11 forwarding, copy .Xauthority into batarong's home in the iso fs, run sudo mount --rbind /dev /[wherever]/Batarong-Installer/archlive/work/x86_64/airootfs/dev, chroot into thing archlive/work/x86_64/airootfs then run su batarong, and run dbus-launch xfce4-settings-manager in chroot"
echo "INFO: https://github.com/pdn6606/TWM-xfce/blob/main/README.md follow all non-optional configuration instructions."
echo "INFO: Remember to set wallpaper [/usr/share/backgrounds/] BatarongOS-Modern.png"
su batarong
sudo rm -f /home/batarong/.Xauthority