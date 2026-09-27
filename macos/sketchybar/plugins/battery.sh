#!/bin/bash

# Source colors
source "$CONFIG_DIR/colors.sh"

# Get battery percentage
PERCENTAGE=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)

# Check if charging
CHARGING=$(pmset -g batt | grep 'AC Power')

# Determine icon and color based on battery level and charging status
if [[ $CHARGING != "" ]]; then
    ICON="󰂄"
    COLOR=$GREEN
elif [ $PERCENTAGE -ge 75 ]; then
    ICON="󰁹"
    COLOR=$GREEN
elif [ $PERCENTAGE -ge 50 ]; then
    ICON="󰂀"
    COLOR=$GREEN
elif [ $PERCENTAGE -ge 25 ]; then
    ICON="󰁾"
    COLOR=$YELLOW
elif [ $PERCENTAGE -ge 10 ]; then
    ICON="󰁻"
    COLOR=$RED
else
    ICON="󰁺"
    COLOR=$RED
fi

# Update the battery item
sketchybar --set battery \
    icon="$ICON" \
    label="${PERCENTAGE}%" \
    icon.color=$COLOR \
    label.color=$TEXT
