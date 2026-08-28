# Shelley hooks: `vision` and `websearch` (agent side-call tools)

Two side-call CLIs give text-only Shelley models capabilities the session
model lacks. The session model never changes; each tool is a cheap mid-turn
side-call, invoked at the model's own discretion.

## `vision` — image side-call

Port of Command Code's VISION tool (https://commandcode.ai/docs/vision) for
Shelley and any text-only LLM: a non-visual model side-calls a cheap
vision-capable model that transcribes the image to text, then carries on.

### Pieces

| What | Where |
|---|---|
| CLI (on PATH) | `bin/vision` |
| system-prompt hook | `modules/shelley/hooks/system-prompt` → `~/.config/shelley/hooks/system-prompt` |
| `/vision` slash command | `modules/shelley/hooks/slash/vision` → `~/.config/shelley/hooks/slash/vision` |
| symlink wiring | `modules/symlinks.yml` (applied by `setup.sh` on a new machine) |

### CLI

    vision shot.png                          # full transcription
    vision shot.png "what's the exact error?"
    vision a.png b.png "compare"
    vision --json shot.png                   # agent-friendly output
    vision --probe                           # which models accept images
    vision --model gpt-5.6-luna shot.png

Backends, in order: exe.dev gateway (`llm.int.exe.xyz/v1`, no key), exe.dev
OpenRouter proxy, then plain OpenRouter with `VISION_API_KEY`. Configure via
`~/.config/vision/config.json` or `VISION_MODEL` / `VISION_BASE_URL` /
`VISION_API_KEY` / `VISION_TIMEOUT`.

Default model: `gpt-5.6-terra` (vision-capable, verified via `--probe`).

### Behavior notes (mirrors the Command Code doc)

- Reading is the model's decision, mid-turn — the hook only documents the tool.
- Fails open: exit 3 + stderr reason; the calling agent keeps its turn.
- Ask about what's IN the image — the transcriber has no other context.
- SVG inputs are rasterized with ImageMagick when present.

## `websearch` — live web search side-call (TinyFish)

Same side-call pattern for web grounding: searches the live web via the
TinyFish Search API (https://docs.tinyfish.ai/search-api) and returns
structured results — titles, URLs, snippets, dates — the model can cite.
Search is free on TinyFish (30 req/min), even at a $0 wallet balance.

### Pieces

| What | Where |
|---|---|
| CLI (on PATH) | `bin/websearch` |
| system-prompt hook | same shared `modules/shelley/hooks/system-prompt` (appends both tool docs) |
| `/websearch` slash command | `modules/shelley/hooks/slash/websearch` → `~/.config/shelley/hooks/slash/websearch` |
| symlink wiring | `modules/symlinks.yml` |

### CLI

    websearch "tinyfish search api"         # rendered results (default 8)
    websearch "q" --json                    # raw payload (agents)
    websearch "q" --news                    # news w/ publisher + date
    websearch "q" --papers                  # academic papers (research_paper)
    websearch "q" --recent 1440             # last 24h (minutes)
    websearch "q" --after 2025-01-01 --before 2025-06-30
    websearch "q" -l DE --lang de           # locale (default US/en)
    websearch "q" --include github.com,arxiv.org --exclude pinterest.com
    websearch "q" --purpose "why you're searching"   # improves relevance
    websearch --status                       # key / config diagnostics

Auth: keyless on exe.dev VMs via the edge proxy (`tinyfish.int.exe.xyz`) —
tried first, no configuration needed. Falls back to the direct API with
`TINYFISH_API_KEY` (get one at https://agent.tinyfish.ai/api-keys) or
`~/.config/websearch/config.json` (`{"api_key": ...}`). `--base-url` forces
a specific backend.

### Behavior notes

- Searching is the model's decision, mid-turn, like reading a file.
- Local-first: the system prompt says grep the repo before querying the web.
- Fails open: exit 3 + stderr reason (e.g. `401 INVALID_API_KEY`); the agent
  keeps its turn and reports the failure.
- Never ask the user to paste a key into chat — outside exe.dev, point at
  https://agent.tinyfish.ai/api-keys and `TINYFISH_API_KEY`.
