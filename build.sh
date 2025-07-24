#!/bin/bash
set -euo pipefail

source config.sh

# check if archiso installed
if ! pacman -Q archiso &> /dev/null; then
    echo "archiso not installed. installing..."
    sudo pacman -S --needed archiso
fi

LIVE_DIR="archlive"
rm -rf "$LIVE_DIR"
cp -r /usr/share/archiso/configs/releng "$LIVE_DIR"

# add packages for xfce
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

# copy theme files if they exist
mkdir -p "$LIVE_DIR/airootfs/usr/share/fonts/"
mkdir -p "$LIVE_DIR/airootfs/usr/share/icons/"
mkdir -p "$LIVE_DIR/airootfs/usr/share/themes/"
mkdir -p "$LIVE_DIR/airootfs/usr/share/backgrounds/"
mkdir -p "$LIVE_DIR/airootfs/home/archiso/.config/gtk-3.0"

[ -d themes/TWM-fonts ] && cp -r themes/TWM-fonts "$LIVE_DIR/airootfs/usr/share/fonts/" || echo "warning: TWM-fonts not found"
[ -d themes/TWM-icons ] && cp -r themes/TWM-icons "$LIVE_DIR/airootfs/usr/share/icons/" || echo "Warning: TWM-icons not found"
[ -d themes/TWM-theme ] && cp -r themes/TWM-theme "$LIVE_DIR/airootfs/usr/share/themes/" || echo "warning: TWM-theme not found"
[ -f themes/TW-Wallpapers/TW.png ] && cp themes/TW-Wallpapers/TW.png "$LIVE_DIR/airootfs/usr/share/backgrounds/" || echo "Warning: TW.png not found"
[ -f themes/gtk.css ] && cp themes/gtk.css "$LIVE_DIR/airootfs/home/archiso/.config/gtk-3.0/" || echo "warning: gtk.css not found"

mkdir -p "$LIVE_DIR/airootfs/usr/lib/systemd/system/"
mkdir -p "$LIVE_DIR/airootfs/etc/systemd/system/graphical.target.wants/"

cp scripts/liveenv.service "$LIVE_DIR/airootfs/usr/lib/systemd/system/liveenv.service"
sudo ln -s "$LIVE_DIR/airootfs/usr/lib/systemd/system/liveenv.service" "$LIVE_DIR/airootfs/etc/systemd/system/graphical.target.wants/liveenv.service"

cp scripts/customize_airootfs.sh "$LIVE_DIR/airootfs/root/customize_airootfs.sh"
chmod +x "$LIVE_DIR/airootfs/root/customize_airootfs.sh"

# build iso
sudo mkarchiso -v -w "$LIVE_DIR/work" -o "$LIVE_DIR/out" "$LIVE_DIR"

# font cache update
if [ -d "$LIVE_DIR/airootfs/usr/share/fonts/" ]; then
  echo "updating font cache..."
  fc-cache -rv "$LIVE_DIR/airootfs/usr/share/fonts/"
fi

ISO_PATH=$(find "$LIVE_DIR/out" -name "*.iso" | head -n1)
echo "custom iso built at $ISO_PATH"
