#!/bin/bash
# =============================================================================
# ☕ remote/setup-nix.sh — Install Nix Package Manager
# =============================================================================

set -euo pipefail

log() { echo "[$(date '+%H:%M:%S')] $1"; }

NIX_SOURCE="[ -f ~/.nix-profile/etc/profile.d/nix.sh ] && . ~/.nix-profile/etc/profile.d/nix.sh"

if eval "${NIX_SOURCE} && command -v nix >/dev/null 2>&1"; then
    log "✅ Nix already installed"
else
    log "🏗️  Installing Nix..."
    curl -L https://nixos.org/nix/install | sh -s -- --no-daemon
    log "✅ Nix is installed"
fi
