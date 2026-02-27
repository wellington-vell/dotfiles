#!/bin/bash
set -euo pipefail

create_symlinks() {
  local script_dir="$1"
  local user_home="$2"

  mkdir -p "$user_home/.config/hypr"
  mkdir -p "$user_home/.config/opencode"
  mkdir -p "$user_home/.config/ghostty"
  mkdir -p "$user_home/.config/bash"
  
  ln -sf "$script_dir/.config/bash/aliases" "$user_home/.config/bash/aliases"
  ln -sf "$script_dir/.config/bash/environment" "$user_home/.config/bash/environment"
  ln -sf "$script_dir/.config/bash/hyprland" "$user_home/.config/bash/hyprland"
  ln -sf "$script_dir/.config/bash/plugins" "$user_home/.config/bash/plugins"
  ln -sf "$script_dir/.config/bash/prompt" "$user_home/.config/bash/prompt"
  ln -sf "$script_dir/.config/.bashrc" "$user_home/.bashrc"

  ln -sf "$script_dir/.config/starship.toml" "$user_home/.config/starship.toml"
  ln -sf "$script_dir/.config/hypr/hyprland.conf" "$user_home/.config/hypr/hyprland.conf"
  ln -sf "$script_dir/.config/opencode/opencode.jsonc" "$user_home/.config/opencode/opencode.jsonc"
  ln -sf "$script_dir/.config/ghostty/config" "$user_home/.config/ghostty/config"

  echo "Symlinks created."
}
