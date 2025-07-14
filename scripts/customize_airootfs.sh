#!/bin/bash
set -e -u

# xfce stuff
if command -v xfconf-query &>/dev/null; then
  su - archiso -c 'xfconf-query -c xsettings -p /Net/ThemeName -s "TWM-theme"' || true
  su - archiso -c 'xfconf-query -c xsettings -p /Net/IconThemeName -s "TWM"' || true
  su - archiso -c 'xfconf-query -c xsettings -p /Gtk/FontName -s "terminus Medium 11"' || true
  su - archiso -c 'xfconf-query -c xsettings -p /Gtk/MonospaceFontName -s "Terminus Bold 11"' || true
  su - archiso -c 'xfconf-query -c xfwm4 -p /general/theme -s "TWM-theme"' || true
  su - archiso -c 'xfconf-query -c xfwm4 -p /general/title_font -s "terminus Bold 15"' || true
  su - archiso -c 'xfconf-query -c xfwm4 -p /general/title_alignment -s "left"' || true
  su - archiso -c 'xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/last-image -s /usr/share/backgrounds/TW.png' || true
else
  echo "warning: xfconf-query not found. xfce settings might not work"
fi

systemctl enable lightdm
systemctl set-default graphical.target
systemctl set-default graphical.target
