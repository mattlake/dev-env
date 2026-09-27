#!/bin/bash
#
# Called by AeroSpace's exec-on-workspace-change. Forwards the focused
# workspace to SketchyBar as an event, which every space.* item subscribes to.
#
# AeroSpace runs exec-* callbacks with a minimal environment, so sketchybar is
# not necessarily on PATH and the Homebrew prefix differs between Intel
# (/usr/local) and Apple Silicon (/opt/homebrew) machines. Resolve it rather
# than hardcoding either.

SKETCHYBAR="$(command -v sketchybar \
    || { [ -x /opt/homebrew/bin/sketchybar ] && echo /opt/homebrew/bin/sketchybar; } \
    || { [ -x /usr/local/bin/sketchybar ] && echo /usr/local/bin/sketchybar; })"

[ -x "$SKETCHYBAR" ] || exit 0

# AEROSPACE_FOCUSED_WORKSPACE is set by AeroSpace. Passing it through means the
# receiving scripts do not each have to ask the server who has focus.
"$SKETCHYBAR" --trigger aerospace_workspace_change \
    FOCUSED_WORKSPACE="$AEROSPACE_FOCUSED_WORKSPACE"
