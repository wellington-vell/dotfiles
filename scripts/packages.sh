#!/bin/bash
set -euo pipefail

install_packages() {
  local script_dir="$1"
  local sudo_available="$2"

  if [[ "$sudo_available" != true ]]; then
    echo "Skipping package installation (sudo not available)"
    return 0
  fi

  if ! sudo pacman -S --needed --noconfirm - <"$script_dir/packages.txt"; then
    echo "Warning: Some pacman packages failed to install" >&2
  fi

  if ! command -v yay &>/dev/null; then
    echo "Installing yay-bin from AUR..."
    cd /tmp
    rm -rf yay-bin
    git clone https://aur.archlinux.org/yay-bin.git
    cd yay-bin
    makepkg -si --noconfirm
  fi

  if [[ -s "$script_dir/packages-aur.txt" ]]; then
    yay -S --noconfirm - <"$script_dir/packages-aur.txt"
  fi

  echo "Packages installed."
}
