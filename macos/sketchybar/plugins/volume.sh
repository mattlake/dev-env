#!/bin/bash

# Source colors
source "$CONFIG_DIR/colors.sh"

# Get current volume level
VOLUME=$(osascript -e "output volume of (get volume settings)")

# Determine icon based on volume level
if [ $VOLUME -eq 0 ]; then
    ICON="󰝟"
elif [ $VOLUME -le 33 ]; then
    ICON="󰕿"
elif [ $VOLUME -le 66 ]; then
    ICON="󰖀"
else
    ICON="󰕾"
fi

# Update the volume item
sketchybar --set volume \
    icon="$ICON" \
    label="${VOLUME}%" \
    icon.color=$BLUE \
    label.color=$TEXT
