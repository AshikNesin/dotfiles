#!/usr/bin/env bash
#
# macOS machine setup. Invoked by the root setup.sh dispatcher (or directly).
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# zsh ships with macOS (default login shell since Catalina), so there are no
# packages to install before the shared setup can run.
bash "$SCRIPT_DIR/../shared/setup.sh"

# NOTE: GUI apps are intentionally NOT driven from here. Run them manually:
#   - Homebrew casks  -> macos/brew/install-core-deps.sh, install.sh
#   - Mac App Store    -> macos/mas-install.sh
#   - System prefs     -> macos/preferences.sh
#   - Manual steps     -> macos/manual.md
