#!/bin/bash
set -euo pipefail

configure_git() {
  local git_name="${1:-${GIT_NAME:-}}"
  local git_email="${2:-${GIT_EMAIL:-}}"

  if [[ -z "$git_name" || -z "$git_email" ]]; then
    echo "Git configuration not found."
    read -p "Would you like to set up git user name and email? [Y/n] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ && -n "$REPLY" ]]; then
      echo "Skipping git configuration."
      return 0
    fi
  fi

  if [[ -z "$git_name" ]]; then
    read -p "Enter your git user name: " git_name
  fi

  if [[ -z "$git_email" ]]; then
    read -p "Enter your git user email: " git_email
  fi

  git config --global user.name "$git_name" || true
  git config --global user.email "$git_email" || true

  echo "Git configured."
}
