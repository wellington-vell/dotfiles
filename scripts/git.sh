#!/bin/bash
set -euo pipefail

configure_git() {
  local git_name="${1:-}"
  local git_email="${2:-}"

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
