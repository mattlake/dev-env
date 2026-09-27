# --- zinit ---
source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"

# Annexes must load before plugins
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

# compinit must run before fzf-tab
autoload -Uz compinit && compinit

zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting
zinit light Aloxaf/fzf-tab
zinit light jeffreytse/zsh-vi-mode

# --- PATH ---
# `go install` targets $GOPATH/bin (dlv, goimports, gofumpt, air, mockgen)
export PATH="$HOME/.local/bin:$HOME/scripts:$HOME/go/bin:$PATH"

if [[ "$OSTYPE" == darwin* ]]; then
    # macOS only: /etc/paths.d/go (root-owned) puts the stale /usr/local/go
    # install on PATH. Homebrew's go at /usr/local/bin currently wins by
    # ordering alone, so drop the stale entry to stop a brew unlink silently
    # downgrading the toolchain.
    path=(${path:#/usr/local/go/bin})
fi

# --- Environment ---
export EDITOR=nvim
export VISUAL=nvim
export TERM=xterm-256color
export EZA_CONFIG_DIR="$HOME/.config/eza"

# --- History ---
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt hist_ignore_dups
setopt hist_ignore_space
setopt share_history
setopt inc_append_history

# --- Shell options ---
setopt autocd
setopt nocaseglob
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# --- fzf ---
# `fzf --zsh` emits both key-bindings and completion, and resolves wherever fzf
# is installed. The old /usr/share/doc/fzf/examples paths were Debian-only and
# silently no-op'd on macOS.
command -v fzf >/dev/null && source <(fzf --zsh)

# --- zoxide ---
eval "$(zoxide init zsh)"
alias j=z
alias jj=zi

# --- Aliases ---
alias ll='eza -lah --icons=always'
alias l='eza -lah --icons=always'
alias lt='eza -lahT --icons=always'
alias ..='cd ..'
alias c='clear'
alias lzg='lazygit'
alias lzd='lazydocker'
alias fzv='nvim $(fzf)'
alias pwgen='pwgen -s 32 1'

# --- Starship prompt ---
eval "$(starship init zsh)"

[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Terminal tab titles: command name while running, current dir when idle
function preexec() {
	printf '\e]0;%s\a' "${1%% *}"
}
function precmd() {
	print -Pn '\e]0;%1~\a'
}

# Fix Claude Code rendering corruption in WezTerm (alternate screen buffer mode)
export CLAUDE_CODE_NO_FLICKER=1
