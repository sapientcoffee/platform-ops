#!/bin/bash
# =============================================================================
# 07b-languages.sh — Install Go, Rust, Python, Ruby via native version managers
# =============================================================================
# Uses direct tarball (Go), rustup (Rust), pyenv (Python), rbenv (Ruby).
# All installs run as user and live entirely in $HOME (persistent disk).
# First boot: full install (~10-15 min for Python/Ruby compilation).
# Subsequent boots: fast update checks (<30s).
# =============================================================================

USER="user"
HOME_DIR="/home/user"
LOG_DIR="$HOME_DIR/logs"
LOG_FILE="$LOG_DIR/language-install.log"

log() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] [07b-languages] $1"
    echo "$msg"
    echo "$msg" >> "$LOG_FILE"
}

# Create log directory
runuser -u $USER -- mkdir -p "$LOG_DIR"

log "=== Language toolchain install started ==="

# =============================================================================
# Go — direct tarball from go.dev
# =============================================================================
install_go() {
    log "[Go] Checking installation..."
    if [ -x "$HOME_DIR/go/bin/go" ]; then
        local current_version
        current_version=$(runuser -u $USER -- "$HOME_DIR/go/bin/go" version 2>/dev/null | awk '{print $3}')
        log "[Go] Already installed: $current_version — skipping"
    else
        log "[Go] Not found — installing..."
        # Get latest stable version (first line of VERSION?m=text, e.g. "go1.22.2")
        local go_version
        go_version=$(curl -fsSL "https://go.dev/VERSION?m=text" | head -1)
        if [ -z "$go_version" ]; then
            log "[Go] ERROR: Could not determine latest version"
            return 1
        fi
        log "[Go] Downloading $go_version..."
        local tarball="${go_version}.linux-amd64.tar.gz"
        local url="https://dl.google.com/go/${tarball}"
        runuser -u $USER -- bash -c "
            cd /tmp &&
            curl -fsSLO '$url' &&
            rm -rf '$HOME_DIR/go' &&
            tar -C '$HOME_DIR' -xzf '$tarball' &&
            rm -f '$tarball'
        " >> "$LOG_FILE" 2>&1
        # Create GOPATH directories
        runuser -u $USER -- mkdir -p "$HOME_DIR/gopath/bin" "$HOME_DIR/gopath/src" "$HOME_DIR/gopath/pkg"
        local installed_version
        installed_version=$(runuser -u $USER -- "$HOME_DIR/go/bin/go" version 2>/dev/null | awk '{print $3}')
        log "[Go] Installed: $installed_version"
    fi
}

# =============================================================================
# Rust — rustup
# =============================================================================
install_rust() {
    log "[Rust] Checking installation..."
    if [ -x "$HOME_DIR/.cargo/bin/rustup" ]; then
        log "[Rust] Already installed — running rustup update..."
        runuser -u $USER -- "$HOME_DIR/.cargo/bin/rustup" update >> "$LOG_FILE" 2>&1
        local rustc_version
        rustc_version=$(runuser -u $USER -- "$HOME_DIR/.cargo/bin/rustc" --version 2>/dev/null)
        log "[Rust] Current: $rustc_version"
    else
        log "[Rust] Not found — installing via rustup..."
        runuser -u $USER -- bash -c "
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable --no-modify-path
        " >> "$LOG_FILE" 2>&1
        local rustc_version
        rustc_version=$(runuser -u $USER -- "$HOME_DIR/.cargo/bin/rustc" --version 2>/dev/null)
        log "[Rust] Installed: $rustc_version"
    fi
}

# =============================================================================
# Python — pyenv
# =============================================================================
install_python() {
    log "[Python] Checking installation..."
    if [ -d "$HOME_DIR/.pyenv" ]; then
        log "[Python] pyenv already installed — updating..."
        runuser -u $USER -- git -C "$HOME_DIR/.pyenv" pull --quiet >> "$LOG_FILE" 2>&1
        local python_version
        python_version=$(runuser -u $USER -- bash -c "
            export PYENV_ROOT='$HOME_DIR/.pyenv'
            export PATH=\"\$PYENV_ROOT/bin:\$PATH\"
            eval \"\$(pyenv init -)\"
            python --version 2>/dev/null
        ")
        log "[Python] Current: $python_version (pyenv updated, skipping Python rebuild)"
    else
        log "[Python] Not found — installing pyenv..."
        runuser -u $USER -- git clone https://github.com/pyenv/pyenv.git "$HOME_DIR/.pyenv" >> "$LOG_FILE" 2>&1
        log "[Python] pyenv cloned — finding latest Python 3.12.x..."
        # Find and install latest Python 3.12.x
        local py_version
        py_version=$(runuser -u $USER -- bash -c "
            export PYENV_ROOT='$HOME_DIR/.pyenv'
            export PATH=\"\$PYENV_ROOT/bin:\$PATH\"
            pyenv install --list | grep -E '^\s+3\.12\.' | tail -1 | tr -d ' '
        ")
        if [ -z "$py_version" ]; then
            log "[Python] ERROR: Could not determine latest Python 3.12.x version"
            return 1
        fi
        log "[Python] Installing Python $py_version (this may take 5-10 minutes)..."
        runuser -u $USER -- bash -c "
            export PYENV_ROOT='$HOME_DIR/.pyenv'
            export PATH=\"\$PYENV_ROOT/bin:\$PATH\"
            eval \"\$(pyenv init -)\"
            pyenv install '$py_version' &&
            pyenv global '$py_version'
        " >> "$LOG_FILE" 2>&1
        local python_version
        python_version=$(runuser -u $USER -- bash -c "
            export PYENV_ROOT='$HOME_DIR/.pyenv'
            export PATH=\"\$PYENV_ROOT/bin:\$PATH\"
            eval \"\$(pyenv init -)\"
            python --version 2>/dev/null
        ")
        log "[Python] Installed: $python_version"
    fi
}

# =============================================================================
# Ruby — rbenv + ruby-build
# =============================================================================
install_ruby() {
    log "[Ruby] Checking installation..."
    if [ -d "$HOME_DIR/.rbenv" ]; then
        log "[Ruby] rbenv already installed — updating..."
        runuser -u $USER -- git -C "$HOME_DIR/.rbenv" pull --quiet >> "$LOG_FILE" 2>&1
        runuser -u $USER -- git -C "$HOME_DIR/.rbenv/plugins/ruby-build" pull --quiet >> "$LOG_FILE" 2>&1
        local ruby_version
        ruby_version=$(runuser -u $USER -- bash -c "
            export PATH=\"$HOME_DIR/.rbenv/bin:\$PATH\"
            eval \"\$($HOME_DIR/.rbenv/bin/rbenv init -)\"
            ruby --version 2>/dev/null
        ")
        log "[Ruby] Current: $ruby_version (rbenv updated, skipping Ruby rebuild)"
    else
        log "[Ruby] Not found — installing rbenv + ruby-build..."
        runuser -u $USER -- git clone https://github.com/rbenv/rbenv.git "$HOME_DIR/.rbenv" >> "$LOG_FILE" 2>&1
        runuser -u $USER -- git clone https://github.com/rbenv/ruby-build.git "$HOME_DIR/.rbenv/plugins/ruby-build" >> "$LOG_FILE" 2>&1
        log "[Ruby] rbenv cloned — finding latest Ruby 3.3.x..."
        # Find and install latest Ruby 3.3.x
        local rb_version
        rb_version=$(runuser -u $USER -- bash -c "
            export PATH=\"$HOME_DIR/.rbenv/bin:\$PATH\"
            $HOME_DIR/.rbenv/bin/rbenv install --list | grep -E '^3\.3\.' | tail -1 | tr -d ' '
        ")
        if [ -z "$rb_version" ]; then
            log "[Ruby] ERROR: Could not determine latest Ruby 3.3.x version"
            return 1
        fi
        log "[Ruby] Installing Ruby $rb_version (this may take 5-10 minutes)..."
        runuser -u $USER -- bash -c "
            export PATH=\"$HOME_DIR/.rbenv/bin:\$PATH\"
            eval \"\$($HOME_DIR/.rbenv/bin/rbenv init -)\"
            $HOME_DIR/.rbenv/bin/rbenv install '$rb_version' &&
            $HOME_DIR/.rbenv/bin/rbenv global '$rb_version'
        " >> "$LOG_FILE" 2>&1
        local ruby_version
        ruby_version=$(runuser -u $USER -- bash -c "
            export PATH=\"$HOME_DIR/.rbenv/bin:\$PATH\"
            eval \"\$($HOME_DIR/.rbenv/bin/rbenv init -)\"
            ruby --version 2>/dev/null
        ")
        log "[Ruby] Installed: $ruby_version"
    fi
}

# --- Run all installs ---
# Go and Rust are fast; Python and Ruby may take 5-15 min on first boot
install_go
install_rust
install_python
install_ruby

log "=== Language toolchain install complete ==="
