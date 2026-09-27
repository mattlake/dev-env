#!/bin/bash
#
# Renders one workspace indicator. $1 is the workspace this item represents.
#
# Runs once per space item on every workspace change, so avoid asking AeroSpace
# who has focus when the event already told us: exec-on-workspace-change passes
# FOCUSED_WORKSPACE through aerospace_change.sh. Fall back to querying for the
# initial paint, where there is no event.

WORKSPACE_ID=$1

source "$CONFIG_DIR/colors.sh"

FOCUSED="${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused 2>/dev/null)}"

if [ "$WORKSPACE_ID" = "$FOCUSED" ]; then
    sketchybar --set space."$WORKSPACE_ID" \
        background.drawing=on \
        background.color="$ACCENT_COLOR" \
        label.color="$BASE" \
        icon.color="$BASE"
else
    sketchybar --set space."$WORKSPACE_ID" \
        background.drawing=on \
        background.color="$SURFACE0" \
        label.color="$TEXT" \
        icon.color="$TEXT"
fi
