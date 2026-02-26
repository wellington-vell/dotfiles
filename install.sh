#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_USER="${SUDO_USER:-$(whoami)}"
USER_HOME="$(eval echo ~"$TARGET_USER")"

# Check if running as root - makepkg cannot run as root
if [ "$(id -u)" -eq 0 ]; then
    echo "Error: Running as root is not allowed."
    echo "This script uses makepkg which cannot be run as root."
    echo "Please run as a non-root user."
    exit 1
fi

echo "Installing dotfiles for user: $TARGET_USER"

# Symlink configs first (before any package operations)
echo "Linking configs..."
mkdir -p "$USER_HOME/.config/hypr"
mkdir -p "$USER_HOME/.config/opencode"
ln -sf "$SCRIPT_DIR/bash/.bashrc" "$USER_HOME/.bashrc"
ln -sf "$SCRIPT_DIR/hypr/hyprland.conf" "$USER_HOME/.config/hypr/hyprland.conf"
ln -sf "$SCRIPT_DIR/opencode/opencode.jsonc" "$USER_HOME/.config/opencode/opencode.jsonc"

# Install pacman packages
echo "Installing pacman packages..."
if ! pacman -S --needed - < "$SCRIPT_DIR/packages.txt"; then
    echo "Warning: Some pacman packages failed to install" >&2
fi

# Configure git
echo "Configuring git..."
read -p "Enter your git user name: " GIT_NAME
read -p "Enter your git user email: " GIT_EMAIL
git config --global user.name "$GIT_NAME" || true
git config --global user.email "$GIT_EMAIL" || true

# Install yay from source (required for AUR packages)
# Continue even if this fails - config is already linked
echo "Installing yay..."
if ! command -v yay &> /dev/null; then
    YAY_TMP=$(mktemp -d)
    if git clone https://aur.archlinux.org/yay.git "$YAY_TMP" 2>/dev/null; then
        if (cd "$YAY_TMP" && makepkg -si --noconfirm 2>/dev/null); then
            echo "yay installed successfully"
        else
            echo "Warning: Failed to install yay. AUR packages cannot be installed." >&2
            echo "You can install yay manually later with: git clone https://aur.archlinux.org/yay.git /tmp/yay && cd /tmp/yay && makepkg -si" >&2
        fi
    else
        echo "Warning: Failed to clone yay repository" >&2
    fi
    rm -rf "$YAY_TMP"
else
    echo "yay already installed"
fi

# Install AUR packages (only if yay is available)
echo "Installing AUR packages..."
if command -v yay &> /dev/null && [ -s "$SCRIPT_DIR/packages-aur.txt" ]; then
    yay -S --needed - < "$SCRIPT_DIR/packages-aur.txt" || echo "Warning: Some AUR packages failed to install" >&2
else
    echo "Skipping AUR packages (yay not available or no packages to install)"
fi

echo "Done!"
