# Dotfiles

My dotfiles for Arch Linux + Hyprland

## Installation

Clone into `~/.dotfiles` and run:

```bash
git clone https://github.com/wellington-vell/dotfiles.git ~/.dotfiles && cd ~/.dotfiles && ./install.sh
```

Or via curl:

```bash
curl -sL https://github.com/wellington-vell/dotfiles/archive/refs/heads/main.tar.gz | tar xz && mv dotfiles-main ~/.dotfiles && cd ~/.dotfiles && ./install.sh
```

### Options

Pass environment variables to skip interactive prompts:

```bash
GIT_NAME="Your Name" GIT_EMAIL="you@example.com" ./install.sh
```

## What's Installed

- **hyprland** - Wayland compositor
- **neovim** - Editor
- **git** - Version control
- **less** - Pager
- **ghostty** - Terminal
- **opencode** - AI coding assistant
- **man** - Manual pages
- **tldr** - Simplified man pages
- **starship** - Shell prompt
- **ttf-jetbrains-mono-nerd** - Font

### AUR Packages (via yay)

- **zen-browser-bin** - Web Browser

## Structure

- `install.sh` - Main entry point
- `scripts/symlinks.sh` - Creates config symlinks
- `scripts/packages.sh` - Installs pacman + AUR packages
- `scripts/git.sh` - Configures git
