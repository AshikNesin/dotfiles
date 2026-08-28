#!/usr/bin/env python3
"""traces-sync.py — incremental Shelley -> Traces sync with full typing.

Pushes every interaction of a conversation (user text, agent text, thinking,
tool calls + results, paired by callId) to Traces, using the event schema the
official CLI uses: one message per event, typed parts, no textContent on
thinking/tool messages.

Modes:
  traces-sync.py <conv-id>            incremental: push DB rows past the
                                      last synced sequence (state in
                                      ~/.cache/shelley-traces/<conv>.state)
  traces-sync.py <conv-id> --rebuild  delete + re-push the whole trace

Deterministic externalIds (message-uuid prefix + part index) and orders
(seq*32+idx) make pushes idempotent — re-running never duplicates.

Best-effort by design: exits 0 on most failures (stderr note) so Shelley
turns are never blocked. Env: TRACES_BASE, TRACES_DISABLE,
TRACES_SHELLEY_DB, TRACES_STATE_DIR.
"""
import datetime
import json
import os
import sqlite3
import sys
import time
import urllib.error
import urllib.request

BASE = os.environ.get("TRACES_BASE", "https://traces.int.exe.xyz")
DB = os.environ.get("TRACES_SHELLEY_DB",
                    os.path.expanduser("~/.config/shelley/shelley.db"))
STATE_DIR = os.environ.get("TRACES_STATE_DIR",
                           os.path.expanduser("~/.cache/shelley-traces"))
CHUNK = 25
FIRST_RUN_LIMIT = 400  # un-synced rows beyond this on first run: skip to now


def die(msg):
    print(f"traces-sync: {msg}", file=sys.stderr)
    sys.exit(1)


def api(method, path, body=None, retries=2):
    data = json.dumps(body).encode() if body is not None else None
    last = None
    for attempt in range(retries + 1):
        try:
            req = urllib.request.Request(
                BASE + path, data=data,
                headers={"Content-Type": "application/json"}, method=method)
            with urllib.request.urlopen(req, timeout=60) as r:
                return json.load(r)
        except urllib.error.HTTPError as e:
            detail = ""
            try:
                detail = e.read().decode(errors="replace")[:200]
            except Exception:
                pass
            last = f"HTTP {e.code}: {detail}"
            if e.code in (429, 500, 502, 503) and attempt < retries:
                time.sleep(1.5 * (attempt + 1))
                continue
            raise RuntimeError(last)
        except Exception as e:
            raise RuntimeError(str(e))
    raise RuntimeError(last or "request failed")


def to_ms(created_at):
    try:
        dt = datetime.datetime.strptime(created_at, "%Y-%m-%d %H:%M:%S").replace(
            tzinfo=datetime.timezone.utc)
        return int(dt.timestamp() * 1000)
    except Exception:
        return None


def map_row(seq, mid, mtype, llm_data, created_at):
    """One Shelley message -> list of Traces messages (one per event)."""
    try:
        data = json.loads(llm_data) if llm_data else {}
    except Exception:
        return []
    role = "user" if mtype == "user" else "assistant"
    ts = to_ms(created_at)
    events = []  # (kind, payload)
    text_chunks = []
    for p in data.get("Content") or []:
        ptype = p.get("Type")
        if ptype == 2 and p.get("Text"):
            text_chunks.append(p["Text"])
        elif ptype == 3 and p.get("Thinking"):
            events.append(("thinking",
                           [{"type": "thinking", "content": {"text": p["Thinking"][:2000]}}]))
        elif ptype == 5:
            inp = p.get("ToolInput")
            try:
                inp = json.loads(inp) if isinstance(inp, str) else inp
            except Exception:
                pass
            events.append(("tool_call",
                           [{"type": "tool_call", "content": {
                               "callId": p.get("ToolUseID") or f"call-{seq}",
                               "toolName": p.get("ToolName") or "tool",
                               "args": inp if isinstance(inp, dict) else {"input": str(inp)[:500]},
                           }}]))
        elif ptype == 6:
            res = p.get("ToolResult") or []
            out = "\n".join(r.get("Text", "") for r in res if isinstance(r, dict))[:4000]
            events.append(("tool_result",
                           [{"type": "tool_result", "content": {
                               "callId": p.get("ToolUseID") or "call-unknown",
                               "toolName": p.get("ToolName") or "tool",
                               "output": out or "(empty result)",
                               "status": "error" if p.get("ToolError") else "success",
                           }}]))
    text = "\n\n".join(text_chunks).strip()
    if text:
        events.append(("text", None))
    out = []
    base = mid.replace("-", "")[:12]
    for idx, (kind, parts) in enumerate(events):
        m = {"externalId": f"{base}-{idx}",
             "role": role if kind == "text" else "assistant",
             "order": seq * 32 + idx}
        if kind == "text":
            m["textContent"] = text[:12000]
        else:
            m["parts"] = parts
        if ts:
            m["timestamp"] = ts
        out.append(m)
    return out


def fetch_rows(conv, after_seq=0):
    db = sqlite3.connect(f"file:{DB}?mode=ro", uri=True, timeout=10)
    try:
        rows = db.execute(
            "SELECT sequence_id, message_id, type, llm_data, created_at FROM messages "
            "WHERE conversation_id=? AND type IN ('user','agent') "
            "AND excluded_from_context=0 AND sequence_id>? ORDER BY sequence_id",
            (conv, after_seq)).fetchall()
        meta = db.execute(
            "SELECT cwd, model, created_at FROM conversations WHERE conversation_id=?",
            (conv,)).fetchone()
    finally:
        db.close()
    return rows, meta


def trace_meta_put(meta, title=None):
    put = {"agentId": "shelley", "visibility": "private"}
    if title:
        put["title"] = title
    if meta:
        cwd, model, created_at = meta
        if model:
            put["model"] = model
        if cwd:
            put["projectPath"] = cwd
            put["projectName"] = cwd.rstrip("/").split("/")[-1]
        ts = to_ms(created_at)
        if ts:
            put["sourceCreatedAt"] = ts
    return put


def push_all(ext, msgs):
    for i in range(0, len(msgs), CHUNK):
        api("POST", f"/v1/traces/{ext}/messages/batch", {"messages": msgs[i:i + CHUNK]})
        time.sleep(0.25)


def main():
    if os.environ.get("TRACES_DISABLE") == "1":
        return
    args = [a for a in sys.argv[1:]]
    rebuild = "--rebuild" in args
    init_only = "--init-only" in args
    args = [a for a in args if not a.startswith("--")]
    if not args:
        die("usage: traces-sync.py <conversation-id> [--rebuild|--init-only]")
    conv = args[0]
    ext = f"shelley-{conv}"
    state_file = os.path.join(STATE_DIR, f"{conv}.state")
    had_state = os.path.exists(state_file)
    last_seq = 0
    if had_state:
        try:
            last_seq = int(open(state_file).read().strip() or 0)
        except Exception:
            last_seq = 0

    if init_only:
        # Seed state at the newest row WITHOUT pushing: used at conversation
        # start so the opening prompt (recorded via traces_add_message by
        # new-conversation) isn't duplicated, and so a fresh conversation's
        # whole pre-history isn't pushed.
        rows, _ = fetch_rows(conv, 0)
        if rows:
            os.makedirs(STATE_DIR, exist_ok=True)
            open(state_file, "w").write(str(rows[-1][0]))
        return

    rows, meta = fetch_rows(conv, 0 if rebuild else last_seq)
    if not rows and not rebuild:
        return  # nothing new

    if rebuild:
        try:
            api("DELETE", f"/v1/traces/{ext}")
        except Exception:
            pass
        def _first_user(rs):
            for r in rs:
                for m in map_row(*r):
                    if m["role"] == "user" and m.get("textContent"):
                        return m["textContent"]
            return None
        first_user = _first_user(rows)
        title = None
        if first_user:
            flat = " ".join(first_user.split())
            title = flat[:70] + ("…" if len(flat) > 70 else "")
        api("PUT", f"/v1/traces/{ext}", trace_meta_put(meta, title))
    msgs = []
    for r in rows:
        msgs.extend(map_row(*r))
    if not rebuild:
        # First ever sync of a long-running conversation: assume history is
        # intentionally skipped rather than blocking the 30s hook budget.
        if not had_state and len(msgs) > FIRST_RUN_LIMIT:
            def _flat(s):
                f = " ".join(s.split())
                return f[:70] + ("…" if len(f) > 70 else "")
            first_txt = next((m["textContent"] for m in msgs if m.get("textContent")), None)
            api("PUT", f"/v1/traces/{ext}",
                trace_meta_put(meta, _flat(first_txt) if first_txt else None))
            os.makedirs(STATE_DIR, exist_ok=True)
            open(state_file, "w").write(str(rows[-1][0]))
            print(f"traces-sync: {conv}: first run with {len(msgs)} messages "
                  f"> {FIRST_RUN_LIMIT}; starting from now", file=sys.stderr)
            return
        api("PUT", f"/v1/traces/{ext}", trace_meta_put(meta))
    if msgs:
        push_all(ext, msgs)
    if rows:
        os.makedirs(STATE_DIR, exist_ok=True)
        open(state_file, "w").write(str(rows[-1][0]))
    print(f"traces-sync: {conv}: pushed {len(msgs)} messages"
          f"{' (rebuild)' if rebuild else ''}", file=sys.stderr)


if __name__ == "__main__":
    main()
