#!/bin/bash
# Restore /nix bind mount from persistent disk on boot
# Nix store lives on persistent HOME disk at /home/user/nix
# Container root resets on restart, so we re-create the mount each boot
# NOTE: Nix does NOT allow /nix to be a symlink — must use bind mount

if [ -d /home/user/nix ] && ! mountpoint -q /nix 2>/dev/null; then
    rm -rf /nix 2>/dev/null
    mkdir -p /nix
    mount --bind /home/user/nix /nix
    echo "Restored /nix bind mount from /home/user/nix"
fi

# Restore nvidia PATH/LD_LIBRARY_PATH for GPU access
if [ -d /var/lib/nvidia/bin ]; then
    cat > /etc/profile.d/nvidia.sh << 'EOF'
export PATH=/var/lib/nvidia/bin:$PATH
export LD_LIBRARY_PATH=/var/lib/nvidia/lib64:$LD_LIBRARY_PATH
EOF
    echo "Restored nvidia profile script"
fi
