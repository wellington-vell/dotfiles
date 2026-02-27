# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Load modular configs
for file in ~/.config/bash/*; do
  [ -f "$file" ] && source "$file"
done

# Bash completion
if [[ -f /usr/share/bash-completion/bash_completion ]]; then
  source /usr/share/bash-completion/bash_completion
elif [[ -f /etc/bash_completion ]]; then
  source /etc/bash_completion
fi

# Ble.sh
[[ $- == *i* ]] && source /usr/share/blesh/ble.sh --noattach

# Fzf
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
eval "$(fzf --bash)"

# Starship prompt
eval "$(starship init bash)"

[[ ${BLE_VERSION-} ]] && ble-attach
