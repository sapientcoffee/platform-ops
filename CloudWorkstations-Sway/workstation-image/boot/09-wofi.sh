#!/bin/bash
# =============================================================================
# 09-wofi.sh — Deploy wofi config and Tokyo Night styling
# =============================================================================
# Copies wofi config and style.css from repo to ~/.config/wofi/
# =============================================================================

USER="user"
HOME_DIR="/home/user"
REPO_DIR="$HOME_DIR/Apps/cloud-workstations/workstation-image/configs/wofi"
WOFI_DIR="$HOME_DIR/.config/wofi"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [09-wofi] $1"; }

# --- Deploy wofi config ---
runuser -u $USER -- mkdir -p "$WOFI_DIR"

cp "$REPO_DIR/config" "$WOFI_DIR/config"
cp "$REPO_DIR/style.css" "$WOFI_DIR/style.css"
chown -R $USER:$USER "$WOFI_DIR"

log "Deployed wofi config and style.css to $WOFI_DIR"
