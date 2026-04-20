# --- zinit ---
source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"

zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting
zinit light Aloxaf/fzf-tab
zinit light jeffreytse/zsh-vi-mode

# --- Environment ---
export EDITOR=nvim
export VISUAL=nvim
export TERM=xterm-256color
export EZA_CONFIG_DIR="$HOME/.config/eza"

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
