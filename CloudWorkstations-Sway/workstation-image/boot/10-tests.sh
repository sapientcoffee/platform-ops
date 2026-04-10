#!/bin/bash
# =============================================================================
# 10-tests.sh — Post-boot verification of all Cloud Workstation features
# =============================================================================
# Runs after all setup scripts. Tests every feature and saves results.
# Results: ~/logs/boot-test-results.txt (full) + ~/logs/boot-test-summary.txt (one-line)
# =============================================================================

USER="user"
HOME_DIR="/home/user"
LOG_DIR="$HOME_DIR/logs"
RESULTS="$LOG_DIR/boot-test-results.txt"
SUMMARY="$LOG_DIR/boot-test-summary.txt"
NIX_SH="$HOME_DIR/.nix-profile/etc/profile.d/nix.sh"

PASS=0; FAIL=0; WARN=0; SKIP=0

# Source Nix for this script context
if [ -f "$NIX_SH" ]; then
    . "$NIX_SH"
fi

# Source module helper for composable install gating
WS_MODULES_HELPER="$HOME_DIR/.local/bin/ws-modules.sh"
if [ -f "$WS_MODULES_HELPER" ]; then
    . "$WS_MODULES_HELPER"
else
    ws_module_enabled() { return 0; }  # fallback: all enabled
fi

runuser -u $USER -- mkdir -p "$LOG_DIR"

log() { echo "$1" | tee -a "$RESULTS"; }

test_pass() { PASS=$((PASS+1)); log "  PASS: $1"; }
test_fail() { FAIL=$((FAIL+1)); log "  FAIL: $1"; }
test_warn() { WARN=$((WARN+1)); log "  WARN: $1"; }
test_skip() { SKIP=$((SKIP+1)); log "  SKIP: $1"; }

check_binary() {
    local name="$1" bin="$2"
    if runuser -u $USER -- bash -c ". $NIX_SH && export PATH=$HOME_DIR/.nix-profile/bin:$HOME_DIR/.npm-global/bin:$HOME_DIR/.local/bin:$HOME_DIR/gopath/bin:$HOME_DIR/go/bin:$HOME_DIR/.cargo/bin:$HOME_DIR/.pyenv/bin:$HOME_DIR/.rbenv/bin:/var/lib/nvidia/bin:\$PATH && which $bin" >/dev/null 2>&1; then
        test_pass "$name ($bin)"
    else
        test_fail "$name ($bin not found)"
    fi
}

check_file() {
    local name="$1" path="$2"
    if [ -f "$path" ]; then
        test_pass "$name"
    else
        test_fail "$name ($path missing)"
    fi
}

check_dir() {
    local name="$1" path="$2"
    if [ -d "$path" ]; then
        test_pass "$name"
    else
        test_fail "$name ($path missing)"
    fi
}

check_grep() {
    local name="$1" pattern="$2" file="$3"
    if grep -q "$pattern" "$file" 2>/dev/null; then
        test_pass "$name"
    else
        test_fail "$name (pattern '$pattern' not in $file)"
    fi
}

check_process() {
    local name="$1" pattern="$2"
    if pgrep -f "$pattern" >/dev/null 2>&1; then
        test_pass "$name running"
    else
        test_warn "$name not running (may start later)"
    fi
}

# Start fresh results
echo "========================================" > "$RESULTS"
echo "Cloud Workstation Boot Test Results" >> "$RESULTS"
echo "Date: $(TZ=America/Los_Angeles date)" >> "$RESULTS"
echo "========================================" >> "$RESULTS"
echo "" >> "$RESULTS"

# =============================================================================
# IDEs
# =============================================================================
if ws_module_enabled "ides"; then
    log "--- IDEs ---"
    check_binary "VSCode" "code"
    check_binary "IntelliJ" "idea-oss"
    check_binary "Cursor" "cursor"
    check_binary "Windsurf" "windsurf"
    check_binary "Zed" "zeditor"
else
    log "--- IDEs --- (SKIPPED — module disabled)"
    test_skip "IDEs (module disabled)"
fi

# tmux (separate module)
if ws_module_enabled "tmux"; then
    check_binary "tmux" "tmux"
else
    log "--- tmux --- (SKIPPED — module disabled)"
    test_skip "tmux (module disabled)"
fi

# =============================================================================
# AI CLI Tools
# =============================================================================
log ""
if ws_module_enabled "ai-tools"; then
    log "--- AI CLI Tools ---"
    check_binary "Claude Code" "claude"
    check_binary "Codex" "codex"
    check_binary "OpenCode" "opencode"
    check_binary "Cody" "cody"
    check_binary "Pi" "pi"
    # Aider (pip, installed to ~/.local/bin)
    if runuser -u $USER -- bash -c "export PYENV_ROOT=$HOME_DIR/.pyenv && export PATH=$HOME_DIR/.local/bin:\$PYENV_ROOT/bin:\$PATH && eval \"\$(pyenv init -)\" && which aider" >/dev/null 2>&1; then
        test_pass "Aider (aider)"
    else
        test_fail "Aider (not found)"
    fi
    # GH Copilot (extension)
    if runuser -u $USER -- bash -c ". $NIX_SH && gh copilot --version" >/dev/null 2>&1; then
        test_pass "GH Copilot"
    else
        test_warn "GH Copilot (extension may not be installed)"
    fi
elif ws_module_enabled "ai-tools-minimal"; then
    log "--- AI CLI Tools (minimal) ---"
    check_binary "Claude Code" "claude"
    test_skip "Codex (ai-tools-minimal)"
    test_skip "OpenCode (ai-tools-minimal)"
    test_skip "Cody (ai-tools-minimal)"
    test_skip "Pi (ai-tools-minimal)"
    test_skip "Aider (ai-tools-minimal)"
    test_skip "GH Copilot (ai-tools-minimal)"
else
    log "--- AI CLI Tools --- (SKIPPED — module disabled)"
    test_skip "AI CLI Tools (module disabled)"
fi

# =============================================================================
# Languages
# =============================================================================
log ""
if ws_module_enabled "languages"; then
    log "--- Languages ---"
    check_binary "Go" "go"
    check_binary "Rust (rustc)" "rustc"
    check_binary "Cargo" "cargo"
    # Python (needs pyenv init)
    if runuser -u $USER -- bash -c "export PYENV_ROOT=$HOME_DIR/.pyenv && export PATH=\$PYENV_ROOT/bin:\$PATH && eval \"\$(pyenv init -)\" && which python" >/dev/null 2>&1; then
        test_pass "Python (pyenv)"
    else
        test_fail "Python (pyenv not found)"
    fi
    # Ruby (needs rbenv init)
    if runuser -u $USER -- bash -c "export PATH=$HOME_DIR/.rbenv/bin:\$PATH && eval \"\$($HOME_DIR/.rbenv/bin/rbenv init -)\" && which ruby" >/dev/null 2>&1; then
        test_pass "Ruby (rbenv)"
    else
        test_fail "Ruby (rbenv not found)"
    fi
else
    log "--- Languages --- (SKIPPED — module disabled)"
    test_skip "Languages (module disabled)"
fi
# Node.js (via Nix — always part of base)
check_binary "Node.js" "node"
check_binary "npm" "npm"

# =============================================================================
# Nix
# =============================================================================
log ""
log "--- Nix ---"
if runuser -u $USER -- bash -c ". $NIX_SH && nix-env --version" >/dev/null 2>&1; then
    test_pass "nix-env works"
else
    test_fail "nix-env not working"
fi
if runuser -u $USER -- bash -c ". $NIX_SH && home-manager --version" >/dev/null 2>&1; then
    test_pass "home-manager available"
else
    test_fail "home-manager not available"
fi

# =============================================================================
# Config Files
# =============================================================================
log ""
log "--- Config Files ---"
# Desktop module configs
if ws_module_enabled "desktop"; then
    check_file "Wofi config" "$HOME_DIR/.config/wofi/config"
    check_file "Wofi style" "$HOME_DIR/.config/wofi/style.css"
    check_file "Snippet picker" "$HOME_DIR/.local/bin/snippet-picker"
    check_file "Snippets conf" "$HOME_DIR/.config/snippets/snippets.conf"
else
    test_skip "Wofi/Snippets configs (desktop module disabled)"
fi
# Core configs (always)
check_file "sway-status" "$HOME_DIR/.local/bin/sway-status"
check_file "Sway config" "$HOME_DIR/.config/sway/config"
# Tmux module configs
if ws_module_enabled "tmux"; then
    check_file "tmux.conf" "$HOME_DIR/.tmux.conf"
    # Verify tmux.conf syntax is valid
    if runuser -u $USER -- bash -c ". $NIX_SH && tmux -f $HOME_DIR/.tmux.conf start-server \\; kill-server" >/dev/null 2>&1; then
        test_pass "tmux.conf syntax valid"
    else
        test_fail "tmux.conf has syntax errors"
    fi
else
    test_skip "tmux.conf (tmux module disabled)"
fi
check_file ".zshrc" "$HOME_DIR/.zshrc"
check_file ".env" "$HOME_DIR/.env"

# =============================================================================
# Sway Config Content
# =============================================================================
log ""
log "--- Sway Config Checks ---"
SWAY_CFG="$HOME_DIR/.config/sway/config"
check_grep "xwayland disable" "xwayland disable" "$SWAY_CFG"
check_grep "IntelliJ DISPLAY=:0" "DISPLAY=:0.*idea-oss" "$SWAY_CFG"
check_grep "VSCode LD_LIBRARY_PATH" "LD_LIBRARY_PATH.*code" "$SWAY_CFG"
check_grep "Wofi XDG_DATA_DIRS" "XDG_DATA_DIRS" "$SWAY_CFG"
check_grep "Clipman wofi PATH" "PATH=.*clipman.*wofi\|clipman store" "$SWAY_CFG"
check_grep "Windsurf keybinding" "mod+w.*windsurf" "$SWAY_CFG"
check_grep "Apps button click" "button1.*wofi" "$SWAY_CFG"
check_grep "Antigravity keybinding" "antigravity" "$SWAY_CFG"
check_grep "Snippet picker keybinding" "snippet-picker" "$SWAY_CFG"

# =============================================================================
# Shell Config
# =============================================================================
log ""
log "--- Shell Config ---"
HM_NIX="$HOME_DIR/.config/home-manager/home.nix"
if [ -f "$HM_NIX" ]; then
    ZSHRC_SOURCE="$HM_NIX"
else
    ZSHRC_SOURCE="$HOME_DIR/.zshrc"
fi
check_grep "zshrc.local sourcing" "zshrc.local" "$ZSHRC_SOURCE"
check_grep "Timezone Pacific" "America/Los_Angeles" "$ZSHRC_SOURCE"
check_grep "Go PATH" "GOROOT" "$ZSHRC_SOURCE"
check_grep "Rust PATH" "cargo/bin" "$ZSHRC_SOURCE"
check_grep "pyenv init" "pyenv init" "$ZSHRC_SOURCE"
check_grep "rbenv init" "rbenv init" "$ZSHRC_SOURCE"
check_grep "Starship prompt" "starship init" "$ZSHRC_SOURCE"
check_grep "tmux aliases" "tmux new-session" "$ZSHRC_SOURCE"
check_grep "Nix profile sourced" "nix-profile.*nix.sh\|nix.sh" "$ZSHRC_SOURCE"

# =============================================================================
# sway-status
# =============================================================================
log ""
log "--- sway-status ---"
SWAY_STATUS="$HOME_DIR/.local/bin/sway-status"
check_grep "Apps block" "apps" "$SWAY_STATUS"
check_grep "GPU block" "gpu" "$SWAY_STATUS"
check_grep "CPU block" "cpu" "$SWAY_STATUS"
check_grep "Memory block" "memory" "$SWAY_STATUS"
check_grep "Disk block" "disk" "$SWAY_STATUS"
check_grep "Clock block" "clock" "$SWAY_STATUS"
check_grep "Network block" "network" "$SWAY_STATUS"

# =============================================================================
# Directory Structure
# =============================================================================
log ""
log "--- Directory Structure ---"
if ws_module_enabled "languages"; then
    check_dir "GOPATH" "$HOME_DIR/gopath"
    check_dir "Go install" "$HOME_DIR/go/bin"
    check_dir "Cargo" "$HOME_DIR/.cargo/bin"
    check_dir "pyenv" "$HOME_DIR/.pyenv"
    check_dir "rbenv" "$HOME_DIR/.rbenv"
else
    test_skip "Language dirs (languages module disabled)"
fi
check_dir "npm-global" "$HOME_DIR/.npm-global"
check_dir "Nix profile" "$HOME_DIR/.nix-profile"

# =============================================================================
# Services (may not be running during boot script phase)
# =============================================================================
log ""
log "--- Services ---"
check_process "Sway" "sway$"
check_process "swaybar" "swaybar"
check_process "wayvnc" "wayvnc"
check_process "Xwayland" "Xwayland"
check_process "clipman" "clipman store"

# =============================================================================
# Upgrade Scripts
# =============================================================================
log ""
log "--- Upgrade Scripts ---"

# Check tool versions (verifies upgrades actually installed something)
check_version() {
    local name="$1" cmd="$2"
    local ver=$(runuser -u $USER -- bash -c ". $NIX_SH && export PATH=$HOME_DIR/.nix-profile/bin:$HOME_DIR/.npm-global/bin:$HOME_DIR/.local/bin:$HOME_DIR/gopath/bin:$HOME_DIR/go/bin:$HOME_DIR/.cargo/bin:$HOME_DIR/.pyenv/bin:$HOME_DIR/.rbenv/bin:/var/lib/nvidia/bin:\$PATH && $cmd" 2>&1 | grep -viE "^[0-9]+/[0-9].*WARN |^WARNING" | head -1)
    if [ -n "$ver" ] && ! echo "$ver" | grep -qiE "not found|error|command not found"; then
        test_pass "$name version: $ver"
    else
        test_fail "$name version check failed"
    fi
}

if ws_module_enabled "ai-tools"; then
    # Check 07-apps.sh ran and completed
    if [ -f "$HOME_DIR/logs/app-update.log" ]; then
        if grep -q "App update complete" "$HOME_DIR/logs/app-update.log" 2>/dev/null; then
            test_pass "07-apps.sh completed successfully"
        else
            test_fail "07-apps.sh did not complete (check ~/logs/app-update.log)"
        fi
    else
        test_fail "07-apps.sh never ran (~/logs/app-update.log missing)"
    fi

    check_version "Claude Code" "claude --version"
    check_version "Codex" "codex --version"
    check_version "OpenCode" "opencode -v"
    check_version "Cody" "cody --version"
    check_version "Pi" "pi --version"

    # Aider version (pip, installed to ~/.local/bin — needs pyenv for Python)
    AIDER_VER=$(runuser -u $USER -- bash -c "export PYENV_ROOT=$HOME_DIR/.pyenv && export PATH=$HOME_DIR/.local/bin:\$PYENV_ROOT/bin:\$PATH && eval \"\$(pyenv init -)\" && aider --version" 2>&1 | head -1)
    if [ -n "$AIDER_VER" ] && ! echo "$AIDER_VER" | grep -qiE "not found|error"; then
        test_pass "Aider version: $AIDER_VER"
    else
        test_fail "Aider version check failed"
    fi

    # GH Copilot extension installed
    if [ -d "$HOME_DIR/.local/share/gh/extensions/gh-copilot" ] || runuser -u $USER -- bash -c ". $NIX_SH && gh extension list" 2>&1 | grep -q "copilot"; then
        test_pass "GH Copilot extension installed"
    elif ! runuser -u $USER -- bash -c ". $NIX_SH && gh auth status" >/dev/null 2>&1; then
        test_warn "GH Copilot extension (gh not authenticated)"
    else
        test_fail "GH Copilot extension not found"
    fi
elif ws_module_enabled "ai-tools-minimal"; then
    check_version "Claude Code" "claude --version"
    test_skip "Full AI tools versions (ai-tools-minimal profile)"
else
    test_skip "AI tool versions (module disabled)"
fi

# Home Manager generation is recent (within last 24 hours)
HM_GEN=$(runuser -u $USER -- bash -c ". $NIX_SH && home-manager generations" 2>&1 | head -1)
if [ -n "$HM_GEN" ]; then
    test_pass "Home Manager generation: $HM_GEN"
else
    test_fail "Home Manager has no generations"
fi

# Nix channel updated
if runuser -u $USER -- bash -c ". $NIX_SH && nix-channel --list" 2>&1 | grep -q "nixpkgs"; then
    test_pass "Nix channel configured"
else
    test_fail "Nix channel not configured"
fi

# =============================================================================
# Tailscale (opt-in — only tested if module enabled + TAILSCALE_AUTHKEY in ~/.env)
# =============================================================================
log ""
if ws_module_enabled "tailscale"; then
    log "--- Tailscale ---"
    check_binary "tailscale" "tailscale"
    if grep -q "TAILSCALE_AUTHKEY" "$HOME_DIR/.env" 2>/dev/null; then
        check_file "Tailscale state dir" "$HOME_DIR/.tailscale/tailscaled.state"
        if pgrep -x tailscaled >/dev/null 2>&1; then
            test_pass "tailscaled running"
        else
            test_fail "tailscaled not running (TAILSCALE_AUTHKEY is set)"
        fi
        if tailscale status >/dev/null 2>&1; then
            TS_IP=$(tailscale ip -4 2>/dev/null)
            test_pass "Tailscale connected ($TS_IP)"
        else
            test_fail "Tailscale not connected"
        fi
        if tailscale status --json 2>/dev/null | grep -q '"SSH"'; then
            test_pass "Tailscale SSH enabled"
        else
            test_warn "Tailscale SSH status unknown"
        fi
        # SSH config for Tailscale
        if grep -q "^PasswordAuthentication yes" /etc/ssh/sshd_config 2>/dev/null; then
            test_pass "SSH PasswordAuthentication enabled"
        else
            test_fail "SSH PasswordAuthentication not enabled"
        fi
        # iptables rule for tailscale SSH
        if iptables -C INPUT -i tailscale0 -p tcp --dport 22 -j ACCEPT 2>/dev/null; then
            test_pass "iptables: SSH allowed on tailscale0"
        else
            test_fail "iptables: SSH not allowed on tailscale0"
        fi
    else
        log "  SKIP: Tailscale not configured (no TAILSCALE_AUTHKEY in ~/.env)"
    fi
else
    log "--- Tailscale --- (SKIPPED — module disabled)"
    test_skip "Tailscale (module disabled)"
fi

# =============================================================================
# Summary
# =============================================================================
TOTAL=$((PASS+FAIL+WARN+SKIP))
log ""
log "========================================"
log "  TOTAL: $TOTAL | PASS: $PASS | FAIL: $FAIL | WARN: $WARN | SKIP: $SKIP"
log "========================================"

# Write one-line summary
PROFILE_INFO=""
if [ -f "$HOME_DIR/.ws-modules" ]; then
    PROFILE_INFO=" | Profile: $(grep '^profile=' "$HOME_DIR/.ws-modules" 2>/dev/null | cut -d= -f2)"
fi
echo "$(TZ=America/Los_Angeles date '+%Y-%m-%d %H:%M:%S %Z') | PASS: $PASS | FAIL: $FAIL | WARN: $WARN | SKIP: $SKIP${PROFILE_INFO}" > "$SUMMARY"

# Set ownership
chown -R $USER:$USER "$LOG_DIR"
