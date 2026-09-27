#!/bin/bash

# Source colors
source "$CONFIG_DIR/colors.sh"

# Get current date and time
DATETIME=$(date '+%a %b %d %H:%M')

# Update the clock item
sketchybar --set clock \
    icon="󰥔" \
    label="$DATETIME" \
    icon.color=$BLUE \
    label.color=$TEXT
