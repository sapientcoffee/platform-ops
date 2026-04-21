#!/bin/bash
# Setup Nix package manager on persistent disk
# Run once after first workstation start

if [ ! -d "$HOME/.nix-profile" ]; then
    echo "Installing Nix package manager..."
    sh <(curl -L https://nixos.org/nix/install) --no-daemon
    echo 'if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then . $HOME/.nix-profile/etc/profile.d/nix.sh; fi' >> "$HOME/.bashrc"
    echo "Nix installed successfully!"
else
    echo "Nix already installed."
fi
