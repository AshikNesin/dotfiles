# shelley

- Avoid context bloat: keep injected agent memory small and bounded; prefer tiered/on-demand loading over always injecting everything.. Confidence: 0.90
- Keep generated taste files clean: no dates, commit ids, or conversation metadata — such noise is unwanted.. Confidence: 0.90
- Use the Command Code taste file format (# <pkg> header, '- text. Confidence: X' lines) so taste stores stay interoperable across harnesses.. Confidence: 0.85
