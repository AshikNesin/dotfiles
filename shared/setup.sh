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

# User-space tools (uv, and the CLIs `uv tool install` exposes — e.g.
# pre-commit) live in ~/.local/bin. Make sure it's on PATH for this script
# and every subprocess, before we go probing for those commands below.
case ":${PATH:-}:" in
    *":$HOME/.local/bin:"*) ;;
    *) export PATH="$HOME/.local/bin:$PATH" ;;
esac

# --- Git submodules (pure prompt, z, ...) ------------------------------
log "Initializing git submodules"
git -C "$DOTFILES_DIR" submodule update --init --recursive
git -C "$DOTFILES_DIR" submodule update --recursive --remote

# --- pre-commit (gitleaks) ---------------------------------------------
# Best-effort: install the binary if possible, then wire the hook.
# We never abort the whole setup if this step can't complete.
#
# PEP 668: Ubuntu 24.04+ / Debian 12+ mark the system Python as
# "externally managed" and reject `pip install` system-wide. We install
# pre-commit with uv (`tool install` -> isolated env in ~/.local/bin),
# which is PEP 668-safe and cross-platform. uv itself is bootstrapped
# below from its standalone installer if it isn't already present, so this
# one path works on BOTH macOS and Linux; pip is only a last-resort fallback.
log "Setting up pre-commit"
# Bootstrap uv if it's missing — its standalone installer is cross-platform
# (macOS + Linux) and lands in ~/.local/bin (already on PATH above). This
# means pre-commit works on a fresh macOS box too, not just Ubuntu.
if ! command -v uv >/dev/null 2>&1; then
    log "Installing uv (standalone installer)"
    curl -LsSf https://astral.sh/uv/install.sh | sh \
        || echo "    uv installer failed; will try pip fallbacks below"
fi
if ! command -v pre-commit >/dev/null 2>&1; then
    if   command -v uv   >/dev/null 2>&1; then
        uv tool install pre-commit || echo "    uv tool install failed; skipping pre-commit"
    elif command -v pipx >/dev/null 2>&1; then
        pipx install pre-commit || echo "    pipx install failed; skipping pre-commit"
    elif command -v pip  >/dev/null 2>&1; then
        pip  install --user pre-commit 2>/dev/null || pip  install pre-commit 2>/dev/null || echo "    pip install failed (PEP 668 on newer Ubuntu? install uv); skipping pre-commit"
    elif command -v pip3 >/dev/null 2>&1; then
        pip3 install --user pre-commit 2>/dev/null || pip3 install pre-commit 2>/dev/null || echo "    pip3 install failed (PEP 668 on newer Ubuntu? install uv); skipping pre-commit"
    else
        echo "    uv/pip not found — install uv (https://docs.astral.sh/uv/), then run: uv tool install pre-commit"
    fi
fi
if command -v pre-commit >/dev/null 2>&1; then
    # pre-commit install operates on the CURRENT working directory (no -C flag,
    # unlike git). When invoked via curl|bash the cwd is $HOME, not the repo,
    # so it fails with "git failed. Is it installed, and are you in a Git
    # repository directory?" Run it from the repo root via a subshell.
    (cd "$DOTFILES_DIR" && pre-commit install)
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
