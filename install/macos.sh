#!/usr/bin/env bash
#
# Rebuild a macOS machine from this repo.
#
# Idempotent: safe to re-run. Existing files are backed up before being
# replaced by symlinks, never silently overwritten.
#
#   ./install/macos.sh            # full run
#   ./install/macos.sh --links    # symlinks only, skip package installs
#   ./install/macos.sh --dry-run  # print what would happen, change nothing

set -euo pipefail

# shellcheck source=lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

if ! $LINKS_ONLY; then
    info "Homebrew"
    if ! command -v brew >/dev/null; then
        run /bin/bash -c \
            "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        ok "already installed"
    fi

    info "Taps requiring explicit trust"
    # brew bundle silently skips untrusted taps, so trust must come first or
    # sketchybar and borders will not install.
    run brew tap felixkratz/formulae
    run brew trust felixkratz/formulae

    info "Packages from macos/Brewfile"
    run brew bundle install --file="$REPO/macos/Brewfile"

    info "zinit (not available via brew)"
    ZINIT_HOME="$HOME/.local/share/zinit/zinit.git"
    if [[ ! -d $ZINIT_HOME ]]; then
        run mkdir -p "$(dirname "$ZINIT_HOME")"
        run git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
    else
        ok "already cloned"
    fi

    info "starship (not a brew formula on this machine)"
    if ! command -v starship >/dev/null; then
        run /bin/sh -c "$(curl -fsSL https://starship.rs/install.sh)"
    else
        ok "already installed"
    fi

    info "herdr (not a brew formula)"
    if ! command -v herdr >/dev/null && [[ ! -x $HOME/.local/bin/herdr ]]; then
        run /bin/sh -c "$(curl -fsSL https://herdr.dev/install.sh)"
    else
        ok "already installed"
    fi

    # Claude Code native build, self-updating. Cask was dropped in favour of
    # this because the native installer keeps itself current without brew.
    info "claude (native, not a brew cask)"
    if ! command -v claude >/dev/null && [[ ! -x $HOME/.local/bin/claude ]]; then
        run /bin/bash -c "$(curl -fsSL https://claude.ai/install.sh)"
    else
        ok "already installed"
    fi
fi

info "Symlinks: shared"
link_shared
link shared/wezterm/.wezterm.lua      "$HOME/.wezterm.lua"

info "Symlinks: macOS"
link macos/aerospace/aerospace.toml   "$HOME/.config/aerospace/aerospace.toml"
link macos/sketchybar                 "$HOME/.config/sketchybar"
link macos/borders                    "$HOME/.config/borders"

info "Services"
# AeroSpace has start-at-login in its config, but that only takes effect once
# the app has run at least once to register itself.
if [[ -d /Applications/AeroSpace.app ]]; then
    if pgrep -x AeroSpace >/dev/null; then
        run aerospace reload-config || warn "aerospace rejected the config"
        printf '      reloaded aerospace config\n'
    else
        run open -a AeroSpace
        printf '      started AeroSpace (grant Accessibility if prompted)\n'
    fi
else
    warn "AeroSpace.app not installed, skipping"
fi

# sketchybar lives in an untrusted tap, so `brew services` refuses to touch it
# until the tap is trusted. Trust it here too: --links skips the package phase
# where it is normally done. Neither step is fatal -- a bar that needs a manual
# restart should not fail the whole install.
if command -v sketchybar >/dev/null; then
    run brew trust felixkratz/formulae || warn "could not trust felixkratz/formulae"
    if $DRY_RUN; then
        printf '      would run: brew services restart sketchybar\n'
    elif brew services restart sketchybar >/dev/null 2>&1; then
        printf '      restarted sketchybar\n'
    else
        warn "could not restart sketchybar via brew services; reloading directly"
        pkill -x sketchybar 2>/dev/null || true
        (sketchybar >/dev/null 2>&1 &) || warn "sketchybar did not come back up, start it manually"
    fi
else
    warn "sketchybar not on PATH, skipping restart"
fi

# borders draws the focus highlight AeroSpace does not. Its formula ships a
# launchd service, so let brew own restart-on-crash and start-at-login rather
# than launching it from aerospace's after-startup-command.
if command -v borders >/dev/null; then
    if $DRY_RUN; then
        printf '      would run: brew services restart borders\n'
    elif brew services restart felixkratz/formulae/borders >/dev/null 2>&1; then
        printf '      restarted borders\n'
    else
        warn "could not restart borders via brew services; starting directly"
        pkill -x borders 2>/dev/null || true
        ("$HOME/.config/borders/bordersrc" >/dev/null 2>&1 &) \
            || warn "borders did not start, run it manually"
    fi
else
    warn "borders not on PATH, skipping"
fi

cat <<'EOF'

Done. Remaining manual steps, which cannot be scripted:

  * AeroSpace: grant Accessibility permission on first launch
    (System Settings > Privacy & Security > Accessibility)
  * Raycast: settings live in Raycast's own cloud sync, not in this repo.
    Sign in to restore extensions and hotkeys.
  * Machine-local overrides are intentionally untracked. Create them if wanted:
      ~/.zshrc.local          sourced at the end of .zshrc
      ~/.wezterm.local.lua    see shared/wezterm/.wezterm.local.lua.example
      ~/.gitconfig.local      required for [user] name/email; included by .gitconfig
EOF
