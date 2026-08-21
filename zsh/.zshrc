# =============================================================================
# Zsh configuration
# =============================================================================

# -----------------------------------------------------------------------------
# Options
# -----------------------------------------------------------------------------

setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS

# Globbing
setopt EXTENDED_GLOB

# -----------------------------------------------------------------------------
# History
# -----------------------------------------------------------------------------

HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000

setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS

# -----------------------------------------------------------------------------
# Completion
# -----------------------------------------------------------------------------

# Repository containing this configuration
DOTFILES_DIR="${${(%):-%N}:A:h:h}"

# Local completion functions
fpath=(
    "$DOTFILES_DIR/zsh/zsh-completions/src"
    $fpath
)

autoload -Uz compinit
compinit

# Case-insensitive matching
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Show descriptions
zstyle ':completion:*' verbose yes

# Interactive menu
zstyle ':completion:*' menu select

# Group completions by type
zstyle ':completion:*' group-name ''

# Cache completion results
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$HOME/.cache/zsh"

# -----------------------------------------------------------------------------
# Key bindings
# -----------------------------------------------------------------------------

bindkey -e

bindkey '\e[1;5D' backward-word
bindkey '\e[1;5C' forward-word

# -----------------------------------------------------------------------------
# Aliases
# -----------------------------------------------------------------------------

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias grep='grep --color=auto'

# Git shortcuts
alias g='git'
alias gs='git status'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git log --oneline --decorate --graph'
alias ga='git add'
alias gc='git commit'
alias gco='git checkout'
alias gb='git branch'
alias gp='git push'
alias gpl='git pull'

# -----------------------------------------------------------------------------
# Plugins
# -----------------------------------------------------------------------------

source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# -----------------------------------------------------------------------------
# fzf
# -----------------------------------------------------------------------------

if [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]]; then
    source /usr/share/doc/fzf/examples/key-bindings.zsh
fi

if [[ -f /usr/share/doc/fzf/examples/completion.zsh ]]; then
    #source /usr/share/doc/fzf/examples/completion.zsh
fi

# -----------------------------------------------------------------------------
# zoxide
# -----------------------------------------------------------------------------

eval "$(zoxide init zsh)"

# -----------------------------------------------------------------------------
# Prompt
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Git prompt
# -----------------------------------------------------------------------------

autoload -Uz vcs_info

zstyle ':vcs_info:git:*' enable git
zstyle ':vcs_info:git:*' check-for-changes true

zstyle ':vcs_info:git:*' stagedstr '+'
zstyle ':vcs_info:git:*' unstagedstr '*'

zstyle ':vcs_info:git:*' formats '[%b%c%u]'
zstyle ':vcs_info:git:*' actionformats '[%b|%a%c%u]'

# Show ahead/behind information
zstyle ':vcs_info:git:*' get-revision true
zstyle ':vcs_info:git:*' set-message true

precmd() {
    vcs_info
}

setopt PROMPT_SUBST

PROMPT='%F{cyan}%~%f %F{green}${vcs_info_msg_0_}%f %F{yellow}❯%f '

# -----------------------------------------------------------------------------
# Optional modules
# -----------------------------------------------------------------------------

# CMake / C++ workflow
# source "$DOTFILES_DIR/zsh/config/cmake.zsh"
