#!/usr/bin/env bash
set -euo pipefail

if ! command -v mkarchiso &>/dev/null; then
  echo "installing archiso..."
  sudo pacman -S --needed archiso
fi

LIVE_DIR="$(pwd)/archlive"
echo "preparing working dir at $LIVE_DIR"
sudo rm -rf "$LIVE_DIR"
cp -r /usr/share/archiso/configs/releng "$LIVE_DIR"

echo "adding custom install scripts..."
mkdir -p "$LIVE_DIR/airootfs/root"
cp install.py "$LIVE_DIR/airootfs/root/"
chmod +x "$LIVE_DIR/airootfs/root/install.py"

echo "building custom iso..."
sudo mkarchiso -v -w "$LIVE_DIR/work" -o "$LIVE_DIR/out" "$LIVE_DIR"

echo "custom iso built at $LIVE_DIR/out"
echo "Custom ISO built at $LIVE_DIR/out"
