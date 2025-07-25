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
2. Run the build script:
   ```bash
   chmod +x build.sh
   ./build.sh
   ```
3. The ISO will be generated in `archlive/out/`.
4. Test the ISO in a virtual machine or write it to a USB drive using dd `dd if=example.iso of=/dev/sdx`

## Default User
The ISO includes a preconfigured user:
- **Username:** `batarong`
- **Password:** `batarong`

## Notes
- The script uses `/tmp` for temporary files and `archlive/out/` for the ISO.
- See `scripts/customize_airootfs.sh` for XFCE and theme configuration details.
- The system will automatically login as the `batarong` user on boot.

## Troubleshooting
- **Missing theme or icons:** Ensure all theme files are present in the `themes/` directory.
- **LightDM autologin not working:** Check that the `customize_airootfs.sh` script ran successfully and `/etc/lightdm/lightdm.conf` exists.
- **ISO build fails:** Make sure you have enough disk space and permissions (run with `sudo` if needed).
- **Black screen after boot:** This usually indicates a graphics driver issue. Try adding `nomodeset` kernel parameter.

## References
- [Archiso ArchWiki](https://wiki.archlinux.org/title/Archiso)
- [Xfce ArchWiki](https://wiki.archlinux.org/title/Xfce)
- [LightDM ArchWiki](https://wiki.archlinux.org/title/LightDM)
- [fdsdgfdedsx](https://en.wikipedia.org/wiki/Justin_Bieber)
