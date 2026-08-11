# Shelley ↔ Traces bridge

Captures every Shelley conversation into [Traces](https://traces.com) as a live,
shareable trace. Each conversation becomes one trace keyed by the Shelley
conversation id.

## How it works

Shelley is **not** a Traces-supported agent, so the native `traces setup skills`
flow can't see it. Instead this bridge uses Traces' generic REST API
(`actions.traces.com/v1/...`, reachable here via the exe.dev edge proxy at
`https://traces.int.exe.xyz`) and four Shelley lifecycle hooks:

| Hook | Fires | Does |
|------|-------|------|
| `new-conversation` | conversation starts | creates the trace, records the first user message |
| `chat-message` | each user follow-up | appends the user message |
| `end-of-turn` | agent finishes a turn | appends the assistant response |
| `slash/traces` | you type `/traces` | flips visibility and prints the share URL |

`traces-lib.sh` holds the shared helpers (URL build, upsert, message append).

## Sharing

Type in any Shelley conversation:

```
/traces            # share as private (default) and print the URL
/traces public     # share as public
/traces direct     # share as direct (link-only, not indexed)
/traces url        # just print the current URL, no visibility change
```

The share URL is always `https://traces.com/s/shelley-<conversation-id>`.

## Auth

None on the VM. The exe.dev edge proxy at `https://traces.int.exe.xyz`
injects auth for requests from this VM. No `TRACES_API_KEY` is needed and no
secret is stored locally.

## Disable temporarily

```
export TRACES_DISABLE=1
```
(set in the environment before a Shelley turn to skip that turn).

## Remove

```
rm -rf ~/.config/shelley/hooks/new-conversation \
       ~/.config/shelley/hooks/chat-message \
       ~/.config/shelley/hooks/end-of-turn \
       ~/.config/shelley/hooks/slash/traces \
       ~/.config/shelley/hooks/traces-lib.sh \
       ~/.config/shelley/hooks/README-traces-bridge.md
```
