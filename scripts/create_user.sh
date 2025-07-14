#!/bin/bash

# Create user 'batarong' with home directory
useradd -m -G wheel,audio,video,optical,storage -s /bin/bash batarong

# Set password for user (you can change this)
echo "batarong:batarong" | chpasswd

# Configure LightDM for autologin
mkdir -p /etc/lightdm
cat > /etc/lightdm/lightdm.conf << 'EOF'
[Seat:*]
autologin-user=batarong
autologin-user-timeout=0
session-wrapper=/etc/lightdm/Xsession
greeter-session=lightdm-gtk-greeter
EOF

# Enable LightDM service
systemctl enable lightdm.service

# Configure sudo access for wheel group
echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/wheel
