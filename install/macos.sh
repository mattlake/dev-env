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

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="$HOME/.dev-env-backup/$(date +%Y%m%d-%H%M%S)"
DRY_RUN=false
LINKS_ONLY=false

for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=true ;;
        --links)   LINKS_ONLY=true ;;
        -h|--help) sed -n '2,12p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) echo "unknown argument: $arg" >&2; exit 2 ;;
    esac
done

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m warn\033[0m %s\n' "$*" >&2; }
run()  { if $DRY_RUN; then printf '      would run: %s\n' "$*"; else "$@"; fi; }

# link <source-in-repo> <target-in-home>
link() {
    local src="$REPO/$1" dest="$2"

    if [[ ! -e $src ]]; then
        warn "missing in repo, skipping: $1"
        return
    fi

    # Already correct? Nothing to do.
    if [[ -L $dest && "$(readlink "$dest")" == "$src" ]]; then
        printf '      ok: %s\n' "${dest/#$HOME/~}"
        return
    fi

    # Anything already there gets moved aside, including a broken or
    # wrong-target symlink.
    if [[ -e $dest || -L $dest ]]; then
        if $DRY_RUN; then
            printf '      would back up: %s\n' "${dest/#$HOME/~}"
        else
            mkdir -p "$BACKUP_DIR/$(dirname "${dest#$HOME/}")"
            mv "$dest" "$BACKUP_DIR/${dest#$HOME/}"
            warn "backed up existing ${dest/#$HOME/~} to ${BACKUP_DIR/#$HOME/~}"
        fi
    fi

    run mkdir -p "$(dirname "$dest")"
    run ln -sfn "$src" "$dest"
    printf '      linked: %s -> %s\n' "${dest/#$HOME/~}" "$1"
}

if ! $LINKS_ONLY; then
    info "Homebrew"
    if ! command -v brew >/dev/null; then
        run /bin/bash -c \
            "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        printf '      ok: already installed\n'
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
        printf '      ok: already cloned\n'
    fi

    info "starship (not a brew formula on this machine)"
    if ! command -v starship >/dev/null; then
        run /bin/sh -c "$(curl -fsSL https://starship.rs/install.sh)"
    else
        printf '      ok: already installed\n'
    fi
fi

info "Symlinks: shared"
link shared/zsh/.zshrc                "$HOME/.zshrc"
link shared/nvim                      "$HOME/.config/nvim"
link shared/wezterm/.wezterm.lua      "$HOME/.wezterm.lua"
link shared/jetbrains/.ideavimrc      "$HOME/.ideavimrc"

info "Symlinks: macOS"
link macos/aerospace/aerospace.toml   "$HOME/.config/aerospace/aerospace.toml"
link macos/sketchybar                 "$HOME/.config/sketchybar"

info "Services"
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

cat <<'EOF'

Done. Remaining manual steps, which cannot be scripted:

  * AeroSpace: grant Accessibility permission on first launch
    (System Settings > Privacy & Security > Accessibility)
  * Raycast: settings live in Raycast's own cloud sync, not in this repo.
    Sign in to restore extensions and hotkeys.
  * Machine-local overrides are intentionally untracked. Create them if wanted:
      ~/.zshrc.local          sourced at the end of .zshrc
      ~/.wezterm.local.lua    see shared/wezterm/.wezterm.local.lua.example
EOF
