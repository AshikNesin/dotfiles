#!/usr/bin/env bash
# traces-lib.sh — shared helpers for the Shelley<->Traces bridge.
# Sourced by the new-conversation / chat-message / end-of-turn / slash hooks.
#
# Each Shelley conversation becomes one Traces trace, keyed by the Shelley
# conversation id. Messages are appended as they happen so the trace stays
# live. Sharing is on-demand via the /traces slash command.
#
# Auth + base URL come from the exe.dev edge proxy; no secrets live on the VM.
set -euo pipefail

TRACES_BASE="${TRACES_BASE:-https://traces.int.exe.xyz}"
TRACES_SHARE_HOST="${TRACES_SHARE_HOST:-https://traces.com}"
# Disable the hook entirely (e.g. for an offline stretch) without uninstalling.
# Sourced as a function, so all callers stay defined (as no-ops) when disabled.
TRACES_DISABLED="${TRACES_DISABLE:-0}"
# Title shown for every Shelley trace.
TRACES_AGENT_LABEL="shelley"

# Map a Shelley conversation id (e.g. cABC123) to a stable Traces externalId.
# Prefix avoids collisions with other tools' trace ids.
traces_external_id() {
  printf 'shelley-%s' "$1"
}

# Create or update a trace. Args: conv_id title [visibility]
# Empty title is omitted so existing titles aren't clobbered.
traces_upsert() {
  [ "$TRACES_DISABLED" = "1" ] && return 0
  local conv_id="$1" title="$2" vis="${3:-private}"
  local ext; ext="$(traces_external_id "$conv_id")"
  local body
  body=$(jq -nc --arg t "$title" --arg a "$TRACES_AGENT_LABEL" --arg v "$vis" \
    '({agent:$a, visibility:$v}) + (if ($t|length)>0 then {title:$t} else {} end)')
  curl -sS -X PUT "$TRACES_BASE/v1/traces/$ext" \
    -H 'Content-Type: application/json' -d "$body" >/dev/null
}

# Append a single message. Args: conv_id external_msg_id role text
# Message schema: { externalId, role, textContent } — the API accepts richer
# part shapes but only persists textContent (verified against the live API by
# reading back natively-recorded traces; parts are dropped server-side).
traces_add_message() {
  [ "$TRACES_DISABLED" = "1" ] && return 0
  local conv_id="$1" mid="$2" role="$3" text="$4"
  local ext; ext="$(traces_external_id "$conv_id")"
  local body
  body=$(jq -nc --arg mid "$mid" --arg role "$role" --arg text "$text" '{
    messages: [{ externalId: $mid, role: $role, textContent: $text }]
  }')
  curl -sS -X POST "$TRACES_BASE/v1/traces/$ext/messages/batch" \
    -H 'Content-Type: application/json' -d "$body" >/dev/null
}

# Build the human-facing share URL for a conversation.
traces_share_url() {
  printf '%s/s/%s' "$TRACES_SHARE_HOST" "$(traces_external_id "$1")"
}

# Best-effort: nothing here should ever break a Shelley turn.
traces_guard() {
  "$@" || true
}
