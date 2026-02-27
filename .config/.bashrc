#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Auto-start Hyprland on TTY1
if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    if command -v start-hyprland &> /dev/null; then
        exec start-hyprland
    else
        echo "Error: start-hyprland not found" >&2
        echo "Please install Hyprland or add it to your PATH" >&2
    fi
fi

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

# opencode
export PATH=$HOME/.opencode/bin:$PATH

# starship
# Must be last to avoid conflits with others packages
eval "$(starship init bash)"
