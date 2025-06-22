#!/bin/bash

# Your coordinates (replace with your actual coordinates)
LAT="56.706"  # Latitude
LON="11.954"  # Longitude

WALLPAPER_DIR="$HOME/Images/Wallpapers/solar-wallpapers/lakeside"
CURRENT_TIME=$(date +%s)

# Get today's sunrise and sunset times using python-astral
SUNRISE=$(python3 -c "
from astral import LocationInfo
from astral.sun import sun
from datetime import datetime
import time

city = LocationInfo('Custom', 'Custom', 'UTC', $LAT, $LON)
s = sun(city.observer, date=datetime.now())
sunrise = s['sunrise']
print(int(sunrise.timestamp()))
")

SUNSET=$(python3 -c "
from astral import LocationInfo
from astral.sun import sun
from datetime import datetime
import time

city = LocationInfo('Custom', 'Custom', 'UTC', $LAT, $LON)
s = sun(city.observer, date=datetime.now())
sunset = s['sunset']
print(int(sunset.timestamp()))
")

# Calculate transition periods
SUNRISE_START=$((SUNRISE))  # At sunrise
SUNSET_START=$((SUNSET))    # At sunset

# Calculate image number based on time (0-9)
if [ $CURRENT_TIME -lt $SUNRISE_START ]; then
    # Night time (before sunrise) - use image 0
    IMAGE_NUM=0
    PERIOD_NAME="night"
elif [ $CURRENT_TIME -ge $SUNRISE_START ] && [ $CURRENT_TIME -lt $SUNSET_START ]; then
    # Day period (from sunrise to sunset) - evenly distribute images 0-8
    DAY_DURATION=$((SUNSET_START - SUNRISE_START))
    ELAPSED=$((CURRENT_TIME - SUNRISE_START))
    # Calculate progress as percentage (0-100)
    PROGRESS=$((ELAPSED * 100 / DAY_DURATION))
    # Map progress to image number (0 to 8)
    IMAGE_NUM=$((PROGRESS * 8 / 100))
    PERIOD_NAME="day"
else
    # Night time (after sunset) - use image 9
    IMAGE_NUM=9
    PERIOD_NAME="night"
fi

# Ensure image number is within bounds (0-9)
if [ $IMAGE_NUM -lt 0 ]; then
    IMAGE_NUM=0
elif [ $IMAGE_NUM -gt 9 ]; then
    IMAGE_NUM=9
fi

WALLPAPER="$WALLPAPER_DIR/$IMAGE_NUM.jpg"

# Check if wallpaper file exists
if [ ! -f "$WALLPAPER" ]; then
    echo "Warning: Wallpaper file $WALLPAPER not found, using 0.jpg as fallback"
    WALLPAPER="$WALLPAPER_DIR/0.jpg"  # fallback
fi

# Set wallpaper using KDE's method for all desktops and activities
qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
// Set wallpaper for all desktops
var allDesktops = desktops();
for (i=0;i<allDesktops.length;i++) {
    d = allDesktops[i];
    d.wallpaperPlugin = 'org.kde.image';
    d.currentConfigGroup = Array('Wallpaper', 'org.kde.image', 'General');
    d.writeConfig('Image', 'file://$WALLPAPER');
}

// Set wallpaper for all activities
var allActivities = activities();
for (i=0;i<allActivities.length;i++) {
    a = allActivities[i];
    a.wallpaperPlugin = 'org.kde.image';
    a.currentConfigGroup = Array('Wallpaper', 'org.kde.image', 'General');
    a.writeConfig('Image', 'file://$WALLPAPER');
}
"

# Debug info (optional - remove if you don't want logs)
echo "Setting $PERIOD_NAME wallpaper (image $IMAGE_NUM)"
echo "Current time: $(date)"
echo "Sunrise: $(date -d @$SUNRISE)"
echo "Sunset: $(date -d @$SUNSET)"
echo "Wallpaper set to: $WALLPAPER"