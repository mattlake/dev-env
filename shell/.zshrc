# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

setopt HIST_SAVE_NO_DUPS
setopt INC_APPEND_HISTORY

# config helpers
alias zshrc='nvim ~/.zshrc'

# Navigation
setopt autocd
autoload -U compinit; compinit
alias cd='z'
alias l='ls -lah'
alias la='ls -lAh'
alias ll='ls -lh'
alias ls='ls -G'
alias lsa='ls -lah'

#fzf bindings
source <(fzf --zsh)

# zoxide aliases
alias j='z'
alias jj='zi'

alias lzg='lazygit'
alias lzd='lazydocker'

# Tools
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"
