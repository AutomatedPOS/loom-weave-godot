#!/usr/bin/env python3
"""Print the path spine and open nodes of a loom tree.

Read-only. No Godot. Default root is this repo. Pass one or more
tree roots (directories that hold thread.json).
"""

from __future__ import annotations

import json
import sys
from pathlib import Path


def _read(path: Path) -> dict | None:
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return None
    if not isinstance(data, dict):
        return None
    return data


def load_tree(root: Path) -> tuple[list[dict], dict[str, dict], dict[str, list[dict]]]:
    nodes: list[dict] = []
    for path in root.rglob("thread.json"):
        if any(part.startswith(".") for part in path.relative_to(root).parts):
            continue
        node = _read(path)
        if node is None:
            continue
        node = dict(node)
        node["_path"] = str(path)
        nodes.append(node)

    by_guid = {str(n.get("guid", "")): n for n in nodes if n.get("guid")}
    children: dict[str, list[dict]] = {}
    for node in nodes:
        parent = str(node.get("isPartOf", ""))
        children.setdefault(parent, []).append(node)
    return nodes, by_guid, children


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


def _line(node: dict) -> str:
    name = str(node.get("name", "?"))
    typ = str(node.get("type", "?"))
    state = str(node.get("state", "—"))
    return f"{name}  {typ}  {state}"


def _prose(node: dict, key: str) -> str | None:
    val = node.get(key)
    if isinstance(val, str) and val.strip():
        return val.strip()
    return None


def report(root: Path) -> int:
    if not (root / "thread.json").is_file():
        print(f"ERROR no thread.json at {root}", file=sys.stderr)
        return 1
    nodes, by_guid, _children = load_tree(root)
    if not nodes:
        print(f"ERROR no nodes under {root}", file=sys.stderr)
        return 1

    roots = [n for n in nodes if str(n.get("isPartOf", "")) == ""]
    top = roots[0] if roots else nodes[0]

    print(f"tree  {root}")
    print(f"nodes {len(nodes)}")
    print()
    print("SPINE")
    print(f"  {_line(top)}")
    for key in ("justDid", "next", "waitingOn"):
        text = _prose(top, key)
        if text:
            print(f"    {key}: {text}")
    print()

    live = [
        n
        for n in nodes
        if n is not top and str(n.get("state", "")) in ("open", "active")
    ]
    live.sort(key=lambda n: [str(p.get("name", "")) for p in path_of(n, by_guid)])

    print(f"OPEN  {len(live)}")
    for node in live:
        names = " → ".join(str(p.get("name", "?")) for p in path_of(node, by_guid))
        print(f"  {names}  ({node.get('type', '?')}, {node.get('state', '—')})")
        for key in ("justDid", "next", "waitingOn", "body"):
            text = _prose(node, key)
            if text and key != "body":
                print(f"    {key}: {text}")
            elif text and key == "body" and not any(
                _prose(node, k) for k in ("justDid", "next", "waitingOn")
            ):
                print(f"    body: {text}")
    print()

    done = [n for n in nodes if str(n.get("state", "")) == "done"]
    print(f"DONE  {len(done)}")
    return 0


def main(argv: list[str]) -> int:
    here = Path(__file__).resolve().parents[1]
    roots = [Path(a).resolve() for a in argv[1:]] or [here]
    code = 0
    for i, root in enumerate(roots):
        if i:
            print()
            print("---")
            print()
        if report(root) != 0:
            code = 1
    return code


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
