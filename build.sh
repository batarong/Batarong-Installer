#!/bin/bash
set -euo pipefail

# check if archiso installed
if ! pacman -Q archiso zip unzip &> /dev/null; then
    echo "essential packages not installed. installing..."
    sudo pacman -S --needed archiso zip unzip
fi

LIVE_DIR="archlive"
sudo rm -rf "$LIVE_DIR"
cp -r /usr/share/archiso/configs/releng "$LIVE_DIR"
rm -f "$LIVE_DIR/profiledef.sh"
cp profiledef.sh "$LIVE_DIR/profiledef.sh"
rm -f "$LIVE_DIR/pacman.conf"
cp pacman.conf "$LIVE_DIR/pacman.conf"
rm -f "$LIVE_DIR/grub/grub.cfg"
cp grub.cfg "$LIVE_DIR/grub/grub.cfg"

# add packages for xfce
cat <<EOF >> "$LIVE_DIR/packages.x86_64"
xfce4
xfce4-goodies
lightdm
lightdm-gtk-greeter
xorg-server
xorg-xinit
xorg-xauth
firefox
thunar
xfce4-terminal
network-manager-applet
dbus
fastfetch
arch-install-scripts
EOF

# Change hostname
mkdir -p "$LIVE_DIR/airootfs/etc"
cat > "$LIVE_DIR/airootfs/etc/hostname" << 'EOF'
batarong-installer
EOF

# im going insane, im insane, im crazy, crazy? i was crazy once-
mkdir -p "$LIVE_DIR/airootfs/etc/skel/"
unzip -d "$LIVE_DIR/airootfs/etc/skel/" config.zip

# fuck it, ascii and brain implosion energy
cat > "$LIVE_DIR/airootfs/ascii.txt" << 'EOF'
                   $1-:+=+
                  ::-===+
                 -:----+=+
   $2 -=-$1         -:-----=+=+
   $2-==:=$1       -:-+=-:-+=-=+
$2---+****$1     =-+$2%%+$1+=$2%%*$1++++#%%%%##
$2-:-****#$1%%%%#=--++++=++++++#%%#%%%%%%
$2===**+*#$1%%%%+===-========++++==  *++=-:.
 $2=++ -+$1   **+=--:::::::---==+== ::=*+:.:
         ***+==============+===--++$2**=..$1
        ==++++===---======++++==== $2=++-:$1
       ---=======+=+=========+==== :$2=++=$1
       ++++=*##**++++==============:$2-=+=$1
           *#%%%   #***#%%#***+++=+====
           %%%%       %%%%%
          $3*##%%%##    $1 %%%%%
       $3*++*##%%%###   *##****##
      *+-=#%%%%%#### #++*#######
      -:=*###%%%%%%**+-=*##%%####
                   *-:-+*###%%%%#
EOF

# Welcome Screen!!!

mkdir -p "$LIVE_DIR/airootfs/usr/local/bin"

cat > "$LIVE_DIR/airootfs/usr/local/bin/batarongos-welcome" << 'EOF'
#!/bin/bash
FLAG="$HOME/.batarongos_first_login_done"
if [ ! -f "$FLAG" ]; then
  clear
  cat /etc/ascii.txt
  echo ""
  echo "Welcome to BatarongOS!!!! :D"
  echo "Based on Arch Linux."
  echo "Github: https://github.com/batarong"
  touch "$FLAG"
fi
EOF

chmod 557 "$LIVE_DIR/airootfs/usr/local/bin/batarongos-welcome"

mkdir -p "$LIVE_DIR/airootfs/etc/skel"

cat > "$LIVE_DIR/airootfs/etc/skel/.bashrc" << 'EOF'
/usr/local/bin/batarongos-welcome
EOF

# copy theme files if they exist
mkdir -p "$LIVE_DIR/airootfs/usr/share/fonts/"
mkdir -p "$LIVE_DIR/airootfs/usr/share/icons/"
mkdir -p "$LIVE_DIR/airootfs/usr/share/themes/"
mkdir -p "$LIVE_DIR/airootfs/usr/share/backgrounds/"

[ -d themes/TWM-fonts ] && cp -r themes/TWM-fonts "$LIVE_DIR/airootfs/usr/share/fonts/" || echo "warning: TWM-fonts not found"
[ -d themes/TWM-icons ] && cp -r themes/TWM-icons "$LIVE_DIR/airootfs/usr/share/icons/" || echo "Warning: TWM-icons not found"
[ -d themes/TWM-theme ] && cp -r themes/TWM-theme "$LIVE_DIR/airootfs/usr/share/themes/" || echo "warning: TWM-theme not found"
[ -d themes/Wallpapers ] && cp -r themes/Wallpapers/* "$LIVE_DIR/airootfs/usr/share/backgrounds/" || echo "Warning: Wallpapers not found"


# one day, i dont know why, customize airootfs will die, keep that in mind, i designed this rhyme to explain in due time, all i know, time is a valuable thing, watch it fly by as the pendulum swings, watch it count down to the end of the day, the clock ticks features away, its so unreal, did'nt look down below, watch the time fly right out the window, trying to hold on, didn't even know, i wasted it all, just to watch you go
cp scripts/customize_airootfs.sh "$LIVE_DIR/airootfs/root/customize_airootfs.sh"
chmod +x "$LIVE_DIR/airootfs/root/customize_airootfs.sh"

# copy the install script
mkdir -p "$LIVE_DIR/airootfs/home/batarong/Desktop/"
cp scripts/install.sh "$LIVE_DIR/airootfs/home/batarong/install.sh"
chmod 557 "$LIVE_DIR/airootfs/home/batarong/install.sh"

# Copy the script that runs the install script
cp scripts/Install\ BatarongOS.sh "$LIVE_DIR/airootfs/home/batarong/Desktop/Install BatarongOS"
chmod 557 "$LIVE_DIR/airootfs/home/batarong/Desktop/Install BatarongOS"

# Make the welcome program executable
chmod +x "$LIVE_DIR/airootfs/usr/local/bin/batarongos-welcome"

# build iso
sudo mkarchiso -v -w "$LIVE_DIR/work" -o "$LIVE_DIR/out" "$LIVE_DIR"

ISO_PATH=$(find "$LIVE_DIR/out" -name "*.iso" | head -n1)
echo "custom iso built at $ISO_PATH"
