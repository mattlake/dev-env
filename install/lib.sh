# shellcheck shell=bash
# Helpers shared by the Unix installers. Sourced, not run.
#
# The sourcing script's header comment, from line 2 to the first blank line,
# doubles as its --help text.

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="$HOME/.dev-env-backup/$(date +%Y%m%d-%H%M%S)"
DRY_RUN=false
LINKS_ONLY=false

# shellcheck disable=SC2034  # LINKS_ONLY is read by the sourcing installer
for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=true ;;
        --links)   LINKS_ONLY=true ;;
        -h|--help) sed -n '2,/^$/p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) echo "unknown argument: $arg" >&2; exit 2 ;;
    esac
done

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m warn\033[0m %s\n' "$*" >&2; }
ok()   { printf '      ok: %s\n' "$*"; }
run()  { if $DRY_RUN; then printf '      would run: %s\n' "$*"; else "$@"; fi; }

# link <source-in-repo> <target-in-home>
link() {
    local src="$REPO/$1" dest="$2"

    if [[ ! -e $src ]]; then
        warn "missing in repo, skipping: $1"
        return
    fi

    if [[ -L $dest && "$(readlink "$dest")" == "$src" ]]; then
        ok "${dest/#$HOME/~}"
        return
    fi

    # Anything already there gets moved aside, including a broken or
    # wrong-target symlink.
    if [[ -e $dest || -L $dest ]]; then
        if $DRY_RUN; then
            printf '      would back up: %s\n' "${dest/#$HOME/~}"
        else
            mkdir -p "$BACKUP_DIR/$(dirname "${dest#"$HOME"/}")"
            mv "$dest" "$BACKUP_DIR/${dest#"$HOME"/}"
            warn "backed up existing ${dest/#$HOME/~} to ${BACKUP_DIR/#$HOME/~}"
        fi
    fi

    run mkdir -p "$(dirname "$dest")"
    run ln -sfn "$src" "$dest"
    printf '      linked: %s -> %s\n' "${dest/#$HOME/~}" "$1"
}

# WezTerm is deliberately absent: under WSL it runs on the Windows side and
# reads its config from there.
link_shared() {
    link shared/zsh/.zshrc                "$HOME/.zshrc"
    link shared/nvim                      "$HOME/.config/nvim"
    link shared/jetbrains/.ideavimrc      "$HOME/.ideavimrc"
    link shared/herdr/config.toml         "$HOME/.config/herdr/config.toml"
    link shared/git/.gitconfig            "$HOME/.gitconfig"
    link shared/git/ignore                "$HOME/.config/git/ignore"
}
