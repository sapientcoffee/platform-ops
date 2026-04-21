#!/bin/bash
# =============================================================================
# 09-snippets.sh — Deploy snippet picker script and default config
# =============================================================================
# Installs snippet-picker to ~/.local/bin/ and default snippets.conf to
# ~/.config/snippets/. Does NOT overwrite existing snippets.conf to
# preserve user customizations.
# =============================================================================

USER="user"
HOME_DIR="/home/user"
REPO_DIR="$HOME_DIR/Apps/cloud-workstations/workstation-image"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [09-snippets] $1"; }

# --- Deploy snippet-picker script ---
runuser -u $USER -- mkdir -p "$HOME_DIR/.local/bin"
cp "$REPO_DIR/scripts/snippet-picker" "$HOME_DIR/.local/bin/snippet-picker"
chmod +x "$HOME_DIR/.local/bin/snippet-picker"
chown $USER:$USER "$HOME_DIR/.local/bin/snippet-picker"
log "Deployed snippet-picker to ~/.local/bin/"

# --- Deploy default snippets.conf (no-clobber) ---
runuser -u $USER -- mkdir -p "$HOME_DIR/.config/snippets"
if [ ! -f "$HOME_DIR/.config/snippets/snippets.conf" ]; then
    cp "$REPO_DIR/configs/snippets/snippets.conf" "$HOME_DIR/.config/snippets/snippets.conf"
    chown $USER:$USER "$HOME_DIR/.config/snippets/snippets.conf"
    log "Deployed default snippets.conf to ~/.config/snippets/"
else
    log "snippets.conf already exists — preserving user customizations"
fi
