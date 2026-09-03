#!/usr/bin/env python3
"""Copy thread.json files from a loom checkout into res://data/loom."""

from __future__ import annotations

import shutil
import sys
from pathlib import Path


def main() -> int:
    src = Path(sys.argv[1] if len(sys.argv) > 1 else "/tmp/loom-repos/loom").resolve()
    dst = Path(__file__).resolve().parents[1] / "data" / "loom"
    if not (src / "thread.json").is_file():
        print(f"ERROR no thread.json in {src}", file=sys.stderr)
        return 1
    if dst.exists():
        shutil.rmtree(dst)
    count = 0
    for path in src.rglob("thread.json"):
        rel = path.relative_to(src)
        if any(part.startswith(".") for part in rel.parts):
            continue
        dest = dst / rel
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(path, dest)
        count += 1
    print(f"packed {count} nodes into {dst}")
    return 0 if count else 1


if __name__ == "__main__":
    raise SystemExit(main())
