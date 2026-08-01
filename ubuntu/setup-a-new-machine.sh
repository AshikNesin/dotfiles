#!/usr/bin/env bash
#
# Ubuntu machine setup. Invoked by the root setup.sh dispatcher (or directly).
#
set -euo pipefail

# Safety guard: no-op on non-Ubuntu/Debian.
[ -f /etc/os-release ] || exit 0
. /etc/os-release
case "${ID:-}" in
  ubuntu|debian) ;;
  *) echo "Not Ubuntu/Debian. Skipping ubuntu setup."; exit 0 ;;
esac

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() { echo; echo "==> $1"; }

install_if_missing() {
  if command -v "$1" >/dev/null 2>&1; then
    log "$1 already installed"
  else
    log "Installing $1"
    sudo apt-get update
    sudo apt-get install -y "$1"
  fi
}

install_script_if_missing() {
  local command="$1"
  local name="$2"
  local url="$3"

  if command -v "$command" >/dev/null 2>&1; then
    log "$name already installed"
  else
    log "Installing $name"
    # Pipe to bash, not sh: on Ubuntu /bin/sh is dash, which rejects bash-isms
    # like `set -o pipefail` (ExeBox's installer uses it -> "Illegal option") and
    # surfaces noisy "printf: I/O error" from herdr's awk pipeline. bash is a
    # POSIX superset, so sh-based installers (tailscale, herdr) run unchanged.
    curl -fsSL "$url" | bash
  fi
}

# Fresh Ubuntu cloud/minimal images ship without a generated UTF-8 locale, so
# prompt glyphs (pure's \u21e3/\u21e1/\u276f, etc.) render as raw bytes like
# "\M-b\M-^G\M-#". Generate en_US.UTF-8 and make it the default for logins.
ensure_utf8_locale() {
  if ! command -v locale-gen >/dev/null 2>&1; then
    log "Installing locales package"
    sudo apt-get update
    sudo apt-get install -y locales
  fi

  if ! locale -a 2>/dev/null | grep -iq '^en_US\.utf'; then
    log "Generating en_US.UTF-8 locale"
    sudo locale-gen en_US.UTF-8
  fi

  # Persist for future logins (/etc/default/locale)
  sudo update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

  # Apply to this script's process tree so subprocesses render UTF-8 now
  export LANG=en_US.UTF-8
  export LC_ALL=en_US.UTF-8
}

# --- Ubuntu prerequisites (zsh must exist before shared setup) ---------
install_if_missing curl
install_if_missing git
install_if_missing zsh

# UTF-8 locale (before the prompt ever loads, so glyphs render correctly)
ensure_utf8_locale

# Set zsh as default shell
zsh_path="$(command -v zsh)"

if [ "${SHELL:-}" = "$zsh_path" ]; then
  log "zsh is already the default shell"
else
  # Ensure zsh is a permitted login shell (chsh validates against /etc/shells).
  if ! grep -qx "$zsh_path" /etc/shells; then
    log "Adding $zsh_path to /etc/shells"
    echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
  fi

  # Change the login shell WITHOUT going through chsh's interactive PAM
  # prompt, which fails ("PAM: Authentication failure") on cloud / NOPASSWD-
  # sudo boxes where the account has no usable password. Run as root via sudo
  # and chsh skips the password prompt; usermod is the bulletproof fallback.
  log "Setting zsh as default shell"
  if ! sudo chsh -s "$zsh_path" "$(id -un)" 2>/dev/null; then
    sudo usermod -s "$zsh_path" "$(id -un)"
  fi
  log "Log out and back in to start using zsh."
fi

# --- Shared setup: submodules, pre-commit, Oh My Zsh, symlinks ---------
bash "$SCRIPT_DIR/../shared/setup.sh"

# --- Developer tools (Ubuntu-specific) ---------------------------------
# Detect Exe network
ON_EXE_DEV=0
if curl -fsS --max-time 1 https://reflection.int.exe.xyz >/dev/null 2>&1; then
  ON_EXE_DEV=1
fi

install_script_if_missing tailscale "Tailscale" "https://tailscale.com/install.sh"
install_script_if_missing herdr "Herdr" "https://herdr.dev/install.sh"

# Install ExeBox (only on Exe network)
if [ "$ON_EXE_DEV" -eq 1 ]; then
  install_script_if_missing exebox "ExeBox" \
    "https://raw.githubusercontent.com/AshikNesin/exebox/main/install.sh"
fi

log "Done 🎉"
echo
echo "  ✅  Setup complete. Dotfiles symlinked, zsh configured, UTF-8 locale set."
echo
echo "  To use it in THIS terminal:"
echo "    export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 && exec zsh"
echo "  Or just log out and back in (UTF-8 locale + zsh apply automatically)."
echo
