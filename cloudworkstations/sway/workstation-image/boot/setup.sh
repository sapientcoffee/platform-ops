#!/bin/bash
# =============================================================================
# Master Bootstrap Script — Cloud Workstation
# =============================================================================
# Single entry point for all workstation setup logic.
# Called from /etc/workstation-startup.d/000_bootstrap.sh on boot.
# Sources all numbered sub-scripts from ~/boot/ in order.
# =============================================================================

set -euo pipefail

BOOT_DIR="/home/user/boot"
LOG_TAG="ws-bootstrap"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$LOG_TAG] $1"; }

# Source module helper for composable install gating
if [ -f /home/user/.local/bin/ws-modules.sh ]; then
    . /home/user/.local/bin/ws-modules.sh
    log "Profile: $(ws_get_profile), modules: $(grep '^modules=' "$WS_MODULES_FILE" 2>/dev/null | cut -d= -f2 || echo 'all')"
else
    # Backwards compatible: if no helper, define a no-op that always returns enabled
    ws_module_enabled() { return 0; }
    log "No ws-modules.sh found — all modules enabled (backwards compatible)"
fi

# Map script names to their module
script_module() {
    case "$1" in
        06a-tailscale.sh)               echo "tailscale" ;;
        06b-tmux.sh)                    echo "tmux" ;;
        07-apps.sh)                     echo "ai-tools" ;;
        07a-lang-deps.sh|07b-languages.sh) echo "languages" ;;
        09-wofi.sh|09-snippets.sh)      echo "desktop" ;;
        *)                              echo "core" ;;
    esac
}

log "Starting workstation bootstrap from $BOOT_DIR"

for script in "$BOOT_DIR"/[0-9][0-9]*.sh; do
    [ -f "$script" ] || continue
    script_name="$(basename "$script")"
    # Skip scripts that run via systemd
    [ "$script_name" = "08-workspaces.sh" ] && { log "Skipping $script_name (runs via systemd after Sway)"; continue; }
    [ "$script_name" = "10-tests.sh" ] && { log "Skipping $script_name (runs via systemd after all services)"; continue; }

    # Check if this script's module is enabled
    MODULE=$(script_module "$script_name")
    if [ "$MODULE" != "core" ] && ! ws_module_enabled "$MODULE"; then
        log "Skipping $script_name (module '$MODULE' not enabled)"
        continue
    fi

    log "Running $script_name..."
    if bash "$script" 2>&1; then
        log "Completed $script_name"
    else
        log "WARNING: $script_name exited with code $?"
    fi
done

log "Bootstrap complete"
