# Shelley hooks: `vision` (image side-call)

Port of Command Code's VISION tool (https://commandcode.ai/docs/vision) for
Shelley and any text-only LLM: a non-visual model side-calls a cheap
vision-capable model that transcribes the image to text, then carries on.
The session model never changes.

## Pieces

| What | Where |
|---|---|
| CLI (on PATH) | `bin/vision` |
| system-prompt hook | `modules/shelley/hooks/system-prompt` → `~/.config/shelley/hooks/system-prompt` |
| `/vision` slash command | `modules/shelley/hooks/slash/vision` → `~/.config/shelley/hooks/slash/vision` |
| symlink wiring | `modules/symlinks.yml` (applied by `setup.sh` on a new machine) |

## CLI

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

## Behavior notes (mirrors the Command Code doc)

- Reading is the model's decision, mid-turn — the hook only documents the tool.
- Fails open: exit 3 + stderr reason; the calling agent keeps its turn.
- Ask about what's IN the image — the transcriber has no other context.
- SVG inputs are rasterized with ImageMagick when present.
