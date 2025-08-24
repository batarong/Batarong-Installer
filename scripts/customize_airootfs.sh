#!/bin/bash
set -e -u

# Create user 'batarong' with home directory
groupadd -r autologin
useradd -m -G wheel,autologin,audio,video,optical,storage -s /bin/bash batarong

# Make batarong's home directory owned by batarong (thanks, build.sh)
chown -R batarong:batarong /home/batarong

# Make installer executable (i'm going insane)
chmod +x /home/batarong/Desktop/Install\ Batarong.sh
chmod +x /home/batarong/install.sh

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

# Change os-release (LOGO=archlinux-logo where is this and how to change)
rm -f "/usr/lib/os-release"
cat > "/usr/lib/os-release" << 'EOF'
NAME="BatarongOS"
PRETTY_NAME="BatarongOS"
ID=batarongos
ID_LIKE=arch
BUILD_ID=rolling
ANSI_COLOR="38;2;255;255;0"
HOME_URL="https://batarong.neocities.org/"
EOF

rm -rf "/etc/lightdm/lightdm.conf"
cat > "/etc/lightdm/lightdm.conf" << 'EOF'
[Seat:*]
autologin-user=batarong
autologin-user-timeout=15
session-wrapper=/etc/lightdm/Xsession
greeter-session=lightdm-gtk-greeter
EOF

# add icon pack 
#pacman -S --noconfirm papirus-icon-theme # requires fix to work in config.zip and need to merge with high contrast icon pack
#echo "INFO: Extra config can be placed here, type exit to exit and continue"
#su batarong
