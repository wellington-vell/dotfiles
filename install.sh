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
ln -sf "$SCRIPT_DIR/bash/.bashrc" "$USER_HOME/.bashrc"
ln -sf "$SCRIPT_DIR/hypr/hyprland.conf" "$USER_HOME/.config/hypr/hyprland.conf"
ln -sf "$SCRIPT_DIR/opencode/opencode.jsonc" "$USER_HOME/.config/opencode/opencode.jsonc"

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

# Install yay from AUR (required for AUR packages)
# Uses yay-bin (precompiled) for speed, falls back to yay (source) if needed
echo "Installing yay..."
if ! command -v yay &> /dev/null; then
    YAY_TMP=$(mktemp -d)
    trap "rm -rf '$YAY_TMP'" EXIT
    
    # Try yay-bin first (precompiled - faster)
    if git clone --depth 1 https://aur.archlinux.org/yay-bin.git "$YAY_TMP" 2>&1; then
        if (cd "$YAY_TMP" && makepkg --noconfirm -si); then
            echo "yay-bin installed successfully"
        else
            echo "Warning: Failed to install yay-bin, trying yay (from source)..." >&2
            rm -rf "$YAY_TMP"
            YAY_TMP=$(mktemp -d)
            
            # Fallback to yay (compiles from source)
            if git clone --depth 1 https://aur.archlinux.org/yay.git "$YAY_TMP" 2>&1; then
                if (cd "$YAY_TMP" && makepkg --noconfirm -si); then
                    echo "yay installed successfully"
                else
                    echo "Warning: Failed to install yay. AUR packages cannot be installed." >&2
                fi
            else
                echo "Warning: Failed to clone yay repository" >&2
            fi
        fi
    else
        echo "Warning: Failed to clone yay repository" >&2
    fi
else
    echo "yay already installed"
fi

# Install AUR packages (only if yay is available)
echo "Installing AUR packages..."
if command -v yay &> /dev/null && [ -s "$SCRIPT_DIR/packages-aur.txt" ]; then
    if [ "$SUDO_AVAILABLE" = true ]; then
        sudo yay -S --needed - < "$SCRIPT_DIR/packages-aur.txt" || echo "Warning: Some AUR packages failed to install" >&2
    else
        echo "Skipping AUR packages (sudo not available)"
    fi
else
    echo "Skipping AUR packages (yay not available or no packages to install)"
fi

echo "Done!"
