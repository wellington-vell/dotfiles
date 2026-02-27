#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_USER="${SUDO_USER:-$(whoami)}"
USER_HOME="$(eval echo ~"$TARGET_USER")"

if [ "$(id -u)" -eq 0 ]; then
    echo "Error: Running as root is not allowed."
    echo "Please run as a non-root user."
    exit 1
fi

check_sudo() {
    sudo -n true 2>/dev/null
}

get_sudo() {
    echo "This installation requires sudo for system packages."
    echo "Please enter your password if prompted."
    if sudo -v; then
        echo "sudo access confirmed."
        return 0
    else
        echo "Warning: sudo access not available."
        return 1
    fi
}

SUDO_AVAILABLE=false
if check_sudo; then
    SUDO_AVAILABLE=true
    echo "sudo access already available."
elif get_sudo; then
    SUDO_AVAILABLE=true
else
    echo ""
    echo "Continuing without sudo. Only user-space configuration will be applied."
    echo "To install packages, run this script again with sudo access."
    echo ""
fi

echo "Installing dotfiles for user: $TARGET_USER"

source "$SCRIPT_DIR/scripts/symlinks.sh"
source "$SCRIPT_DIR/scripts/packages.sh"
source "$SCRIPT_DIR/scripts/git.sh"

echo "Linking configs..."
create_symlinks "$SCRIPT_DIR" "$USER_HOME"

echo "Installing packages..."
install_packages "$SCRIPT_DIR" "$SUDO_AVAILABLE"

echo "Configuring git..."
configure_git

source "$USER_HOME/.bashrc"

echo "Done!"
