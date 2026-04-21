#!/bin/bash
# F-0025: Set up Sway + wayvnc systemd services on every boot
# These services live on the ephemeral root disk and are lost on reboot,
# so this startup script recreates them before systemd starts.

echo "Setting up Sway desktop + wayvnc systemd services..."

# --- nvidia ldconfig (GPU driver libs are on ephemeral disk) ---
if [ -d /var/lib/nvidia/lib64 ]; then
    echo "/var/lib/nvidia/lib64" > /etc/ld.so.conf.d/nvidia.conf
    ldconfig
    echo "Configured nvidia ldconfig"
fi

# --- Create sway-desktop.service ---
cat > /etc/systemd/system/sway-desktop.service << 'EOF'
[Unit]
Description=Sway desktop (headless for wayvnc)
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=user
PAMName=login
Environment=WLR_BACKENDS=headless
Environment=WLR_LIBINPUT_NO_DEVICES=1
Environment=XDG_RUNTIME_DIR=/run/user/1000
Environment=XDG_SESSION_TYPE=wayland
Environment=LD_LIBRARY_PATH=/var/lib/nvidia/lib64
ExecStartPre=/bin/mkdir -p /run/user/1000
ExecStartPre=/bin/chown user:user /run/user/1000
ExecStartPre=/bin/chmod 700 /run/user/1000
ExecStart=/home/user/.nix-profile/bin/sway
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

echo "Created sway-desktop.service"

# --- Create wayvnc.service ---
cat > /etc/systemd/system/wayvnc.service << 'EOF'
[Unit]
Description=wayvnc VNC server for Sway
After=sway-desktop.service
Requires=sway-desktop.service

[Service]
Type=simple
User=user
Environment=XDG_RUNTIME_DIR=/run/user/1000
Environment=WAYLAND_DISPLAY=wayland-1
ExecStartPre=/bin/sleep 3
ExecStart=/home/user/.nix-profile/bin/wayvnc --output=HEADLESS-1 0.0.0.0 5901
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

echo "Created wayvnc.service"

# --- Enable sway-desktop and wayvnc services ---
ln -sf /etc/systemd/system/sway-desktop.service /etc/systemd/system/multi-user.target.wants/
ln -sf /etc/systemd/system/wayvnc.service /etc/systemd/system/multi-user.target.wants/
echo "Enabled sway-desktop and wayvnc services"

# --- Disable and mask TigerVNC (conflicts on port 5901) ---
# Remove the wants symlink so systemd won't auto-start TigerVNC
rm -f /etc/systemd/system/multi-user.target.wants/tigervnc.service
# Mask the service: must rm first (ln -sf fails on overlay fs with regular files)
rm -f /etc/systemd/system/tigervnc.service
ln -s /dev/null /etc/systemd/system/tigervnc.service
# Kill any already-running Xtigervnc process
pkill -f Xtigervnc 2>/dev/null || true
echo "Disabled and masked TigerVNC service (port 5901 now served by wayvnc)"

# noVNC stays enabled — it proxies port 80 -> localhost:5901,
# which wayvnc now serves instead of TigerVNC.

echo "Sway desktop setup complete."
