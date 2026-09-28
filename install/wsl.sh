#!/usr/bin/env bash
#
# Rebuild the WSL Ubuntu 24.04 dev machine from this repo.
#
# Idempotent: safe to re-run. Existing files are backed up before being
# replaced by symlinks, never silently overwritten. Run as your normal user;
# it calls sudo itself.
#
#   ./install/wsl.sh            # full run
#   ./install/wsl.sh --links    # symlinks only, skip package installs
#   ./install/wsl.sh --dry-run  # print what would happen, change nothing

set -euo pipefail

# shellcheck source=lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

if [[ $EUID -eq 0 ]]; then
    echo "run as your normal user, not root: the script uses sudo where needed" >&2
    exit 1
fi

ME="$(id -un)"
IS_WSL=false
if [[ -e /proc/sys/fs/binfmt_misc/WSLInterop || -n ${WSL_DISTRO_NAME:-} ]]; then
    IS_WSL=true
fi

# Tools installed by this run must be callable later in the same run, before
# any shell rc has put them on PATH.
export DOTNET_ROOT="$HOME/.dotnet"
export PATH="$HOME/.local/bin:$HOME/go/bin:$DOTNET_ROOT:$DOTNET_ROOT/tools:$HOME/.local/share/fnm:$PATH"
# Otherwise even the read-only `dotnet --list-sdks` checks write telemetry
# files into ~/.dotnet, so --dry-run would not be change-free.
export DOTNET_CLI_TELEMETRY_OPTOUT=1 DOTNET_NOLOGO=1

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

APT_UPDATED=false

have() { command -v "$1" >/dev/null; }

# Bash suspends errexit inside anything run as the left side of ||, so every
# step called through here must chain its commands or return non-zero itself.
optional() { "$@" || warn "${*:1:2} failed, continuing; re-run to retry"; }

# Prints the packages from the arguments that dpkg does not have installed.
missing_pkgs() {
    local p
    for p in "$@"; do
        dpkg-query -W -f='${db:Status-Status}' "$p" 2>/dev/null | grep -qx installed \
            || printf '%s\n' "$p"
    done
}

apt_install() {
    if ! $APT_UPDATED; then
        run sudo apt-get update
        APT_UPDATED=true
    fi
    run sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y "$@"
}

# remote_script <url> <interpreter> [args...]
# Downloads first so a failed fetch fails the step, rather than piping an
# empty body into sh and reporting success.
remote_script() {
    local url=$1 interp=$2 file
    shift 2
    if $DRY_RUN; then
        printf '      would run: curl %s | %s %s\n' "$url" "$interp" "$*"
        return
    fi
    file="$(mktemp "$TMP/script.XXXXXX")"
    curl -fsSL --retry 2 "$url" -o "$file" || return 1
    "$interp" "$file" "$@"
}

# github_release <owner/repo> <asset-regex> <binary>
# Installs <binary> from the newest release asset matching the regex into
# ~/.local/bin. Handles .tar.gz archives and single gzipped binaries.
github_release() {
    local repo=$1 pattern=$2 bin=$3 url dir="$TMP/$3"
    if $DRY_RUN; then
        printf '      would install: %s from the latest %s release\n' "$bin" "$repo"
        return
    fi
    url="$(curl -fsSL --retry 2 "https://api.github.com/repos/$repo/releases/latest" \
        | jq -r --arg p "$pattern" \
            'first(.assets[].browser_download_url | select(test($p; "i"))) // empty')" \
        || return 1
    if [[ -z $url ]]; then
        warn "no release asset of $repo matches $pattern"
        return 1
    fi
    mkdir -p "$dir" && curl -fsSL --retry 2 "$url" -o "$dir/asset" || return 1
    case $url in
        *.tar.gz) tar -xzf "$dir/asset" -C "$dir" || return 1 ;;
        *.gz)     gunzip -c "$dir/asset" > "$dir/$bin" || return 1 ;;
    esac
    install -m 755 "$(find "$dir" -type f -name "$bin" | head -n 1)" "$HOME/.local/bin/$bin" \
        && printf '      installed: %s\n' "$bin"
}

ensure_apt_packages() {
    local packages missing
    info "apt: prerequisites for third-party repos"
    mapfile -t missing < <(missing_pkgs ca-certificates curl gnupg software-properties-common)
    if (( ${#missing[@]} )); then
        apt_install "${missing[@]}"
    else
        ok "already installed"
    fi

    info "apt: third-party repos"
    ensure_ppa neovim-ppa/unstable
    ensure_ppa longsleep/golang-backports
    ensure_docker_repo

    info "apt: packages from wsl/apt-packages"
    mapfile -t packages < <(sed 's/#.*//; s/[[:space:]]*$//; /^$/d' "$REPO/wsl/apt-packages")
    mapfile -t missing < <(missing_pkgs "${packages[@]}")
    if (( ${#missing[@]} )); then
        apt_install "${missing[@]}"
    else
        ok "all ${#packages[@]} packages installed"
    fi
}

ensure_ppa() {
    if grep -rqs "$1" /etc/apt/sources.list.d/; then
        ok "ppa:$1"
        return
    fi
    run sudo add-apt-repository -y --no-update "ppa:$1"
    APT_UPDATED=false
}

ensure_docker_repo() {
    local codename line
    if grep -rqs download.docker.com /etc/apt/sources.list.d/; then
        ok "docker apt repo"
        return
    fi
    codename="$(. /etc/os-release && echo "$VERSION_CODENAME")"
    line="deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $codename stable"
    run sudo install -m 0755 -d /etc/apt/keyrings
    run sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    run sudo chmod a+r /etc/apt/keyrings/docker.asc
    run sudo sh -c "echo '$line' > /etc/apt/sources.list.d/docker.list"
    APT_UPDATED=false
}

ensure_fd() {
    info "fd (Ubuntu ships it as fdfind)"
    if have fd; then
        ok "already on PATH"
    else
        run ln -sfn /usr/bin/fdfind "$HOME/.local/bin/fd"
    fi
}

ensure_zinit() {
    local zinit_home="$HOME/.local/share/zinit/zinit.git"
    info "zinit"
    if [[ -d $zinit_home ]]; then
        ok "already cloned"
        return
    fi
    run mkdir -p "$(dirname "$zinit_home")" \
        && run git clone https://github.com/zdharma-continuum/zinit.git "$zinit_home"
}

ensure_starship() {
    info "starship"
    if have starship; then
        ok "already installed"
        return
    fi
    remote_script https://starship.rs/install.sh sh -y -b "$HOME/.local/bin"
}

ensure_herdr() {
    info "herdr"
    if have herdr; then
        ok "already installed"
        return
    fi
    remote_script https://herdr.dev/install.sh sh
}

ensure_claude() {
    info "claude (native, self-updating)"
    if have claude; then
        ok "already installed"
        return
    fi
    remote_script https://claude.ai/install.sh bash
}

ensure_zoxide() {
    info "zoxide"
    if have zoxide; then
        ok "already installed"
        return
    fi
    remote_script https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh sh
}

# ensure_release <binary> <owner/repo> <asset-regex>
ensure_release() {
    info "$1"
    if have "$1"; then
        ok "already installed"
        return
    fi
    github_release "$2" "$3" "$1"
}

ensure_fzf() {
    info "fzf"
    # noble's fzf 0.44 predates the `fzf --zsh` that .zshrc sources.
    if fzf --zsh >/dev/null 2>&1; then
        ok "already installed"
        return
    fi
    github_release junegunn/fzf 'linux_amd64\.tar\.gz$' fzf
}

ensure_fnm() {
    info "fnm"
    if have fnm; then
        ok "already installed"
        return
    fi
    remote_script https://fnm.vercel.app/install bash \
        --install-dir "$HOME/.local/share/fnm" --skip-shell
}

ensure_node() {
    info "node (LTS via fnm)"
    if have fnm && fnm list | grep -q default; then
        ok "default $(fnm list | grep default | awk '{print $2}')"
        return
    fi
    run fnm install --lts && run fnm default lts-latest
}

ensure_dotnet_sdks() {
    local channel
    info ".NET SDKs into ~/.dotnet"
    for channel in 8.0 9.0 10.0; do
        if [[ -x $DOTNET_ROOT/dotnet ]] \
            && "$DOTNET_ROOT/dotnet" --list-sdks | grep -q "^${channel//./\\.}\."; then
            ok "SDK $channel"
            continue
        fi
        remote_script https://dot.net/v1/dotnet-install.sh bash \
            --channel "$channel" --install-dir "$DOTNET_ROOT" || return 1
    done
}

ensure_dotnet_tool() {
    info "dotnet tool $1"
    if dotnet tool list -g 2>/dev/null | awk 'NR > 2 { print $1 }' | grep -qix "$1"; then
        ok "already installed"
        return
    fi
    run dotnet tool update -g "$1"
}

# ensure_go_tool <binary> <module>
ensure_go_tool() {
    info "go: $1"
    if [[ -x $HOME/go/bin/$1 ]]; then
        ok "already installed"
        return
    fi
    run go install "$2@latest"
}

ensure_docker_group() {
    info "docker group"
    if getent group docker | cut -d: -f4 | tr ',' '\n' | grep -qx "$ME"; then
        ok "$ME is a member"
        return
    fi
    run sudo usermod -aG docker "$ME"
}

ensure_login_shell() {
    info "login shell"
    if [[ "$(getent passwd "$ME" | cut -d: -f7)" == */zsh ]]; then
        ok "already zsh"
        return
    fi
    run sudo chsh -s /usr/bin/zsh "$ME"
}

ensure_wsl_conf() {
    info "/etc/wsl.conf"
    if ! $IS_WSL; then
        warn "not running under WSL, skipping"
        return
    fi
    if cmp -s "$REPO/wsl/wsl.conf" /etc/wsl.conf; then
        ok "matches wsl/wsl.conf"
        return
    fi
    if [[ -e /etc/wsl.conf ]]; then
        run mkdir -p "$BACKUP_DIR/etc"
        run cp /etc/wsl.conf "$BACKUP_DIR/etc/wsl.conf"
        warn "backed up existing /etc/wsl.conf to ${BACKUP_DIR/#$HOME/~}/etc"
    fi
    run sudo install -m 644 "$REPO/wsl/wsl.conf" /etc/wsl.conf
}

ensure_docker_running() {
    info "docker daemon"
    # -r skips a zombie dockerd, which a failed start leaves behind.
    if pgrep -x -r R,S,D dockerd >/dev/null; then
        ok "running"
        return
    fi
    if $DRY_RUN; then
        printf '      would run: sudo service docker start\n'
        return
    fi
    # The init script reports success even when dockerd dies straight after,
    # so only a daemon that answers counts as started.
    sudo service docker start >/dev/null 2>&1 || true
    for _ in 1 2 3 4 5; do
        if sudo docker info >/dev/null 2>&1; then
            printf '      started\n'
            return
        fi
        sleep 1
    done
    warn "docker did not start; wsl.conf starts it on the next WSL boot"
}

if ! $LINKS_ONLY; then
    $DRY_RUN || sudo -v
    run mkdir -p "$HOME/.local/bin"

    ensure_apt_packages
    ensure_fd

    optional ensure_zinit
    optional ensure_starship
    optional ensure_herdr
    optional ensure_claude
    optional ensure_zoxide
    optional ensure_fzf
    optional ensure_release lazygit     jesseduffield/lazygit     '_linux_x86_64\.tar\.gz$'
    optional ensure_release lazydocker  jesseduffield/lazydocker  '_linux_x86_64\.tar\.gz$'
    optional ensure_release presenterm  mfontanini/presenterm     'x86_64-unknown-linux-gnu\.tar\.gz$'
    optional ensure_release tree-sitter tree-sitter/tree-sitter   'tree-sitter-linux-x64\.gz$'
    optional ensure_fnm
    optional ensure_node
    optional ensure_dotnet_sdks
    optional ensure_dotnet_tool dotnet-ef
    optional ensure_dotnet_tool dotnet-svcutil
    optional ensure_dotnet_tool jetbrains.resharper.globaltools
    optional ensure_go_tool dlv      github.com/go-delve/delve/cmd/dlv
    optional ensure_go_tool gofumpt  mvdan.cc/gofumpt
    optional ensure_go_tool goimports golang.org/x/tools/cmd/goimports
    optional ensure_go_tool air      github.com/air-verse/air
    optional ensure_go_tool mockgen  github.com/golang/mock/mockgen
    optional ensure_go_tool slides   github.com/maaslalani/slides

    ensure_docker_group
    ensure_login_shell
    ensure_wsl_conf
    ensure_docker_running
fi

info "Symlinks: shared"
link_shared

cat <<'EOF'

Done. Remaining manual steps, which cannot be scripted:

  * Restart WSL so the docker group and /etc/wsl.conf take effect. From
    Windows: wsl --shutdown, then reopen the terminal.
  * Machine-local overrides are intentionally untracked. Create them if wanted:
      ~/.gitconfig.local      required for [user] name/email; included by .gitconfig
      ~/.zshrc.local          sourced at the end of .zshrc
  * Add an SSH key to GitHub. The linked .gitconfig rewrites https://github.com
    to SSH, so zinit cannot fetch its plugins on first zsh start until then.
  * WezTerm and the rest of the Windows-side config come from
    install/windows.ps1, run on Windows itself.
  * win32yank.exe (Neovim's clipboard bridge) is installed on the Windows side
    and reached through the Windows PATH; nothing to do here.
EOF
