#!/usr/bin/env bash
set -euo pipefail


if ! command -v mkarchiso &>/dev/null; then
  echo "Installing archiso..."
  sudo pacman -S --needed archiso
fi

LIVE_DIR="$(pwd)/archlive"
echo "Preparing working directory at $LIVE_DIR"
rm -rf "$LIVE_DIR"
cp -r /usr/share/archiso/configs/releng "$LIVE_DIR"

echo "Adding custom install scripts..."
mkdir -p "$LIVE_DIR/airootfs/root"
cp install.py "$LIVE_DIR/airootfs/root/"
cp customize_airootfs.sh "$LIVE_DIR/airootfs/root/"
chmod +x "$LIVE_DIR/airootfs/root/install.py" "$LIVE_DIR/airootfs/root/customize_airootfs.sh"

echo "Building custom ISO..."
sudo mkarchiso -v -w "$LIVE_DIR/work" -o "$LIVE_DIR/out" "$LIVE_DIR"

echo "Custom ISO built at $LIVE_DIR/out"
