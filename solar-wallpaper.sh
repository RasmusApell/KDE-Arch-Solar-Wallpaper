#!/bin/bash

# Your coordinates (replace with your actual coordinates)
LAT="56.706"  # Latitude
LON="11.954"  # Longitude

WALLPAPER_DIR="$HOME/Images/Wallpapers/solar-wallpapers/island"
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

# Calculate transition periods (customized)
SUNRISE_START=$((SUNRISE))  #  At sunrise
SUNRISE_END=$(date -d "10:00" +%s)  # Fixed 10:00 AM sunrise end
SUNSET_START=$((SUNSET - 7200))    # 2 hours before sunset
SUNSET_END=$((SUNSET + 3600))      # 1 hour after sunset

# Choose wallpaper based on solar time
if [ $CURRENT_TIME -ge $SUNRISE_START ] && [ $CURRENT_TIME -lt $SUNRISE_END ]; then
    # Sunrise period (1 hour window around sunrise)
    WALLPAPER="$WALLPAPER_DIR/sunrise.jpg"
    echo "Setting sunrise wallpaper"
elif [ $CURRENT_TIME -ge $SUNRISE_END ] && [ $CURRENT_TIME -lt $SUNSET_START ]; then
    # Day time (from end of sunrise to start of sunset)
    WALLPAPER="$WALLPAPER_DIR/day.jpg"
    echo "Setting day wallpaper"
elif [ $CURRENT_TIME -ge $SUNSET_START ] && [ $CURRENT_TIME -lt $SUNSET_END ]; then
    # Sunset period (1 hour window around sunset)
    WALLPAPER="$WALLPAPER_DIR/sunset.jpg"
    echo "Setting sunset wallpaper"
else
    # Night time (from end of sunset to start of sunrise)
    WALLPAPER="$WALLPAPER_DIR/night.jpg"
    echo "Setting night wallpaper"
fi

# Check if wallpaper file exists
if [ ! -f "$WALLPAPER" ]; then
    echo "Warning: Wallpaper file $WALLPAPER not found, using day as fallback"
    WALLPAPER="$WALLPAPER_DIR/day.jpg"  # fallback
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
echo "Current time: $(date)"
echo "Sunrise: $(date -d @$SUNRISE)"
echo "Sunset: $(date -d @$SUNSET)"
echo "Wallpaper set to: $WALLPAPER"