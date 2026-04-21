#!/bin/bash
# =============================================================================
# 06a-tailscale.sh — Tailscale VPN (opt-in via TAILSCALE_AUTHKEY in ~/.env)
# =============================================================================
# If TAILSCALE_AUTHKEY is set in ~/.env, starts tailscaled and authenticates.
# If not set, skips silently. State persisted to ~/.tailscale/ for reconnection.
# =============================================================================

USER="user"
HOME_DIR="/home/user"
ENV_FILE="$HOME_DIR/.env"
STATE_DIR="$HOME_DIR/.tailscale"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [06a-tailscale] $1"; }

# Check if TAILSCALE_AUTHKEY is configured
if [ -f "$ENV_FILE" ] && grep -q "TAILSCALE_AUTHKEY" "$ENV_FILE" 2>/dev/null; then
    AUTHKEY=$(grep "^TAILSCALE_AUTHKEY=" "$ENV_FILE" | cut -d'=' -f2- | tr -d '"' | tr -d "'")
    if [ -z "$AUTHKEY" ]; then
        log "TAILSCALE_AUTHKEY is empty in ~/.env — skipping"
        exit 0
    fi
else
    log "No TAILSCALE_AUTHKEY in ~/.env — Tailscale disabled (opt-in)"
    exit 0
fi

log "TAILSCALE_AUTHKEY found — starting Tailscale"

# Install tailscale if not present (ephemeral root disk wipes it on reboot)
if ! command -v tailscale >/dev/null 2>&1; then
    log "Tailscale binary not found — installing..."
    curl -fsSL https://tailscale.com/install.sh | sh 2>&1
    log "Tailscale installed"
fi

# Ensure state directory exists on persistent disk
runuser -u $USER -- mkdir -p "$STATE_DIR"

# Start tailscaled if not already running
if ! pgrep -x tailscaled >/dev/null 2>&1; then
    tailscaled --state="$STATE_DIR/tailscaled.state" --socket=/var/run/tailscale/tailscaled.sock &
    disown
    sleep 3
    log "tailscaled started"
else
    log "tailscaled already running"
fi

# Check if already connected
if tailscale status >/dev/null 2>&1; then
    IP=$(tailscale ip -4 2>/dev/null)
    log "Tailscale already connected: $IP — skipping auth"
else
    # Authenticate and connect with SSH enabled
    tailscale up --ssh --authkey="$AUTHKEY" --hostname="cloud-ws-$(hostname -s)" 2>&1
    if tailscale status >/dev/null 2>&1; then
        IP=$(tailscale ip -4 2>/dev/null)
        log "Tailscale connected: $IP"
    else
        log "WARNING: Tailscale failed to connect"
    fi
fi

# --- Set user password from ~/.env (for SSH access) ---
if grep -q "^USER_PASSWORD=" "$ENV_FILE" 2>/dev/null; then
    USER_PW=$(grep "^USER_PASSWORD=" "$ENV_FILE" | cut -d'=' -f2- | tr -d '"' | tr -d "'")
    if [ -n "$USER_PW" ]; then
        echo "$USER:$USER_PW" | chpasswd 2>/dev/null
        log "User password set from ~/.env"
    fi
fi

# --- Enable SSH password auth for Tailscale connections ---
if ! grep -q "^PasswordAuthentication yes" /etc/ssh/sshd_config 2>/dev/null; then
    sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
    pkill -HUP sshd 2>/dev/null || true
    log "SSH PasswordAuthentication enabled"
fi

# --- Allow SSH on Tailscale interface ---
if ! iptables -C INPUT -i tailscale0 -p tcp --dport 22 -j ACCEPT 2>/dev/null; then
    iptables -I INPUT -i tailscale0 -p tcp --dport 22 -j ACCEPT
    log "iptables: SSH allowed on tailscale0"
fi
