#!/bin/bash
# =============================================================================
# 02-nvidia.sh — nvidia GPU driver setup (ldconfig + PATH)
# =============================================================================
# GPU driver libs are on the ephemeral disk at /var/lib/nvidia/.
# This script makes them available system-wide via ldconfig and profile.
# =============================================================================

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [02-nvidia] $1"; }

if [ ! -d /var/lib/nvidia/lib64 ]; then
    log "No nvidia drivers found at /var/lib/nvidia — skipping"
    exit 0
fi

# ldconfig for nvidia libs (so apps can find libnvidia-ml.so etc.)
if [ ! -f /etc/ld.so.conf.d/nvidia.conf ]; then
    echo "/var/lib/nvidia/lib64" > /etc/ld.so.conf.d/nvidia.conf
    ldconfig
    log "Configured nvidia ldconfig"
else
    log "nvidia ldconfig already configured"
fi

# Profile script for nvidia PATH/LD_LIBRARY_PATH
cat > /etc/profile.d/nvidia.sh << 'EOF'
export PATH=/var/lib/nvidia/bin:$PATH
export LD_LIBRARY_PATH=/var/lib/nvidia/lib64:${LD_LIBRARY_PATH:-}
EOF
log "Created nvidia profile script"
