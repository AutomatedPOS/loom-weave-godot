#!/usr/bin/env python3
"""Canvas plumbing. A shape is a query. Refill reads the dated tree.

Nothing here writes a thread.json. A shape that carries tree data,
a transcript, or a credential is rejected.
"""

from __future__ import annotations

import json
import re
from datetime import date, datetime, timezone
from pathlib import Path
from typing import Any

GUID_RE = re.compile(
    r"^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"
)
DAY_RE = re.compile(r"^[0-9]{4}-[0-9]{2}-[0-9]{2}$")
SKIP_DIR_NAMES = {
    ".git",
    "__pycache__",
    ".venv",
    "node_modules",
    "_incoming",
    "data",
    "build",
    "trees",
}

SHAPE_KEYS = ("v", "kind", "as_of", "windows", "attachments")
WINDOW_KEYS = ("id", "slot", "ask")
ASK_KINDS = ("none", "node", "kids", "path", "roster", "pdca")
ASK_GUID_KINDS = ("node", "kids", "path")
RAILS = ("personas", "processes", "tools")
REF_KINDS = ("roster", "window")
ONTO_KINDS = ("window",)

# Keys that mean a snapshot leaked into a query.
FORBIDDEN = {
    "body",
    "justDid",
    "next",
    "waitingOn",
    "context",
    "chose",
    "consequences",
    "nodes",
    "children",
    "children_of",
    "by_guid",
    "transcript",
    "messages",
    "session",
    "credential",
    "endpoint",
    "model",
    "inbox",
    "snapshot",
    "text",
    "items",
    "panes",
}


class ShapeError(ValueError):
    pass


class Unbound(ValueError):
    pass


def empty_shape() -> dict:
    return {
        "v": 1,
        "kind": "shape",
        "as_of": "now",
        "windows": [{"id": "field", "slot": 0, "ask": {"kind": "none"}}],
        "attachments": [],
    }


def dumps_shape(shape: dict) -> str:
    validate_shape(shape)
    return json.dumps(shape, indent="\t", ensure_ascii=False) + "\n"


def parse_shape(text: str) -> dict:
    try:
        data = json.loads(text)
    except json.JSONDecodeError as exc:
        raise ShapeError(f"not JSON: {exc}") from exc
    validate_shape(data)
    return data


def validate_shape(obj: Any) -> None:
    if not isinstance(obj, dict):
        raise ShapeError("shape must be an object")
    _forbid(obj)
    extra = set(obj) - set(SHAPE_KEYS)
    if extra:
        raise ShapeError(f"shape extra keys: {sorted(extra)}")
    if obj.get("kind") != "shape":
        raise ShapeError("kind must be shape")
    if int(obj.get("v", 0)) != 1:
        raise ShapeError("v must be 1")
    as_of = obj.get("as_of", "now")
    if not isinstance(as_of, str) or not as_of.strip():
        raise ShapeError("as_of must be a string")
    _day_of(as_of, date(2026, 9, 4))  # format check only; day ignored
    windows = obj.get("windows")
    if not isinstance(windows, list) or not windows:
        raise ShapeError("windows must be a non-empty list")
    ids: set[str] = set()
    for window in windows:
        _validate_window(window, ids)
    attachments = obj.get("attachments", [])
    if not isinstance(attachments, list):
        raise ShapeError("attachments must be a list")
    for att in attachments:
        _validate_attachment(att, ids)


def _validate_window(window: Any, ids: set[str]) -> None:
    if not isinstance(window, dict):
        raise ShapeError("window must be an object")
    extra = set(window) - set(WINDOW_KEYS)
    if extra:
        raise ShapeError(f"window extra keys: {sorted(extra)}")
    wid = window.get("id")
    if not isinstance(wid, str) or not wid.strip() or GUID_RE.match(wid):
        raise ShapeError("window id must be a non-guid local id")
    if wid in ids:
        raise ShapeError(f"duplicate window id {wid}")
    ids.add(wid)
    slot = window.get("slot")
    if not isinstance(slot, int) or isinstance(slot, bool):
        raise ShapeError("slot must be an integer")
    ask = window.get("ask")
    if not isinstance(ask, dict):
        raise ShapeError("ask must be an object")
    kind = ask.get("kind")
    if kind not in ASK_KINDS:
        raise ShapeError(f"ask.kind {kind!r} is not a query")
    allowed = {"kind"}
    if kind in ASK_GUID_KINDS:
        allowed.add("guid")
        guid = ask.get("guid")
        if not isinstance(guid, str) or not GUID_RE.match(guid):
            raise ShapeError("ask.guid must be a tree guid")
    elif kind == "roster":
        allowed.add("rail")
        rail = ask.get("rail")
        if rail not in RAILS:
            raise ShapeError("ask.rail must be personas, processes, or tools")
    extra_ask = set(ask) - allowed
    if extra_ask:
        raise ShapeError(f"ask extra keys: {sorted(extra_ask)}")


def _validate_attachment(att: Any, ids: set[str]) -> None:
    if not isinstance(att, dict):
        raise ShapeError("attachment must be an object")
    extra = set(att) - {"from", "onto"}
    if extra:
        raise ShapeError(f"attachment extra keys: {sorted(extra)}")
    src = att.get("from")
    dst = att.get("onto")
    _validate_ref(src, "from", ids, allow_roster=True)
    _validate_ref(dst, "onto", ids, allow_roster=False)


def _validate_ref(ref: Any, side: str, ids: set[str], allow_roster: bool) -> None:
    if not isinstance(ref, dict):
        raise ShapeError(f"{side} must be an object")
    extra = set(ref) - {"kind", "guid", "id"}
    if extra:
        raise ShapeError(f"{side} extra keys: {sorted(extra)}")
    kind = ref.get("kind")
    allowed_kinds = REF_KINDS if allow_roster else ONTO_KINDS
    if kind not in allowed_kinds:
        raise ShapeError(f"{side}.kind {kind!r} is not allowed")
    if kind == "roster":
        guid = ref.get("guid")
        if not isinstance(guid, str) or not GUID_RE.match(guid):
            raise ShapeError(f"{side}.guid must be a tree guid")
        if "id" in ref:
            raise ShapeError(f"{side} roster ref cannot carry a window id")
    else:
        wid = ref.get("id")
        if not isinstance(wid, str) or wid not in ids:
            raise ShapeError(f"{side}.id must name a window in this shape")
        if "guid" in ref:
            raise ShapeError(f"{side} window ref cannot carry a tree guid")


def _forbid(obj: Any) -> None:
    if isinstance(obj, dict):
        hit = set(obj) & FORBIDDEN
        if hit:
            raise ShapeError(f"shape carries data keys: {sorted(hit)}")
        for value in obj.values():
            _forbid(value)
    elif isinstance(obj, list):
        for item in obj:
            _forbid(item)


def _day_of(as_of: str, now: date) -> date:
    text = as_of.strip()
    if text == "now":
        return now
    if "T" in text:
        text = text.split("T", 1)[0]
    if not DAY_RE.match(text):
        raise ShapeError(f"as_of is not a UTC day: {as_of!r}")
    return date.fromisoformat(text)


def day_of(as_of: str, now: date | None = None) -> date:
    return _day_of(as_of, now or date.today())


def utc_today() -> date:
    return datetime.now(timezone.utc).date()


def _date_field(node: dict, key: str) -> date | None:
    raw = node.get(key)
    if not isinstance(raw, str) or not DAY_RE.match(raw):
        return None
    return date.fromisoformat(raw)


def begun(node: dict, day: date) -> bool:
    actual_start = _date_field(node, "actualStart")
    if actual_start is not None:
        return actual_start <= day
    actual_end = _date_field(node, "actualEnd")
    if actual_end is not None:
        return actual_end <= day
    decided = _date_field(node, "decidedDate")
    if decided is not None:
        return decided <= day
    return False


def is_ghost(node: dict, day: date) -> bool:
    if begun(node, day):
        return False
    actual_start = _date_field(node, "actualStart")
    actual_end = _date_field(node, "actualEnd")
    decided = _date_field(node, "decidedDate")
    planned_start = _date_field(node, "plannedStart")
    planned_end = _date_field(node, "plannedEnd")
    if actual_start is None and actual_end is None and decided is None:
        if planned_start is None and planned_end is None:
            return True
    if planned_start is not None and planned_start <= day:
        if planned_end is None or planned_end >= day:
            return True
    return False


def present(node: dict, day: date) -> bool:
    return begun(node, day) or is_ghost(node, day)


def _guid(node: dict) -> str:
    return str(node.get("guid", ""))


def index_nodes(nodes: list[dict]) -> tuple[dict[str, dict], dict[str, list[dict]]]:
    by_guid: dict[str, dict] = {}
    children: dict[str, list[dict]] = {}
    for node in nodes:
        guid = _guid(node)
        if not guid:
            continue
        by_guid[guid] = node
        parent = str(node.get("isPartOf", ""))
        children.setdefault(parent, []).append(node)
    return by_guid, children


def roster_parent(nodes: list[dict], rail: str) -> dict | None:
    if rail not in RAILS:
        raise ShapeError(f"unknown rail {rail}")
    for node in nodes:
        for prop in node.get("props") or []:
            if not isinstance(prop, dict):
                continue
            if prop.get("name") == "roster" and prop.get("value") == rail:
                return node
    return None


def roster_items(nodes: list[dict], rail: str, day: date) -> list[dict]:
    parent = roster_parent(nodes, rail)
    if parent is None:
        return []
    _, children = index_nodes(nodes)
    out = []
    for child in children.get(_guid(parent), []):
        if present(child, day):
            out.append(child)
    out.sort(key=lambda n: (_date_field(n, "actualStart") or date.max, str(n.get("name", ""))))
    return out


def path_of(node: dict, by_guid: dict[str, dict]) -> list[dict]:
    chain: list[dict] = []
    cur = node
    seen: set[str] = set()
    while True:
        chain.append(cur)
        parent = str(cur.get("isPartOf", ""))
        if parent == "" or parent not in by_guid or parent in seen:
            break
        seen.add(parent)
        cur = by_guid[parent]
    chain.reverse()
    return chain


def project(node: dict, day: date) -> dict:
    out = {
        "guid": _guid(node),
        "name": str(node.get("name", "")),
        "type": str(node.get("type", "")),
        "state": str(node.get("state", "")),
        "ghost": is_ghost(node, day),
    }
    for key in (
        "actualStart",
        "actualEnd",
        "plannedStart",
        "plannedEnd",
        "decidedDate",
        "justDid",
        "next",
        "waitingOn",
        "body",
    ):
        if key in node:
            out[key] = node[key]
    if "props" in node:
        out["props"] = node["props"]
    return out


def _pdca(node: dict) -> str:
    for prop in node.get("props") or []:
        if isinstance(prop, dict) and prop.get("name") == "pdca":
            return str(prop.get("value", ""))
    return ""


def refill(shape: dict, nodes: list[dict], now: date | None = None) -> dict:
    validate_shape(shape)
    day = day_of(str(shape.get("as_of", "now")), now or utc_today())
    by_guid, children = index_nodes(nodes)
    panes: dict[str, dict] = {}
    for window in shape["windows"]:
        ask = window["ask"]
        kind = ask["kind"]
        items: list[dict] = []
        if kind == "node":
            node = by_guid.get(ask["guid"])
            if node is not None and present(node, day):
                items.append(project(node, day))
        elif kind == "kids":
            for child in children.get(ask["guid"], []):
                if present(child, day):
                    items.append(project(child, day))
        elif kind == "path":
            node = by_guid.get(ask["guid"])
            if node is not None and present(node, day):
                for step in path_of(node, by_guid):
                    if present(step, day):
                        items.append(project(step, day))
        elif kind == "roster":
            for child in roster_items(nodes, ask["rail"], day):
                items.append(project(child, day))
        elif kind == "pdca":
            for node in nodes:
                if str(node.get("state", "")) not in ("open", "active"):
                    continue
                if _pdca(node) and present(node, day):
                    items.append(project(node, day))
        panes[window["id"]] = {"ask": dict(ask), "items": items}
    return {"as_of": day.isoformat(), "panes": panes}


def bind(persona_guid: str, loadout: dict, nodes: list[dict]) -> dict:
    if not isinstance(persona_guid, str) or not GUID_RE.match(persona_guid):
        raise Unbound("persona guid is missing")
    by_guid, _ = index_nodes(nodes)
    node = by_guid.get(persona_guid)
    if node is None:
        raise Unbound("persona is not in the tree")
    rail = None
    for prop in node.get("props") or []:
        if isinstance(prop, dict) and prop.get("name") == "rail":
            rail = prop.get("value")
    if rail != "persona":
        raise Unbound("guid is not a persona rail item")
    chat = loadout.get("chat") if isinstance(loadout, dict) else None
    if not isinstance(chat, dict):
        raise Unbound("loadout has no chat cap")
    endpoint = str(chat.get("endpoint", "")).strip()
    if not endpoint:
        raise Unbound("chat endpoint is empty")
    # Credential is read from the loadout at tap time and is not copied.
    binding = {"persona": persona_guid, "cap": "chat"}
    if set(binding) & FORBIDDEN:
        raise RuntimeError("binding grew a data key")
    return binding


def load_tree(root: Path) -> list[dict]:
    nodes: list[dict] = []
    root = root.resolve()
    for path in root.rglob("thread.json"):
        if any(part in SKIP_DIR_NAMES for part in path.relative_to(root).parts):
            continue
        try:
            data = json.loads(path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError):
            continue
        if isinstance(data, dict) and data.get("guid"):
            node = dict(data)
            node["_path"] = str(path)
            nodes.append(node)
    return nodes
