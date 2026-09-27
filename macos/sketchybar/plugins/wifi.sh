#!/bin/bash

# Source colors
source "$CONFIG_DIR/colors.sh"

# Get WiFi network name using ipconfig (more reliable than networksetup)
SSID=$(ipconfig getsummary en0 2>/dev/null | awk -F': ' '/SSID :/ {print $2}' | xargs)

# Fallback to checking if interface is active
if [[ $SSID == "" ]]; then
    # Check if en0 is active
    ACTIVE=$(ifconfig en0 2>/dev/null | grep "status: active")
    if [[ $ACTIVE != "" ]]; then
        # Interface is active but SSID not found, try alternative method
        SSID=$(networksetup -getairportnetwork en0 2>/dev/null | awk -F': ' '{print $2}')
    fi
fi

# Check if connected - use color as indicator, no label
if [[ $SSID == "" ]] || [[ $SSID == *"not associated"* ]] || [[ $SSID == *"You are not"* ]]; then
    ICON="󰖪"
    COLOR=$RED
else
    ICON="󰖩"
    COLOR=$GREEN
fi

# Update the wifi item (no label, just icon with color indicator)
sketchybar --set wifi \
    icon="$ICON" \
    label="" \
    icon.color=$COLOR
