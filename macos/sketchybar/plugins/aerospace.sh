#!/bin/bash

# Get the workspace ID passed as argument
WORKSPACE_ID=$1

# Source colors
source "$CONFIG_DIR/colors.sh"

# Get the focused workspace
FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused)

# Check if this workspace is focused
if [ "$WORKSPACE_ID" = "$FOCUSED_WORKSPACE" ]; then
    # Active workspace - highlight with blue accent
    sketchybar --set space.$WORKSPACE_ID \
        background.drawing=on \
        background.color=$ACCENT_COLOR \
        label.color=$BASE \
        icon.color=$BASE
else
    # Inactive workspace - subtle background
    sketchybar --set space.$WORKSPACE_ID \
        background.drawing=on \
        background.color=$SURFACE0 \
        label.color=$TEXT \
        icon.color=$TEXT
fi
