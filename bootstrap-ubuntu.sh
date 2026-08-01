#!/usr/bin/env bash
set -euo pipefail

# Only run on Ubuntu
[ -f /etc/os-release ] || exit 0
. /etc/os-release

if [ "${ID:-}" != "ubuntu" ]; then
  echo "Not Ubuntu. Skipping."
  exit 0
fi

log() {
  echo
  echo "==> $1"
}

install_if_missing() {
  if command -v "$1" >/dev/null 2>&1; then
    log "$1 already installed"
  else
    log "Installing $1"
    sudo apt-get update
    sudo apt-get install -y "$1"
  fi
}

# Install required packages
install_if_missing curl
install_if_missing git
install_if_missing zsh

# Clone or update dotfiles
DOTFILES_DIR="$HOME/dotfiles"

if [ -d "$DOTFILES_DIR/.git" ]; then
  log "Updating dotfiles"
  git -C "$DOTFILES_DIR" pull --ff-only
else
  log "Cloning dotfiles"
  git clone https://github.com/AshikNesin/dotfiles.git "$DOTFILES_DIR"
fi

# Install Oh My Zsh
if [ -d "$HOME/.oh-my-zsh" ]; then
  log "Oh My Zsh already installed"
else
  log "Installing Oh My Zsh"
  RUNZSH=no CHSH=no sh -c "$(
    curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
  )"
fi

# Set zsh as default shell
zsh_path="$(command -v zsh)"

if [ "${SHELL:-}" = "$zsh_path" ]; then
  log "zsh is already the default shell"
else
  if ! grep -qx "$zsh_path" /etc/shells; then
    echo "$zsh_path is not listed in /etc/shells"
    echo "Run: echo '$zsh_path' | sudo tee -a /etc/shells"
    exit 1
  fi

  log "Setting zsh as default shell"
  chsh -s "$zsh_path"
  log "Log out and back in to start using zsh."
fi

# Install Tailscale
if command -v tailscale >/dev/null 2>&1; then
  log "Tailscale already installed"
else
  log "Installing Tailscale"
  curl -fsSL https://tailscale.com/install.sh | sh
fi

# Install Herdr
if command -v herdr >/dev/null 2>&1; then
  log "Herdr already installed"
else
  log "Installing Herdr"
  curl -fsSL https://herdr.dev/install.sh | sh
fi

log "Done 🎉"
