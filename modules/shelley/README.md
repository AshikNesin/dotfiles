# Shelley

Configuration and hooks for the Shelley coding agent.

## Traces bridge

Captures every Shelley conversation into [Traces](https://traces.com) as a
live, shareable trace. Shelley isn't a Traces-supported agent, so the native
`traces setup skills` flow can't see it; instead this bridge uses Traces'
generic REST API (reachable here via the exe.dev edge proxy at
`https://traces.int.exe.xyz`) plus Shelley lifecycle hooks.

| Hook | Fires | Does |
|------|-------|------|
| `new-conversation` | conversation starts | creates the trace, records the first user message |
| `chat-message` | each user follow-up | appends the user message |
| `end-of-turn` | agent finishes a turn | appends the assistant response |
| `slash/traces` | you type `/traces` | flips visibility and prints the share URL |

### Install

```sh
bash ~/dotfiles/modules/shelley/install.sh
# or, via the dotfiles symlink matrix: cd ~/dotfiles && bash modules/symlink.sh
```

### Share

Type in any Shelley conversation:

```
/traces            # share as private (default) and print the URL
/traces public     # share as public
/traces direct     # share as direct (link-only, not indexed)
/traces url        # just print the current URL, no visibility change
```

The share URL is always `https://traces.com/s/shelley-<conversation-id>`.

### Auth

None on the VM — the exe.dev edge proxy injects it. No secret is stored
locally. Disable for a stretch with `export TRACES_DISABLE=1`.
