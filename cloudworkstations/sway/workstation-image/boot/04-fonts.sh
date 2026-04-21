#!/bin/bash
# =============================================================================
# 04-fonts.sh — Install custom fonts from persistent disk
# =============================================================================
# Fonts are pre-staged at ~/boot/fonts/ (copied from dev-fonts/ in repo).
# Installs to ~/.local/share/fonts/ and rebuilds font cache.
# =============================================================================

USER="user"
FONT_SRC="/home/user/boot/fonts"
FONT_DST="/home/user/.local/share/fonts"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [04-fonts] $1"; }

if [ ! -d "$FONT_SRC" ]; then
    log "No fonts directory at $FONT_SRC — skipping"
    exit 0
fi

# Idempotent check: skip if key fonts already installed
if runuser -u $USER -- bash -c ". /home/user/.nix-profile/etc/profile.d/nix.sh && fc-list 2>/dev/null" | grep -qi "operator mono"; then
    log "Fonts already installed — skipping"
    exit 0
fi

log "Installing fonts from $FONT_SRC to $FONT_DST..."
runuser -u $USER -- mkdir -p "$FONT_DST"

# Copy all OTF and TTF files (flatten into single directory)
find "$FONT_SRC" -type f \( -name '*.otf' -o -name '*.ttf' \) -exec cp --update=none {} "$FONT_DST/" \;
chown -R $USER:$USER "$FONT_DST"

# Rebuild font cache
runuser -u $USER -- bash -c ". /home/user/.nix-profile/etc/profile.d/nix.sh && fc-cache -fv" 2>&1 | tail -5
log "Font installation complete"
