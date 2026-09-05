# Shelley

Configuration and hooks for the Shelley coding agent.

## Taste (learned preferences)

A local re-implementation of Command Code's Taste feature
(https://commandcode.ai/docs/taste), built on Shelley lifecycle hooks — no
cloud, no rebuild, all local.

| Piece | Mechanism |
|---|---|
| learning | `end-of-turn` hook fires `taste learn <conv>` (detached); the distiller reads the conversation from Shelley's SQLite DB, side-calls a cheap LLM (exe.dev gateway, keyless) and merges durable preferences into per-package `taste.md` files |
| injection | `system-prompt` hook appends `taste render` — tiered to avoid context bloat (see below) |
| control | `/taste` slash panel + `taste` CLI in `~/dotfiles/bin` |
| sharing | commit `.shelley/taste/` — teammates get it via git (no cloud needed) |

### Injection tiers (context-budget discipline)

Research-backed (Claude Code memory docs: <200 lines or adherence drops;
Cursor: always-apply tiny, rest on demand; Mem0: selective retrieval beats
full stuffing), `taste render` injects three tiers:

1. **Core** — cross-project packages (general/workflow/git/code-style/docs/architecture),
   conf ≥ 0.5, capped ~900 chars. Always injected.
2. **Matched** — packages whose names match this project (path tokens, ecosystem
   markers like `go.mod`/`settings.gradle`) plus ALL project-scope learnings.
   Capped ~1800 chars.
3. **Indexed** — everything else: one index line (`taste cat <pkg>` to pull).
   The agent fetches on demand; zero cost otherwise.

Worst case ≈ 3k chars; typical case <1.5k. `taste render | wc -c` shows yours.

Storage:
- project: `<git-root>/.shelley/taste/<pkg>/taste.md` (commit for the team)
- global:  `~/.config/shelley/taste/<pkg>/taste.md` (follows you across projects)

Learning can be toggled per project (`taste disable` → `.shelley/settings.local.json`)
or user-wide (`taste disable --user` → `~/.config/shelley/config.json`); default on.
Kill switch: `export TASTE_DISABLE=1`. State/log: `~/.cache/shelley-taste/`.

Common commands:
```sh
taste status                          # settings, packages, injection size
taste doctor                          # diagnose the pipeline end-to-end
taste list [-g]                       # packages, learning counts
taste note "prefer table-driven tests" [--package testing]
taste forget "substring"              # remove matching learnings
taste lint                            # validate taste.md files
taste push [pkg|--all]                # project -> global
taste pull [pkg|--all]                # global -> project
taste learn <conv-id> [--dry-run]     # manual learn run
```
In a Shelley conversation: `/taste`, `/taste on|off`, `/taste list`,
`/taste note ...`, `/taste render`, `/taste doctor`.

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
