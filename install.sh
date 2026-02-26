#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing dotfiles..."

# Link bashrc
ln -sf "$DOTFILES_DIR/bash/.bashrc" "$HOME/.bashrc"

# Link hyprland config
mkdir -p "$HOME/.config/hypr"
ln -sf "$DOTFILES_DIR/hypr/hyprland.conf" "$HOME/.config/hypr/hyprland.conf"

echo "Done!"
