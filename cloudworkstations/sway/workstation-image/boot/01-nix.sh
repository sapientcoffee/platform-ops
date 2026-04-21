#!/bin/bash
# =============================================================================
# 01-nix.sh — Restore /nix bind mount from persistent disk
# =============================================================================
# Nix store lives on persistent HOME disk at /home/user/nix.
# Container root resets on restart, so we re-create the mount each boot.
# NOTE: Nix does NOT allow /nix to be a symlink — must use bind mount.
# =============================================================================

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [01-nix] $1"; }

if mountpoint -q /nix 2>/dev/null; then
    log "/nix already mounted — skipping"
    exit 0
fi

if [ ! -d /home/user/nix ]; then
    log "WARNING: /home/user/nix not found — Nix not installed on persistent disk"
    exit 0
fi

rm -rf /nix 2>/dev/null
mkdir -p /nix
mount --bind /home/user/nix /nix
log "Restored /nix bind mount from /home/user/nix"
