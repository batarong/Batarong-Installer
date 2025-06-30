#!/bin/bash
set -e -u

# XFCE theme, icons, fonts, wallpaper
if command -v xfconf-query &>/dev/null; then
  su - archiso -c 'xfconf-query -c xsettings -p /Net/ThemeName -s "TWM-theme"' || true
  su - archiso -c 'xfconf-query -c xsettings -p /Net/IconThemeName -s "TWM"' || true
  su - archiso -c 'xfconf-query -c xsettings -p /Gtk/FontName -s "Terminus Medium 11"' || true
  su - archiso -c 'xfconf-query -c xsettings -p /Gtk/MonospaceFontName -s "Terminus Bold 11"' || true
  su - archiso -c 'xfconf-query -c xfwm4 -p /general/theme -s "TWM-theme"' || true
  su - archiso -c 'xfconf-query -c xfwm4 -p /general/title_font -s "Terminus Bold 15"' || true
  su - archiso -c 'xfconf-query -c xfwm4 -p /general/title_alignment -s "left"' || true
  su - archiso -c 'xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/last-image -s /usr/share/backgrounds/TW.png' || true
else
  echo "Warning: xfconf-query not found. XFCE settings may not be applied."
fi

# Enable LightDM and graphical target
systemctl enable lightdm
systemctl set-default graphical.target
