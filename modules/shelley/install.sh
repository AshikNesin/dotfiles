#!/usr/bin/env bash
# install.sh — symlink the Shelley hooks (incl. the Traces bridge) into place.
# Re-runnable; replaces stale links. Does NOT clobber unrelated hooks.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$HERE/hooks"
DEST="$HOME/.config/shelley/hooks"
mkdir -p "$DEST/slash"

link() {
  local rel="$1"           # path relative to hooks/, e.g. slash/traces
  local src="$SRC/$rel"
  local dst="$DEST/$rel"
  mkdir -p "$(dirname "$dst")"
  if [ -L "$dst" ] || [ -e "$dst" ]; then rm -f "$dst"; fi
  ln -s "$src" "$dst"
  echo "linked $dst -> $src"
}

link traces-lib.sh
link traces-sync.py
link new-conversation
link chat-message
link end-of-turn
link traces-doctor
link slash/traces
link slash/vision
link slash/websearch

echo
echo "Shelley hooks installed to $DEST"
echo "Verify:  bash $DEST/traces-doctor"
echo "Tools:   /traces  /vision  /websearch  (in a Shelley conversation)"
