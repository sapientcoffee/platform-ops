#!/bin/bash
# =============================================================================
# ☕ remote/setup-home-manager.sh — Install and Sync Home Manager
# =============================================================================

set -euo pipefail

log() { echo "[$(date '+%H:%M:%S')] $1"; }

MODULES="${1:-core,desktop,tmux}"
IDES_ENABLED="${2:-false}"

NIX_SOURCE_FILE="${HOME}/.nix-profile/etc/profile.d/nix.sh"
if [ -f "$NIX_SOURCE_FILE" ]; then
    . "$NIX_SOURCE_FILE"
else
    echo "❌ ERROR: Nix not found. Run setup-nix.sh first."
    exit 1
fi

if ! command -v home-manager >/dev/null; then
    log "🏗️  Installing Home Manager..."
    nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
    nix-channel --update
    nix-shell '<home-manager>' -A install
fi

log "🔄 Syncing packages for modules: ${MODULES}..."

EXTRA_PACKAGES=""
if [ "$IDES_ENABLED" = "true" ]; then
    EXTRA_PACKAGES="vscode windsurf zed-editor"
fi

mkdir -p ~/.config/home-manager
cat > ~/.config/home-manager/home.nix << NIXEOF
{ config, pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;
  home.username = "user";
  home.homeDirectory = "/home/user";
  home.stateVersion = "23.11";
  home.packages = with pkgs; [
    neovim tmux tree ffmpeg git gh curl wget htop ripgrep fd jq unzip chromium google-chrome sway waybar foot wofi thunar nodejs_22
    wayvnc wl-clipboard clipman mako swaylock swayidle yadm
    ${EXTRA_PACKAGES}
  ];
  programs.home-manager.enable = true;
}
NIXEOF

log "🚀 Applying home-manager configuration..."
home-manager switch

log "✅ Packages synced"
