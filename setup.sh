#!/usr/bin/env bash
#
# setup.sh — the ONE entry point for a new machine.
#
# The same script handles both ways of running it:
#
#   1. Remote one-liner (repo not on the machine yet):
#
#        curl -fsSL https://raw.githubusercontent.com/AshikNesin/dotfiles/main/setup.sh | bash
#
#      It installs git/curl if needed, clones ~/dotfiles, then re-runs itself
#      from the clone (which then does step 2).
#
#   2. Local (repo already cloned):
#
#        cd ~/dotfiles && ./setup.sh
#
#      Detects the OS and runs macos/ or ubuntu/ setup-a-new-machine.sh.
#
# NOTE: pipe to `bash`, not `sh` — this script uses bash features.
#
set -euo pipefail

REPO_URL="https://github.com/AshikNesin/dotfiles.git"
DOTFILES_DIR="${HOME}/dotfiles"

# --- Are we running from inside the repo, or via curl | bash? -----------
# When piped to bash, BASH_SOURCE[0] is empty and sibling files don't exist,
# so we know the repo isn't present locally yet -> remote bootstrap mode.
script_dir=""
src="${BASH_SOURCE[0]:-}"
if [ -n "$src" ]; then
  script_dir="$(cd "$(dirname "$src")" && pwd)"
fi

is_local=0
if [ -n "$script_dir" ] && [ -f "$script_dir/ubuntu/setup-a-new-machine.sh" ]; then
  is_local=1
fi

# --- Remote bootstrap mode: ensure git/curl, clone, then re-exec --------
if [ "$is_local" -eq 0 ]; then
  echo "==> Bootstrapping dotfiles..."

  need_git=0
  need_curl=0
  command -v git  >/dev/null 2>&1 || need_git=1
  command -v curl >/dev/null 2>&1 || need_curl=1

  if [ "$need_git" -eq 1 ] || [ "$need_curl" -eq 1 ]; then
    case "$(uname -s)" in
      Linux)
        if [ -f /etc/os-release ]; then . /etc/os-release; fi
        case "${ID:-}" in
          ubuntu|debian)
            sudo apt-get update
            if [ "$need_curl" -eq 1 ]; then sudo apt-get install -y curl; fi
            if [ "$need_git"  -eq 1 ]; then sudo apt-get install -y git;  fi
            ;;
          *)
            echo "Unsupported distro for auto-installing git/curl: ${ID:-unknown}" >&2
            echo "Install git and curl manually, then re-run." >&2
            exit 1
            ;;
        esac
        ;;
      Darwin)
        # git & curl ship with the Xcode Command Line Tools.
        echo "git/curl not found. Install the Xcode Command Line Tools first:" >&2
        echo "    xcode-select --install" >&2
        echo "then re-run this command." >&2
        exit 1
        ;;
      *)
        echo "Unsupported OS: $(uname -s)" >&2
        exit 1
        ;;
    esac
  fi

  if [ -d "$DOTFILES_DIR/.git" ]; then
    echo "==> Updating dotfiles at $DOTFILES_DIR"
    git -C "$DOTFILES_DIR" pull --ff-only
  else
    echo "==> Cloning dotfiles -> $DOTFILES_DIR"
    git clone "$REPO_URL" "$DOTFILES_DIR"
  fi

  echo "==> Re-running setup.sh from the clone"
  exec bash "$DOTFILES_DIR/setup.sh"
fi

# --- Local mode: detect OS and dispatch --------------------------------
case "$(uname -s)" in
  Darwin)
    os="macos"
    ;;
  Linux)
    if [ -f /etc/os-release ]; then . /etc/os-release; fi
    case "${ID:-}" in
      ubuntu|debian) os="ubuntu" ;;
      *) echo "Unsupported Linux distribution: ${ID:-unknown}" >&2; exit 1 ;;
    esac
    ;;
  *)
    echo "Unsupported OS: $(uname -s)" >&2
    exit 1
    ;;
esac

target="$script_dir/$os/setup-a-new-machine.sh"
if [ ! -f "$target" ]; then
  echo "Setup script not found: $target" >&2
  exit 1
fi

echo "==> Detected OS: $os"
echo "==> Running: $target"
exec bash "$target"
