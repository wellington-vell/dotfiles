#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_USER="${SUDO_USER:-$(whoami)}"

if [ "$(id -u)" -eq 0 ]; then
    echo "Error: Running as root is not allowed."
    echo "Please run as a non-root user."
    exit 1
fi

check_sudo() {
    sudo -n true 2>/dev/null
}

get_sudo() {
    echo "This installation requires sudo for AUR packages."
    echo "Please enter your password if prompted."
    if sudo -v; then
        echo "sudo access confirmed."
        return 0
    else
        echo "Error: sudo access required for AUR packages."
        exit 1
    fi
fi

if ! check_sudo; then
    get_sudo
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
sudo yay -S --noconfirm - < "$SCRIPT_DIR/packages-aur.txt"

echo "Done!"
