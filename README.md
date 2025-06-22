# KDE-Arch-Solar-Wallpaper

A systemd service and timer that automatically changes your KDE Plasma wallpaper based on solar time (sunrise, day, sunset, night). The script uses your local coordinates to determine the appropriate wallpaper based on the current time relative to sunrise and sunset.

## Features

- Automatically changes wallpaper every 5 minutes
- Uses solar time calculations for accurate day/night transitions
- Supports 4 wallpaper states: sunrise, day, sunset, and night
- Customizable transition periods with fixed 10:00 AM sunrise end
- Works on all displays and activities in KDE Plasma 6
- KDE Plasma 6 compatible

## System Compatibility

**This has only been tested on Arch Linux with KDE Plasma 6.**

While it may work on other distributions and desktop environments, the installation process and dependencies are specifically tailored for Arch Linux. The script uses KDE-specific D-Bus commands and may require modifications for other desktop environments.

## Prerequisites

- Arch Linux (tested)
- KDE Plasma 6 (tested)
- `python-astral` package (for solar calculations)
- `qt5-tools` package (for D-Bus communication)
- Wallpaper images in the specified directory

### Install Dependencies

```bash
sudo pacman -S python-astral qt5-tools
```

## Installation

### 1. Copy the Script

First, copy the main script to your local bin directory:

```bash
mkdir -p ~/.local/bin
cp solar-wallpaper.sh ~/.local/bin/
chmod +x ~/.local/bin/solar-wallpaper.sh
```

### 2. Copy Systemd Files

Copy the service and timer files to the systemd user directory:

```bash
mkdir -p ~/.config/systemd/user
cp solar-wallpaper.service ~/.config/systemd/user/
cp solar-wallpaper.timer ~/.config/systemd/user/
```

### 3. Reload Systemd and Enable Services

```bash
systemctl --user daemon-reload
systemctl --user enable solar-wallpaper.timer
systemctl --user start solar-wallpaper.timer
```

### 4. Verify Installation

Check that the timer is active:

```bash
systemctl --user status solar-wallpaper.timer
```

## Configuration

### 1. Set Your Coordinates

Edit `~/.local/bin/solar-wallpaper.sh` and update the latitude and longitude variables:

```bash
LAT="56.706"  # Replace with your latitude
LON="11.954"  # Replace with your longitude
```

### 2. Prepare Wallpaper Images

Create the wallpaper directory and add your images:

```bash
mkdir -p ~/Images/Wallpapers/solar-wallpapers/island
```

Add the following images to the directory:
- `sunrise.jpg` - Wallpaper for sunrise period
- `day.jpg` - Wallpaper for daytime
- `sunset.jpg` - Wallpaper for sunset period
- `night.jpg` - Wallpaper for nighttime

**Note:** The script expects wallpapers in a subdirectory (e.g., `island`, `beach`, etc.) within `solar-wallpapers/`. Update the `WALLPAPER_DIR` variable in the script to match your preferred subdirectory.

### 3. Customize Transition Times (Optional)

The script uses these transition periods:
- **Sunrise period**: From actual sunrise until 10:00 AM (fixed)
- **Day period**: From 10:00 AM until 2 hours before sunset
- **Sunset period**: 2 hours before sunset until 1 hour after sunset
- **Night period**: 1 hour after sunset until sunrise

You can modify these in the script:
```bash
SUNRISE_START=$((SUNRISE))  # At sunrise
SUNRISE_END=$(date -d "10:00" +%s)  # Fixed 10:00 AM sunrise end
SUNSET_START=$((SUNSET - 7200))    # 2 hours before sunset
SUNSET_END=$((SUNSET + 3600))      # 1 hour after sunset
```

### 4. Test the Script

Run the script manually to test:

```bash
~/.local/bin/solar-wallpaper.sh
```

## Usage

Once installed and configured, the service will automatically:

- Run every 5 minutes
- Check the current time against sunrise/sunset
- Change your wallpaper based on the solar period
- Use customizable transition windows around sunrise/sunset
- Apply changes to all displays and activities

## Troubleshooting

### Check Service Status

```bash
systemctl --user status solar-wallpaper.service
systemctl --user status solar-wallpaper.timer
```

### View Logs

```bash
journalctl --user -u solar-wallpaper.service -n 20
```

### Manual Execution

To test the script manually:

```bash
~/.local/bin/solar-wallpaper.sh
```

### Common Issues

1. **"qdbus: command not found"** - Install `qt5-tools`:
   ```bash
   sudo pacman -S qt5-tools
   ```

2. **Wallpaper not changing** - Check:
   - File paths are correct
   - Wallpaper files exist and are readable
   - KDE Plasma wallpaper plugin is set to "Image"

3. **D-Bus errors** - Ensure you're running KDE Plasma and the script has proper environment variables.

## Uninstallation

To remove the service:

```bash
systemctl --user stop solar-wallpaper.timer
systemctl --user disable solar-wallpaper.timer
rm ~/.config/systemd/user/solar-wallpaper.service
rm ~/.config/systemd/user/solar-wallpaper.timer
systemctl --user daemon-reload
```

## License

This project is open source. Feel free to modify and distribute according to your needs.