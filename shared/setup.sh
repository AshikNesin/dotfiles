#!/usr/bin/env bash
#
# shared/setup.sh — OS-agnostic setup steps, run by BOTH macos/ and ubuntu/
# setup-a-new-machine.sh:
#
#   - init git submodules (utils/pure, utils/z, ...)
#   - pre-commit (gitleaks hook)
#   - Oh My Zsh
#   - dotfile symlinks (modules/symlink.sh)
#
# OS-specific package installs (apt, brew) stay in the per-OS scripts,
# which MUST install `zsh` before calling this.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

log() { echo; echo "==> $1"; }

# --- Git submodules (pure prompt, z, ...) ------------------------------
log "Initializing git submodules"
git -C "$DOTFILES_DIR" submodule update --init --recursive
git -C "$DOTFILES_DIR" submodule update --recursive --remote

# --- pre-commit (gitleaks) ---------------------------------------------
# Best-effort: install the binary if a pip is available, then wire the hook.
# We never abort the whole setup if this step can't complete.
log "Setting up pre-commit"
if ! command -v pre-commit >/dev/null 2>&1; then
    if   command -v pip  >/dev/null 2>&1; then pip  install pre-commit || echo "    pip install failed (PEP 668 on newer Ubuntu?); skipping pre-commit"
    elif command -v pip3 >/dev/null 2>&1; then pip3 install pre-commit || echo "    pip3 install failed; skipping pre-commit"
    else
        echo "    pip not found — install python3-pip (or pipx), then run: pip install pre-commit"
    fi
fi
if command -v pre-commit >/dev/null 2>&1; then
    pre-commit install
fi

# --- Oh My Zsh ---------------------------------------------------------
# Non-interactive (RUNZSH=no CHSH=no): we don't want the installer to spawn a
# shell or change the login shell mid-script. macOS defaults to zsh already;
# Ubuntu sets it via chsh in its own script.
log "Installing Oh My Zsh"
if [ -d "$HOME/.oh-my-zsh" ]; then
    log "Oh My Zsh already installed"
else
    RUNZSH=no CHSH=no sh -c "$(
        curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
    )"
fi

# --- Dotfile symlinks (~/.zshrc, ~/.gitconfig, ~/.vimrc, ...) ----------
# symlink.sh installs its own deps (yq + jq) cross-platform.
log "Creating dotfile symlinks"
bash "$DOTFILES_DIR/modules/symlink.sh"

log "Shared setup complete"
