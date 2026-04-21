#!/bin/bash
set -e

# --- 1. System Updates & Desktop Environment ---
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get upgrade -y
apt-get install -y xfce4 xfce4-goodies curl wget gnupg software-properties-common

# --- 2. Chrome Remote Desktop ---
wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb
apt-get install -y --fix-broken ./chrome-remote-desktop_current_amd64.deb
rm chrome-remote-desktop_current_amd64.deb
bash -c 'echo "exec /etc/X11/Xsession /usr/bin/xfce4-session" > /etc/chrome-remote-desktop-session'

# --- 2.5. Install Google Chrome ---
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add -
sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
apt-get update
apt-get install -y google-chrome-stable

# --- 3. Install GitHub CLI (gh) ---
(type -p wget >/dev/null || (apt-get update && apt-get install wget -y)) \
    && mkdir -p -m 755 /etc/apt/keyrings \
    && out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    && cat $out | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
    && chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && mkdir -p -m 755 /etc/apt/sources.list.d \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install gh -y

# --- 4. Install Antigravity IDE ---
mkdir -p /etc/apt/keyrings
curl -fsSL https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg | \
  gpg --dearmor --yes -o /etc/apt/keyrings/antigravity-repo-key.gpg
echo "deb [signed-by=/etc/apt/keyrings/antigravity-repo-key.gpg] https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/ antigravity-debian main" | \
  tee /etc/apt/sources.list.d/antigravity.list > /dev/null
apt-get update
apt-get install antigravity -y

# --- 5. User & Persistent Disk Setup ---
# (Assumes a secondary disk is attached as sdb)
USER="developer"
if ! id "$USER" &>/dev/null; then
    useradd -m -s /bin/bash "$USER"
fi

# Check if the persistent disk is formatted. If not, format it to ext4.
if ! blkid /dev/sdb | grep -q "ext4"; then
    mkfs.ext4 -m 0 -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb
fi

# Mount the disk to /home/developer
mkdir -p /home/$USER
mount -o discard,defaults /dev/sdb /home/$USER
echo UUID=$(blkid -s UUID -o value /dev/sdb) /home/$USER ext4 discard,defaults,nofail 0 2 >> /etc/fstab

# Ensure correct ownership
chown -R $USER:$USER /home/$USER

# --- 6. Interactive Setup Prompt ---
# We add this to .bashrc on the persistent disk so it follows the user.
BASHRC="/home/$USER/.bashrc"
if ! grep -q "CRD Setup Prompt" "$BASHRC"; then
    cat << 'EOF' >> "$BASHRC"

# CRD Setup Prompt
# Only runs if we are in an interactive SSH session and CRD isn't set up.
if [[ $- == *i* ]] && [ ! -d "$HOME/.config/chrome-remote-desktop" ]; then
    echo -e "\n\033[1;34m[🛰️ Antigravity Desktop Setup]\033[0m"
    echo -e "Chrome Remote Desktop is not yet registered for this VM."
    echo -e "1. Go to: \033[4;36mhttps://remotedesktop.google.com/headless\033[0m"
    echo -e "2. Follow the steps and copy the \033[1mDebian Linux\033[0m command."
    echo -ne "3. Paste the command here: "
    read -r crd_command
    if [[ $crd_command == *"chrome-remote-desktop"* ]]; then
        echo "Configuring..."
        eval "$crd_command"
        echo -e "\033[1;32m✅ Registration successful!\033[0m"
        echo "You can now connect via https://remotedesktop.google.com/access"
    else
        echo -e "\033[1;31m❌ Invalid command.\033[0m"
        echo "You can run the command manually later once you have it."
    fi
fi
EOF
fi
chown $USER:$USER "$BASHRC"
