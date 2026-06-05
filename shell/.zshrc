# --- zinit ---
source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"

zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting
zinit light Aloxaf/fzf-tab
zinit light jeffreytse/zsh-vi-mode

# --- PATH ---
export PATH="$HOME/.local/bin:$HOME/scripts:$PATH"

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

# Terminal tab titles: command name while running, current dir when idle
function preexec() {
	printf '\e]0;%s\a' "${1%% *}"
}
function precmd() {
	print -Pn '\e]0;%1~\a'
}

# Fix Claude Code rendering corruption in WezTerm (alternate screen buffer mode)
export CLAUDE_CODE_NO_FLICKER=1
