# ──────────────────────────────────────────────────────────────────────────────
# 1) Path & core settings
# ──────────────────────────────────────────────────────────────────────────────

# Use GNU tar from Homebrew
export PATH="$(brew --prefix)/opt/gnu-tar/libexec/gnubin:$PATH"
export PATH="/usr/local/sbin:$PATH"

# Hide "user@host" if default user
DEFAULT_USER="$USER"

# Color settings for ls & less
export CLICOLOR=true
export LSCOLORS="exfxcxdxbxegedabagacad"

# Load zsh’s color definitions
autoload colors && colors

# Change to directory if you type its name
setopt auto_cd

# Editor
export EDITOR="vim"

# Git diff shorthand
alias d='git diff'
alias tar='gtar'

# Disable Homebrew analytics
export HOMEBREW_NO_ANALYTICS=1

# ──────────────────────────────────────────────────────────────────────────────
# 2) History
# ──────────────────────────────────────────────────────────────────────────────

HISTFILE=$HOME/.zsh_history
HISTSIZE=50000
SAVEHIST=50000

setopt append_history
setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_verify
setopt inc_append_history
# setopt share_history    # uncomment to share history across sessions

# ──────────────────────────────────────────────────────────────────────────────
# 3) chruby & Ruby
# ──────────────────────────────────────────────────────────────────────────────

source "$(brew --prefix)/opt/chruby/share/chruby/chruby.sh"
source "$(brew --prefix)/opt/chruby/share/chruby/auto.sh"
chruby ruby-3.3.0

# ──────────────────────────────────────────────────────────────────────────────
# 4) Fast Git completion caching
# ──────────────────────────────────────────────────────────────────────────────

# Homebrew’s zsh completions directory
fpath+=( "$(brew --prefix)/share/zsh/site-functions" )

autoload -Uz compinit
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path ~/.zsh/.zcompdump
compinit

# ──────────────────────────────────────────────────────────────────────────────
# 5) zsh-autosuggestions (Homebrew)
# ──────────────────────────────────────────────────────────────────────────────

# Must be loaded immediately after compinit
source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
# optional: tweak suggestion color
# export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

# ──────────────────────────────────────────────────────────────────────────────
# 6) Pure prompt
# ──────────────────────────────────────────────────────────────────────────────

autoload -U promptinit
promptinit
prompt pure

# ──────────────────────────────────────────────────────────────────────────────
# 7) zsh-syntax-highlighting (Homebrew)
# ──────────────────────────────────────────────────────────────────────────────

# Must be last so it picks up all key bindings & prompt setup
source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# ──────────────────────────────────────────────────────────────────────────────
# 8) LESS color support
# ──────────────────────────────────────────────────────────────────────────────

export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

# ──────────────────────────────────────────────────────────────────────────────
# 9) SSH agent
# ──────────────────────────────────────────────────────────────────────────────

ssh-add --apple-use-keychain ~/.ssh/id_ed25519 2>/dev/null
ssh-add --apple-use-keychain ~/.ssh/bhamrick 2>/dev/null
