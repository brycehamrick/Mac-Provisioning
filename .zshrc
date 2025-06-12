# ── Fast Git completion ─────────────────────────────────────────────────────
fpath+=("$(brew --prefix)/share/zsh/site-functions")

autoload -Uz compinit
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path ~/.zsh/.zcompdump
compinit

# Enable autosuggestions
source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# ── Pure prompt setup ─────────────────────────────────────────────────────
autoload -U promptinit; promptinit
prompt pure

ZSH_DISABLE_COMPFIX="true"
PATH="/usr/local/sbin:$PATH"

alias tar='gtar'
export HOMEBREW_NO_ANALYTICS=1

source /usr/local/opt/chruby/share/chruby/chruby.sh
source /usr/local/opt/chruby/share/chruby/auto.sh

chruby ruby-3.3.0
ssh-add --apple-use-keychain ~/.ssh/bhamrick 2>/dev/null

# Enable syntax highlighting last:
source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
