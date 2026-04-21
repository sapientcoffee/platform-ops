#!/bin/bash
# =============================================================================
# 06b-tmux.sh — Deploy tmux.conf (Tokyo Night theme)
# =============================================================================

USER="user"
HOME_DIR="/home/user"
REPO_DIR="/home/user/Apps/cloud-workstations"
TMUX_SRC="$REPO_DIR/workstation-image/configs/tmux/tmux.conf"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [06b-tmux] $1"; }

if [ -f "$TMUX_SRC" ]; then
    cp "$TMUX_SRC" "$HOME_DIR/.tmux.conf"
    chown $USER:$USER "$HOME_DIR/.tmux.conf"
    log "Deployed tmux.conf (Tokyo Night)"
else
    log "WARNING: tmux.conf source not found at $TMUX_SRC"
fi

# Deploy claude-tmux and tmux-debug scripts
SCRIPTS_DIR="$REPO_DIR/workstation-image/scripts"
runuser -u $USER -- mkdir -p "$HOME_DIR/.local/bin"

for script in claude-tmux tmux-debug; do
    if [ -f "$SCRIPTS_DIR/$script" ]; then
        cp "$SCRIPTS_DIR/$script" "$HOME_DIR/.local/bin/$script"
        chmod +x "$HOME_DIR/.local/bin/$script"
        chown $USER:$USER "$HOME_DIR/.local/bin/$script"
        log "Deployed $script"
    fi
done
