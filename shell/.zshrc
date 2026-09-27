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

# --- Environment ---
export EDITOR=nvim
export VISUAL=nvim
export TERM=xterm-256color
export EZA_CONFIG_DIR="$HOME/.config/eza"

# --- PATH ---
# /etc/paths.d/go (root-owned) puts the stale /usr/local/go install on PATH.
# Homebrew's go at /usr/local/bin currently wins by ordering only, so drop the
# stale entry to stop a brew unlink silently downgrading the toolchain.
path=(${path:#/usr/local/go/bin})

# `go install` targets $GOPATH/bin (dlv, goimports, gofumpt, air, mockgen)
export PATH="$HOME/go/bin:$PATH"

# --- Shell options ---
setopt autocd
setopt nocaseglob
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# --- fzf ---
source /usr/share/doc/fzf/examples/key-bindings.zsh 2>/dev/null
source /usr/share/doc/fzf/examples/completion.zsh 2>/dev/null

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

