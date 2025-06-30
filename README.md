# Batarongos because im sleepy

## Requirements
- Arch Linux host system
- `archiso` package (`sudo pacman -S archiso`)

## Usage
1. Clone this repository:
   ```bash
   git clone <your-repo-url>
   cd Batarong-Installer
   ```
2. Place the TWM-xfce theme files in the `themes/` directory:
   - `TWM-fonts/`
   - `TWM-icons/`
   - `TWM-theme/`
   - `TW-Wallpapers/TW.png`
   - `gtk.css`
   (If any are missing, the build will warn but continue.)
3. Run the build script:
   ```bash
   chmod +x build.sh
   ./build.sh
   ```
4. The ISO will be generated in `archlive/out/`.
5. Test the ISO in a virtual machine or write it to a USB drive.

## Notes
- The script uses `/tmp` for temporary files and `archlive/out/` for the ISO.
- The TWM-xfce theme files must be present in the `themes/` directory before building for full theming.
- See `scripts/customize_airootfs.sh` for XFCE and theme configuration details.
- If you see warnings about missing theme files, add them to the `themes/` directory and rebuild.
- If fonts do not appear correctly, try updating the font cache in the live system with `fc-cache -rv`.

## Troubleshooting
- **Missing theme or icons:** Ensure all theme files are present in the `themes/` directory.
- **LightDM autologin not working:** Double-check `archlive/airootfs/etc/lightdm/lightdm.conf`.
- **XFCE settings not applied:** The script uses `xfconf-query` for configuration. If settings are missing, check the script and XFCE version compatibility.
- **ISO build fails:** Make sure you have enough disk space and permissions (run with `sudo` if needed).

## References
- [Archiso ArchWiki](https://wiki.archlinux.org/title/Archiso)
- [Xfce ArchWiki](https://wiki.archlinux.org/title/Xfce)
- [LightDM ArchWiki](https://wiki.archlinux.org/title/LightDM)
- [fdsdgfdedsx](https://en.wikipedia.org/wiki/Justin_Bieber)
