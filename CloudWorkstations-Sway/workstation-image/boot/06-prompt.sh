#!/bin/bash
# =============================================================================
# 06-prompt.sh — Starship prompt + foot terminal config
# =============================================================================
# Ensures Starship is available and configures foot terminal with
# Operator Mono font and Tokyo Night color scheme.
# =============================================================================

USER="user"
HOME_DIR="/home/user"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [06-prompt] $1"; }

# --- Ensure Starship is available ---
STARSHIP_PATH="$HOME_DIR/.nix-profile/bin/starship"
if [ ! -x "$STARSHIP_PATH" ]; then
    STARSHIP_PATH="$HOME_DIR/.local/bin/starship"
    if [ ! -x "$STARSHIP_PATH" ]; then
        log "Installing Starship via curl..."
        runuser -u $USER -- mkdir -p "$HOME_DIR/.local/bin"
        runuser -u $USER -- bash -c 'curl -sS https://starship.rs/install.sh | sh -s -- -y -b "$HOME/.local/bin"' 2>&1
        log "Starship installed to $HOME_DIR/.local/bin/starship"
    fi
fi
log "Starship available at: $(which starship 2>/dev/null || echo "$STARSHIP_PATH")"

# --- Create foot terminal config ---
FOOT_DIR="$HOME_DIR/.config/foot"
FOOT_INI="$FOOT_DIR/foot.ini"
runuser -u $USER -- mkdir -p "$FOOT_DIR"

cat > "$FOOT_INI" << 'EOF'
# foot terminal — Cloud Workstation
# Tokyo Night theme with Operator Mono font

[main]
font=Operator Mono Book:size=18
dpi-aware=no
pad=8x8

[scrollback]
lines=10000

[colors-dark]
# Tokyo Night
background=1a1b26
foreground=c0caf5

## Normal colors
regular0=15161e
regular1=f7768e
regular2=9ece6a
regular3=e0af68
regular4=7aa2f7
regular5=bb9af7
regular6=7dcfff
regular7=a9b1d6

## Bright colors
bright0=414868
bright1=f7768e
bright2=9ece6a
bright3=e0af68
bright4=7aa2f7
bright5=bb9af7
bright6=7dcfff
bright7=c0caf5

[key-bindings]
clipboard-copy=Control+Shift+c
clipboard-paste=Control+Shift+v
EOF
chown -R $USER:$USER "$FOOT_DIR"
log "Created foot.ini with Operator Mono Book:size=18 and Tokyo Night theme"
