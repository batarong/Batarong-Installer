#!/bin/bash
set -e -u

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

# Configure sudo access for wheel group
echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/wheel

# Enable LightDM service for graphical login
systemctl enable lightdm.service

# Set graphical target as default
systemctl set-default graphical.target

# Create display-manager service link (standard practice)
ln -sf /usr/lib/systemd/system/lightdm.service /etc/systemd/system/lightdm.service

# xfce stuff
if command -v xfconf-query &>/dev/null; then
  su - batarong -c 'xfconf-query -c xsettings -p /Net/ThemeName -s "TWM-theme"' || true
  su - batarong -c 'xfconf-query -c xsettings -p /Net/IconThemeName -s "TWM"' || true
  su - batarong -c 'xfconf-query -c xsettings -p /Gtk/FontName -s "terminus Medium 11"' || true
  su - batarong -c 'xfconf-query -c xsettings -p /Gtk/MonospaceFontName -s "Terminus Bold 11"' || true
  su - batarong -c 'xfconf-query -c xfwm4 -p /general/theme -s "TWM-theme"' || true
  su - batarong -c 'xfconf-query -c xfwm4 -p /general/title_font -s "terminus Bold 15"' || true
  su - batarong -c 'xfconf-query -c xfwm4 -p /general/title_alignment -s "left"' || true
  su - batarong -c 'xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/last-image -s /usr/share/backgrounds/TW.png' || true
else
  echo "warning: xfconf-query not found. xfce settings might not work"
fi



