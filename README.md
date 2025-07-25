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
2. (Optional) Validate the configuration:
   ```bash
   ./validate_config.sh
   ```
3. Run the build script:
   ```bash
   chmod +x build.sh
   ./build.sh
   ```
4. The ISO will be generated in `archlive/out/`.
5. Test the ISO in a virtual machine or write it to a USB drive.

## Default User
The ISO includes a preconfigured user:
- **Username:** `batarong`
- **Password:** `batarong`


## Notes
- The script uses `/tmp` for temporary files and `archlive/out/` for the ISO.
- The TWM-xfce theme files must be present in the `themes/` directory before building for full theming.
- See `scripts/customize_airootfs.sh` for XFCE and theme configuration details.
- If you see warnings about missing theme files, add them to the `themes/` directory and rebuild.
- If fonts do not appear correctly, try updating the font cache in the live system with `fc-cache -rv`.
- The system will automatically login as the `batarong` user on boot.
- **Fixed**: LightDM is now properly enabled and the system boots to graphical target automatically.

## Recent Fixes
- **LightDM Service**: Added `systemctl enable lightdm.service` to ensure graphical login works
- **Default Target**: Set `systemctl set-default graphical.target` for proper graphical boot
- **Display Manager**: Created proper `/etc/systemd/system/display-manager.service` symlink
- **Archiso Integration**: Fixed customize script to run during chroot phase, not as boot service

## Troubleshooting
- **Missing theme or icons:** Ensure all theme files are present in the `themes/` directory.
- **LightDM autologin not working:** Check that the `customize_airootfs.sh` script ran successfully and `/etc/lightdm/lightdm.conf` exists.
- **ISO boots to text mode instead of graphical:** Run `./validate_config.sh` to check configuration. Ensure LightDM service is enabled.
- **XFCE settings not applied:** The script uses `xfconf-query` for configuration. If settings are missing, check the script and XFCE version compatibility.
- **ISO build fails:** Make sure you have enough disk space and permissions (run with `sudo` if needed).
- **Black screen after boot:** This usually indicates a graphics driver issue. Try adding `nomodeset` kernel parameter.

## References
- [Archiso ArchWiki](https://wiki.archlinux.org/title/Archiso)
- [Xfce ArchWiki](https://wiki.archlinux.org/title/Xfce)
- [LightDM ArchWiki](https://wiki.archlinux.org/title/LightDM)
- [fdsdgfdedsx](https://en.wikipedia.org/wiki/Justin_Bieber)
