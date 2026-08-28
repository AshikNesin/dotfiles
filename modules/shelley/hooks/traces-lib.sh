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
# Agent identity recorded on every Shelley trace.
TRACES_AGENT_ID="${TRACES_AGENT_ID:-shelley}"

# Map a Shelley conversation id (e.g. cABC123) to a stable Traces externalId.
# Prefix avoids collisions with other tools' trace ids.
traces_external_id() {
  printf 'shelley-%s' "$1"
}

# Create or update a trace. Args: conv_id title [visibility] [key=value ...]
# Extra keys map straight onto the trace: model=, agent_id=, project_name=,
# project_path=, git_remote_url=, source_created_at= (ms epoch).
# Empty title is omitted so existing titles aren't clobbered.
traces_upsert() {
  [ "$TRACES_DISABLED" = "1" ] && return 0
  local conv_id="$1" title="$2" vis="${3:-private}"; shift 3 || shift $#
  local ext; ext="$(traces_external_id "$conv_id")"
  local body kv k v
  body=$(jq -nc --arg t "$title" --arg a "${TRACES_AGENT_ID:-shelley}" --arg v "$vis" \
    '({agentId:$a, visibility:$v}) + (if ($t|length)>0 then {title:$t} else {} end)')
  for kv in "$@"; do
    k="${kv%%=*}"; v="${kv#*=}"
    case "$k" in
      model)             body=$(printf '%s' "$body" | jq -c --arg v "$v" '. + {model:$v}');;
      agent_id)          body=$(printf '%s' "$body" | jq -c --arg v "$v" '. + {agentId:$v}');;
      project_name)      body=$(printf '%s' "$body" | jq -c --arg v "$v" '. + {projectName:$v}');;
      project_path)      body=$(printf '%s' "$body" | jq -c --arg v "$v" '. + {projectPath:$v}');;
      git_remote_url)    body=$(printf '%s' "$body" | jq -c --arg v "$v" '. + {gitRemoteUrl:$v}');;
      source_created_at) body=$(printf '%s' "$body" | jq -c --arg v "$v" '. + {sourceCreatedAt:($v|tonumber? // $v)}');;
    esac
  done
  curl -sS -X PUT "$TRACES_BASE/v1/traces/$ext" \
    -H 'Content-Type: application/json' -d "$body" >/dev/null
}

# Append messages from a JSON array of API message objects (already in the
# final schema: {externalId, role, textContent?, order?, timestamp?, parts?}).
# Parts are typed: {type:"text"|"thinking"|"tool_call"|"tool_result"|"error"|"system_event",
# content:{...}} — the shape Traces persists and renders (typed content objects;
# no part-level externalId; messages need explicit order to render in order).
traces_add_messages_json() {
  [ "$TRACES_DISABLED" = "1" ] && return 0
  local conv_id="$1" msgs_json="$2"
  local ext; ext="$(traces_external_id "$conv_id")"
  curl -sS -X POST "$TRACES_BASE/v1/traces/$ext/messages/batch" \
    -H 'Content-Type: application/json' \
    -d "{\"messages\":$msgs_json}" >/dev/null
}

# Append a single plain message. Args: conv_id external_msg_id role text [timestamp_ms]
# Legacy helper for simple text events (user prompts, final responses).
traces_add_message() {
  [ "$TRACES_DISABLED" = "1" ] && return 0
  local conv_id="$1" mid="$2" role="$3" text="$4" ts="${5:-}"
  local ext; ext="$(traces_external_id "$conv_id")"
  local body
  body=$(jq -nc --arg mid "$mid" --arg role "$role" --arg text "$text" \
    'if $ts == "" then {messages:[{externalId:$mid, role:$role, textContent:$text}]} else {messages:[{externalId:$mid, role:$role, textContent:$text, timestamp:($ts|tonumber)}]} end' --arg ts "$ts")
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
