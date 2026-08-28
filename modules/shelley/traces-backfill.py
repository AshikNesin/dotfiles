#!/usr/bin/env python3
"""Backfill Traces traces from a Shelley DB with fully typed parts.

Maps Shelley llm_data content blocks to Traces parts:
  Type 2 (text)        -> message textContent + part {type:text, content:{text}}
  Type 3 (thinking)    -> part {type:thinking, content:{text}}
  Type 5 (tool use)    -> part {type:tool_call, content:{callId,toolName,args}}
  Type 6 (tool result) -> part {type:tool_result, content:{callId,toolName,output,status}}
Tool callIds pair tool_call with its tool_result via ToolUseID.
"""
import datetime, json, sqlite3, sys, time, urllib.request

BASE = "https://traces.int.exe.xyz"
DB = "/home/exedev/.config/shelley/shelley.db"
if len(sys.argv) > 1 and sys.argv[1] == "--db":
    DB = sys.argv[2]; sys.argv = sys.argv[:1] + sys.argv[3:]

def api(method, path, body=None):
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(BASE + path, data=data,
        headers={"Content-Type": "application/json"}, method=method)
    with urllib.request.urlopen(req, timeout=90) as r:
        return json.load(r)

def to_ms(created_at):
    try:
        dt = datetime.datetime.strptime(created_at, "%Y-%m-%d %H:%M:%S").replace(
            tzinfo=datetime.timezone.utc)
        return int(dt.timestamp() * 1000)
    except Exception:
        return None

def build(conv):
    db = sqlite3.connect(DB)
    conv_row = db.execute("SELECT cwd, model, created_at FROM conversations WHERE conversation_id=?", (conv,)).fetchone()
    rows = db.execute(
        "SELECT type, llm_data, created_at FROM messages WHERE conversation_id=? "
        "AND type IN ('user','agent') AND excluded_from_context=0 ORDER BY sequence_id",
        (conv,)).fetchall()
    db.close()

    # One trace message per event, mirroring the official CLI: thinking gets its
    # own message with NO textContent; tool_call / tool_result likewise. A single
    # 'order' counter keeps the global sequence.
    msgs = []
    order = 0
    for t, ld, created_at in rows:
        if not ld:
            continue
        try:
            data = json.loads(ld)
        except Exception:
            continue
        role = "user" if t == "user" else "assistant"
        ts = to_ms(created_at)
        text_chunks = []
        for p in data.get("Content") or []:
            ptype = p.get("Type")
            if ptype == 2 and p.get("Text"):
                text_chunks.append(p["Text"])
            elif ptype == 3 and p.get("Thinking"):
                msgs.append({"externalId": f"m{order+1:04d}", "role": "assistant", "order": order,
                             "parts": [{"type": "thinking", "content": {"text": p["Thinking"][:2000]}}],
                             **({"timestamp": ts} if ts else {})})
                order += 1
            elif ptype == 5:
                inp = p.get("ToolInput")
                try:
                    inp = json.loads(inp) if isinstance(inp, str) else inp
                except Exception:
                    pass
                msgs.append({"externalId": f"m{order+1:04d}", "role": "assistant", "order": order,
                             "parts": [{"type": "tool_call", "content": {
                                 "callId": p.get("ToolUseID") or f"call-{order}",
                                 "toolName": p.get("ToolName") or "tool",
                                 "args": inp if isinstance(inp, dict) else {"input": str(inp)[:500]},
                             }}],
                             **({"timestamp": ts} if ts else {})})
                order += 1
            elif ptype == 6:
                res = p.get("ToolResult") or []
                out = "\n".join(r.get("Text", "") for r in res if isinstance(r, dict))[:4000]
                msgs.append({"externalId": f"m{order+1:04d}", "role": "assistant", "order": order,
                             "parts": [{"type": "tool_result", "content": {
                                 "callId": p.get("ToolUseID") or "call-unknown",
                                 "toolName": p.get("ToolName") or "tool",
                                 "output": out or "(empty result)",
                                 "status": "error" if p.get("ToolError") else "success",
                             }}],
                             **({"timestamp": ts} if ts else {})})
                order += 1
        text = "\n\n".join(text_chunks).strip()
        if text:
            msgs.append({"externalId": f"m{order+1:04d}", "role": role, "order": order,
                         "textContent": text[:12000],
                         **({"timestamp": ts} if ts else {})})
            order += 1
        if not msgs:
            continue
    first = next((m["textContent"] for m in msgs if m["role"] == "user" and m.get("textContent")), None)
    title = (" ".join(first.split())[:70] + ("…" if first and len(first) > 70 else "")) if first else "Shelley session"

    put = {"agentId": "shelley", "visibility": "private", "title": title}
    if conv_row:
        cwd, model, created_at = conv_row
        if model: put["model"] = model
        if cwd:
            put["projectPath"] = cwd
            put["projectName"] = cwd.rstrip("/").split("/")[-1]
        ts = to_ms(created_at)
        if ts: put["sourceCreatedAt"] = ts
    return put, msgs, title

for conv in sys.argv[1:]:
    ext = f"shelley-{conv}"
    put, msgs, title = build(conv)
    if not msgs:
        print(f"{conv}: no content, skipping"); continue
    try:
        api("DELETE", f"/v1/traces/{ext}")
    except Exception as e:
        print(f"  (delete skipped: {e})")
    api("PUT", f"/v1/traces/{ext}", put)
    for i in range(0, len(msgs), 20):
        api("POST", f"/v1/traces/{ext}/messages/batch", {"messages": msgs[i:i+20]})
        time.sleep(0.3)
    tools = sum(1 for m in msgs for p in m.get("parts", []) if p["type"] == "tool_call")
    thinks = sum(1 for m in msgs for p in m.get("parts", []) if p["type"] == "thinking")
    print(f"{conv}: {len(msgs)} msgs ({tools} tool calls, {thinks} thinking) — “{title}”")
