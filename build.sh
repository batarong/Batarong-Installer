#!/bin/bash
set -euo pipefail

# Load configuration
source config.sh

# Step 1: Check if archiso is installed
if ! pacman -Q archiso &> /dev/null; then
    echo "archiso is not installed. Installing..."
    sudo pacman -S --needed archiso
fi

# Step 2: Set up archlive directory
LIVE_DIR="archlive"
rm -rf "$LIVE_DIR"
cp -r /usr/share/archiso/configs/releng "$LIVE_DIR"

# Step 3: Add extra packages for XFCE and utilities
cat <<EOF >> "$LIVE_DIR/packages.x86_64"
xfce4
xfce4-goodies
lightdm
lightdm-gtk-greeter
xorg-server
firefox
thunar
xfce4-terminal
network-manager-applet
xorg-xinit
EOF

# Step 4: Copy theme files (if present)
mkdir -p "$LIVE_DIR/airootfs/usr/share/fonts/"
mkdir -p "$LIVE_DIR/airootfs/usr/share/icons/"
mkdir -p "$LIVE_DIR/airootfs/usr/share/themes/"
mkdir -p "$LIVE_DIR/airootfs/usr/share/backgrounds/"
mkdir -p "$LIVE_DIR/airootfs/home/archiso/.config/gtk-3.0"

[ -d themes/TWM-fonts ] && cp -r themes/TWM-fonts "$LIVE_DIR/airootfs/usr/share/fonts/" || echo "Warning: TWM-fonts not found."
[ -d themes/TWM-icons ] && cp -r themes/TWM-icons "$LIVE_DIR/airootfs/usr/share/icons/" || echo "Warning: TWM-icons not found."
[ -d themes/TWM-theme ] && cp -r themes/TWM-theme "$LIVE_DIR/airootfs/usr/share/themes/" || echo "Warning: TWM-theme not found."
[ -f themes/TW-Wallpapers/TW.png ] && cp themes/TW-Wallpapers/TW.png "$LIVE_DIR/airootfs/usr/share/backgrounds/" || echo "Warning: TW.png not found."
[ -f themes/gtk.css ] && cp themes/gtk.css "$LIVE_DIR/airootfs/home/archiso/.config/gtk-3.0/" || echo "Warning: gtk.css not found."

# Step 5: Configure LightDM for auto-login
mkdir -p "$LIVE_DIR/airootfs/etc/lightdm"
cat <<EOF > "$LIVE_DIR/airootfs/etc/lightdm/lightdm.conf"
[Seat:*]
autologin-user=archiso
autologin-session=xfce
EOF

# Step 6: Copy customization script
cp scripts/customize_airootfs.sh "$LIVE_DIR/airootfs/root/customize_airootfs.sh"
chmod +x "$LIVE_DIR/airootfs/root/customize_airootfs.sh"

# Step 7: Build the ISO
sudo mkarchiso -v -w "$LIVE_DIR/work" -o "$LIVE_DIR/out" "$LIVE_DIR"

# Step 8: Update font cache in the live system
if [ -d "$LIVE_DIR/airootfs/usr/share/fonts/" ]; then
  echo "Updating font cache in airootfs..."
  fc-cache -rv "$LIVE_DIR/airootfs/usr/share/fonts/"
fi

ISO_PATH=$(find "$LIVE_DIR/out" -name "*.iso" | head -n1)
echo "Custom ISO built at $ISO_PATH"
