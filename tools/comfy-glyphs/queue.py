#!/usr/bin/env python3
"""Queue a glyph on a local ComfyUI, refresh until one is right, pull it.

  python3 tools/comfy-glyphs/queue.py "a hat on a round bust, meaning role" --class persona
  python3 tools/comfy-glyphs/queue.py --refresh
  python3 tools/comfy-glyphs/queue.py --pull

ComfyUI at http://127.0.0.1:8188. Change the checkpoint in the Load
Checkpoint node if the auto-pick is wrong.
"""

from __future__ import annotations

import argparse
import json
import random
import shutil
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent
REPO = ROOT.parents[1]
LAST = ROOT / ".last.json"
RAW = REPO / "artifacts" / "glyphs" / "raw"
PICKED = REPO / "artifacts" / "glyphs" / "picked"
API = ROOT / "workflow_api.json"

sys.path.insert(0, str(ROOT))
from prompt import assemble  # noqa: E402


def _get(url: str) -> object:
    with urllib.request.urlopen(url, timeout=10) as resp:
        return json.loads(resp.read().decode("utf-8"))


def _post(url: str, payload: dict) -> dict:
    data = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(url, data=data, headers={"Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=30) as resp:
        return json.loads(resp.read().decode("utf-8"))


def pick_ckpt(base: str) -> str:
    info = _get(base + "/object_info/CheckpointLoaderSimple")
    names = info["CheckpointLoaderSimple"]["input"]["required"]["ckpt_name"][0]
    if not names:
        raise SystemExit("no checkpoints in ComfyUI")
    for name in names:
        lower = name.lower()
        if "xl" in lower and "refiner" not in lower:
            return name
    return names[0]


def load_api(ckpt: str, positive: str, negative: str, seed: int, batch: int, steps: int) -> dict:
    graph = json.loads(API.read_text(encoding="utf-8"))
    graph["4"]["inputs"]["ckpt_name"] = ckpt
    graph["5"]["inputs"]["batch_size"] = batch
    graph["6"]["inputs"]["text"] = positive
    graph["7"]["inputs"]["text"] = negative
    graph["3"]["inputs"]["seed"] = seed
    graph["3"]["inputs"]["steps"] = steps
    return graph


def wait_images(base: str, prompt_id: str, timeout: float = 180.0) -> list[dict]:
    deadline = time.time() + timeout
    while time.time() < deadline:
        hist = _get(base + "/history/" + urllib.parse.quote(prompt_id))
        item = hist.get(prompt_id)
        if item and item.get("outputs"):
            images: list[dict] = []
            for node in item["outputs"].values():
                images.extend(node.get("images") or [])
            if images:
                return images
        time.sleep(0.4)
    raise SystemExit("ComfyUI timed out")


def save_raw(base: str, images: list[dict]) -> list[Path]:
    RAW.mkdir(parents=True, exist_ok=True)
    written: list[Path] = []
    for img in images:
        qs = urllib.parse.urlencode(
            {
                "filename": img["filename"],
                "subfolder": img.get("subfolder", ""),
                "type": img.get("type", "output"),
            }
        )
        dest = RAW / img["filename"]
        with urllib.request.urlopen(base + "/view?" + qs, timeout=30) as resp:
            dest.write_bytes(resp.read())
        written.append(dest)
    return written


def write_last(payload: dict) -> None:
    LAST.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")


def read_last() -> dict:
    if not LAST.exists():
        raise SystemExit("nothing to refresh. Describe a tile first.")
    return json.loads(LAST.read_text(encoding="utf-8"))


def run(subject: str, kind: str, field: str, batch: int, steps: int, base: str) -> None:
    positive, negative = assemble(subject, kind=kind, field=field)
    try:
        ckpt = pick_ckpt(base)
    except urllib.error.URLError as exc:
        raise SystemExit("ComfyUI is not up at %s (%s)" % (base, exc.reason)) from exc
    seed = random.randint(1, 2**31 - 1)
    graph = load_api(ckpt, positive, negative, seed, batch, steps)
    queued = _post(base + "/prompt", {"prompt": graph})
    if queued.get("error") or queued.get("node_errors"):
        raise SystemExit(queued)
    prompt_id = queued["prompt_id"]
    images = wait_images(base, prompt_id)
    paths = save_raw(base, images)
    write_last(
        {
            "subject": subject,
            "kind": kind,
            "field": field,
            "seed": seed,
            "ckpt": ckpt,
            "prompt_id": prompt_id,
            "files": [str(p) for p in paths],
        }
    )
    print("seed %s  ckpt %s" % (seed, ckpt))
    print(subject)
    for path in paths:
        print(path)


def pull() -> None:
    last = read_last()
    files = [Path(p) for p in last.get("files", [])]
    if not files:
        raise SystemExit("last run stored no files")
    PICKED.mkdir(parents=True, exist_ok=True)
    for src in files:
        if not src.exists():
            raise SystemExit("missing %s — run queue again" % src)
        dest = PICKED / src.name
        shutil.copy2(src, dest)
        print(dest)
    print("picked. %s" % last.get("subject", ""))


def main() -> None:
    parser = argparse.ArgumentParser(description="Describe a tile. Refresh until it is right. Pull it.")
    parser.add_argument("subject", nargs="*", help="what the tile is")
    parser.add_argument("--class", dest="kind", default="", help="persona, process, tool, imperative, null, hazard, task, changed")
    parser.add_argument("--field", choices=("white", "sign"), default="white")
    parser.add_argument("--refresh", action="store_true", help="same description, new seed")
    parser.add_argument("--pull", action="store_true", help="copy the last batch into artifacts/glyphs/picked")
    parser.add_argument("--batch", type=int, default=4)
    parser.add_argument("--steps", type=int, default=24)
    parser.add_argument("--comfy", default="http://127.0.0.1:8188")
    args = parser.parse_args()
    base = args.comfy.rstrip("/")
    if args.pull:
        pull()
        return
    if args.refresh:
        last = read_last()
        run(last["subject"], last.get("kind", ""), last.get("field", "white"), args.batch, args.steps, base)
        return
    subject = " ".join(args.subject).strip()
    if not subject:
        parser.print_help()
        raise SystemExit(2)
    run(subject, args.kind, args.field, args.batch, args.steps, base)


if __name__ == "__main__":
    main()
