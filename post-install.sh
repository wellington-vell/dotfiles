#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "$(id -u)" -eq 0 ]; then
    echo "Error: Running as root is not allowed."
    echo "Please run as a non-root user."
    exit 1
fi

if command -v yay &>/dev/null; then
    echo "yay already installed, skipping..."
else
    echo "Installing yay-bin from AUR..."
    cd /tmp
    rm -rf yay-bin
    git clone https://aur.archlinux.org/yay-bin.git
    cd yay-bin
    makepkg -si --noconfirm
fi

echo "Installing AUR packages..."
yay -S --noconfirm - < "$SCRIPT_DIR/packages-aur.txt"

echo "Done!"
