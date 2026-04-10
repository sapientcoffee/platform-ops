#!/bin/bash
# =============================================================================
# 07a-lang-deps.sh — Install apt build dependencies for language compilation
# =============================================================================
# Installs build-essential, SSL, zlib, and other headers needed by pyenv and
# rbenv to compile Python and Ruby from source. These packages live on the
# ephemeral Docker layer, so they must be reinstalled on every boot.
# =============================================================================

USER="user"
HOME_DIR="/home/user"
LOG_DIR="$HOME_DIR/logs"
LOG_FILE="$LOG_DIR/language-deps.log"

log() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] [07a-lang-deps] $1"
    echo "$msg"
    echo "$msg" >> "$LOG_FILE"
}

# Create log directory
runuser -u $USER -- mkdir -p "$LOG_DIR"

log "=== Language build dependency install started ==="

PACKAGES=(
    build-essential
    libssl-dev
    zlib1g-dev
    libbz2-dev
    libreadline-dev
    libsqlite3-dev
    libffi-dev
    liblzma-dev
    libncurses-dev
    libgdbm-dev
    libyaml-dev
    tk-dev
)

# Check if all packages are already installed
MISSING=()
for pkg in "${PACKAGES[@]}"; do
    if ! dpkg -s "$pkg" &>/dev/null; then
        MISSING+=("$pkg")
    fi
done

if [ ${#MISSING[@]} -eq 0 ]; then
    log "All ${#PACKAGES[@]} build dependencies already installed — skipping"
else
    log "Installing ${#MISSING[@]} missing packages: ${MISSING[*]}"
    apt-get update -qq >> "$LOG_FILE" 2>&1
    DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "${MISSING[@]}" >> "$LOG_FILE" 2>&1
    log "Package installation complete"
fi

log "=== Language build dependency install complete ==="
