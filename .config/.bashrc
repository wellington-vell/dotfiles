#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Load modular configs
for file in ~/.config/bash/*; do
  [ -f "$file" ] && source "$file"
done

# Starship prompt
eval "$(starship init bash)"

# Ble.sh (must be after starship)
[[ -f /usr/share/blesh/ble.sh ]] && source /usr/share/blesh/ble.sh --attach=none
[[ ${BLE_VERSION-} ]] && ble-attach
