#!/bin/bash
# =============================================================================
# 05-shell.sh — ZSH default shell + plugins (no plugin manager)
# =============================================================================
# Sets ZSH as default shell via exec in .bashrc.
# Installs zsh-syntax-highlighting and zsh-autosuggestions via git clone.
# Creates .zshrc with Nix profile, PATH, plugins, and Starship init.
# =============================================================================

USER="user"
HOME_DIR="/home/user"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [05-shell] $1"; }

# --- Make ZSH default via .bashrc exec ---
BASHRC="$HOME_DIR/.bashrc"
if ! grep -q 'exec zsh' "$BASHRC" 2>/dev/null; then
    # Add exec zsh at the end of .bashrc (only in interactive shells)
    cat >> "$BASHRC" << 'BASHEOF'

# Launch ZSH as default shell (chsh may not work in container)
if [ -x "$HOME/.nix-profile/bin/zsh" ] && [ -z "$ZSH_VERSION" ]; then
    exec "$HOME/.nix-profile/bin/zsh"
fi
BASHEOF
    chown $USER:$USER "$BASHRC"
    log "Added ZSH exec to .bashrc"
else
    log "ZSH exec already in .bashrc — skipping"
fi

# --- Clone ZSH plugins ---
ZSH_DIR="$HOME_DIR/.zsh"
runuser -u $USER -- mkdir -p "$ZSH_DIR"

if [ ! -d "$ZSH_DIR/zsh-syntax-highlighting" ]; then
    runuser -u $USER -- git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_DIR/zsh-syntax-highlighting" 2>&1
    log "Cloned zsh-syntax-highlighting"
else
    log "zsh-syntax-highlighting already installed"
fi

if [ ! -d "$ZSH_DIR/zsh-autosuggestions" ]; then
    runuser -u $USER -- git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_DIR/zsh-autosuggestions" 2>&1
    log "Cloned zsh-autosuggestions"
else
    log "zsh-autosuggestions already installed"
fi

# --- Create .zshrc (skip if Home Manager manages it) ---
ZSHRC="$HOME_DIR/.zshrc"
if [ -L "$ZSHRC" ] && readlink "$ZSHRC" | grep -q "nix/store"; then
    log ".zshrc is managed by Home Manager — skipping creation"
else
    cat > "$ZSHRC" << 'ZSHEOF'
# =============================================================================
# ZSH Configuration — Cloud Workstation
# =============================================================================

# Nix profile
if [ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
    . "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi

# Timezone
export TZ="America/Los_Angeles"

# PATH additions
export PATH="$HOME/.npm-global/bin:$HOME/.local/bin:/var/lib/nvidia/bin:$PATH"

# History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt APPEND_HISTORY

# Key bindings (emacs mode)
bindkey -e

# Completion
autoload -Uz compinit && compinit -u

# ZSH plugins (no plugin manager — plain git clones)
if [ -f "$HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
    source "$HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

if [ -f "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
    source "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# Source ~/.env (Vertex AI config for Claude Code, etc.)
if [ -f "$HOME/.env" ]; then
    set -a
    source "$HOME/.env"
    set +a
fi

# Go
export GOROOT="$HOME/go"
export GOPATH="$HOME/gopath"
export PATH="$GOROOT/bin:$GOPATH/bin:$PATH"

# Rust
export PATH="$HOME/.cargo/bin:$PATH"

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv &>/dev/null; then
    eval "$(pyenv init -)"
fi

# rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
if command -v rbenv &>/dev/null; then
    eval "$(rbenv init -)"
fi

# tmux quick sessions (create or attach)
alias t1="tmux new-session -A -s 1"
alias t2="tmux new-session -A -s 2"
alias t3="tmux new-session -A -s 3"
alias t4="tmux new-session -A -s 4"
alias t5="tmux new-session -A -s 5"
alias t6="tmux new-session -A -s 6"
alias t7="tmux new-session -A -s 7"
alias t8="tmux new-session -A -s 8"
alias t9="tmux new-session -A -s 9"
alias t10="tmux new-session -A -s 10"

# tmux utility
alias ta="tmux attach"
alias tl="tmux list-sessions"
alias tk="tmux kill-session -t"
alias td="tmux detach"
alias tn="tmux new-session"
alias ts="tmux switch-client -t"

# Starship prompt
if command -v starship &>/dev/null; then
    eval "$(starship init zsh)"
fi

# User customizations (survives boot — never overwritten)
if [ -f "$HOME/.zshrc.local" ]; then
    source "$HOME/.zshrc.local"
fi
ZSHEOF
    chown $USER:$USER "$ZSHRC"
    log "Created .zshrc"
fi
