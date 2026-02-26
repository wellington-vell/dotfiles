#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_USER="${SUDO_USER:-$(whoami)}"
USER_HOME="$(eval echo ~"$TARGET_USER")"

echo "Installing dotfiles for user: $TARGET_USER"

# Install pacman packages
echo "Installing pacman packages..."
pacman -S --needed - < "$SCRIPT_DIR/packages.txt"

# Configure git
echo "Configuring git..."
read -p "Enter your git user name: " GIT_NAME
read -p "Enter your git user email: " GIT_EMAIL
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"

# Install yay from source (required for AUR packages)
echo "Installing yay..."
if ! command -v yay &> /dev/null; then
    YAY_TMP=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$YAY_TMP"
    cd "$YAY_TMP"
    makepkg -si --noconfirm
    cd -
    rm -rf "$YAY_TMP"
fi

# Install AUR packages
echo "Installing AUR packages..."
if command -v yay &> /dev/null && [ -s "$SCRIPT_DIR/packages-aur.txt" ]; then
    yay -S --needed - < "$SCRIPT_DIR/packages-aur.txt"
else
    echo "No AUR packages to install"
fi

# Symlink configs
echo "Linking configs..."
ln -sf "$SCRIPT_DIR/bash/.bashrc" "$USER_HOME/.bashrc"
mkdir -p "$USER_HOME/.config/hypr"
ln -sf "$SCRIPT_DIR/hypr/hyprland.conf" "$USER_HOME/.config/hypr/hyprland.conf"
mkdir -p "$USER_HOME/.config/opencode"
ln -sf "$SCRIPT_DIR/opencode/opencode.jsonc" "$USER_HOME/.config/opencode/opencode.jsonc"

echo "Done!"
