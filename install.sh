#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_USER="${SUDO_USER:-$(whoami)}"
USER_HOME="$(eval echo ~"$TARGET_USER")"

# Check if running as root
if [ "$(id -u)" -eq 0 ]; then
    echo "Error: Running as root is not allowed."
    echo "Please run as a non-root user."
    exit 1
fi

# Check for sudo availability
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

# Symlink configs first (before any package operations)
echo "Linking configs..."
mkdir -p "$USER_HOME/.config/hypr"
mkdir -p "$USER_HOME/.config/opencode"
mkdir -p "$USER_HOME/.config/ghostty"

ln -sf "$SCRIPT_DIR/.config/starship.toml" "$USER_HOME/.config/starship.toml"
ln -sf "$SCRIPT_DIR/.config/.bashrc" "$USER_HOME/.config/.bashrc"
ln -sf "$SCRIPT_DIR/.config/hypr/hyprland.conf" "$USER_HOME/.config/hypr/hyprland.conf"
ln -sf "$SCRIPT_DIR/.config/opencode/opencode.jsonc" "$USER_HOME/.config/opencode/opencode.jsonc"
ln -sf "$SCRIPT_DIR/.config/ghostty/config" "$USER_HOME/.config/ghostty/config"

# Install pacman packages (requires sudo for system packages)
echo "Installing pacman packages..."
if [ "$SUDO_AVAILABLE" = true ]; then
    if ! sudo pacman -S --needed - < "$SCRIPT_DIR/packages.txt"; then
        echo "Warning: Some pacman packages failed to install" >&2
    fi
else
    echo "Skipping pacman packages (sudo not available)"
fi

# Configure git
echo "Configuring git..."
read -p "Enter your git user name: " GIT_NAME
read -p "Enter your git user email: " GIT_EMAIL
git config --global user.name "$GIT_NAME" || true
git config --global user.email "$GIT_EMAIL" || true

echo "Done!"
