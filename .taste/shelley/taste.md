# shelley

- Avoid context bloat: keep injected agent memory small and bounded; prefer tiered/on-demand loading over always injecting everything.. Confidence: 0.95
- Cap taste packages at 5 per repo; never create a package just for the sake of naming.. Confidence: 0.95
- Enable taste learning by default in all projects; projects opt out per-repo rather than opting in.. Confidence: 0.95
- Keep generated taste files clean: no dates, commit ids, or conversation metadata — such noise is unwanted.. Confidence: 0.95
- Capture recurring workflows as reusable SKILL.md files (e.g. ~/.config/shelley/<name>/SKILL.md) so they auto-load instead of being re-derived each time.. Confidence: 0.90
- Consolidate near-duplicate taste topics (e.g. web/website) into one broader package instead of splitting.. Confidence: 0.90
- Store Shelley skills in ~/dotfiles/skills/ as the source of truth and symlink them into ~/.config/shelley for discovery.. Confidence: 0.90
- Use the Command Code taste file format (# <pkg> header, '- text. Confidence: X' lines) so taste stores stay interoperable across harnesses.. Confidence: 0.90
- Connect services offering MCP OAuth via the OAuth flow in ~/.config/mcp/mcp.json, matching the pattern used for prior integrations (e.g., executor).. Confidence: 0.85
- Sync every conversation to Traces automatically with all interactions — thinking, tool calls, results — not just prompts and replies.. Confidence: 0.85
- Store taste learnings in the respective repo's own .taste/ store — learnings belong to the repo where the work happened.. Confidence: 0.80
- Add new MCP servers to Shelley's config at ~/.config/mcp/mcp.json alongside existing entries; remote servers use a url entry.. Confidence: 0.75
- Match the target system's native schema exactly (typed parts, one event per message) so its filters classify thinking, tools, and compaction correctly.. Confidence: 0.70
- Record full metadata (agent, model, project, timestamps) when sharing traces; role-only or bare records are not acceptable.. Confidence: 0.70
- Normalize internal/gateway model ids to canonical public names before sending to external services so they render with proper labels.. Confidence: 0.65
