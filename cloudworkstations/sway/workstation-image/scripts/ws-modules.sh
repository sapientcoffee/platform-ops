#!/bin/bash
# =============================================================================
# ws-modules.sh — Check if a module is enabled
# =============================================================================
# Source this in boot scripts: . /home/user/.local/bin/ws-modules.sh
#
# Usage:
#   if ws_module_enabled "ai-tools"; then
#       # install AI tools
#   fi
#
# Profiles:
#   minimal  = core,desktop
#   dev      = core,desktop,tmux,ai-tools-minimal
#   ai       = core,desktop,tmux,ides,ai-tools
#   full     = core,desktop,tmux,ides,ai-tools,languages,tailscale
#   custom   = user-specified modules via --modules flag
#
# If no config file exists, all modules are considered enabled
# (backwards compatible with pre-composable installs).
# =============================================================================

WS_MODULES_FILE="/home/user/.ws-modules"

ws_module_enabled() {
    local module="$1"
    # If no config file, assume full profile (backwards compatible)
    if [ ! -f "$WS_MODULES_FILE" ]; then
        return 0  # enabled
    fi
    local modules
    modules=$(grep "^modules=" "$WS_MODULES_FILE" | cut -d= -f2)
    echo ",$modules," | grep -q ",$module,"
}

ws_get_profile() {
    if [ ! -f "$WS_MODULES_FILE" ]; then
        echo "full"
        return
    fi
    grep "^profile=" "$WS_MODULES_FILE" | cut -d= -f2
}
