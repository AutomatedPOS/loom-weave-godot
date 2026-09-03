#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
GODOT="${GODOT:-$HOME/.local/bin/godot}"
TREE="${LOOM_TREE:-/tmp/loom-repos/loom}"
if [[ ! -f "$TREE/thread.json" ]]; then
  TREE="$ROOT/_incoming/loom"
fi
if [[ ! -f "$TREE/thread.json" ]]; then
  git clone --depth 1 https://github.com/AutomatedPOS/loom.git "$ROOT/_incoming/loom"
  TREE="$ROOT/_incoming/loom"
fi

python3 "$ROOT/scripts/pack_loom_data.py" "$TREE"
rm -rf "$ROOT/build/web"
mkdir -p "$ROOT/build/web"
"$GODOT" --headless --path "$ROOT" --export-release Web "$ROOT/build/web/index.html"

# Godot wasm is over the 25 MiB asset cap. Gzip the file on disk.
# Do not advertise Content-Encoding here: Workers would gzip it again
# and tablets freeze on the splash. workers/serve.mjs serves it once.
python3 - "$ROOT/build/web" << 'PY'
from pathlib import Path
import gzip
import shutil
import sys
root = Path(sys.argv[1])
headers = [
    "/*",
    "  Cross-Origin-Opener-Policy: same-origin",
    "  Cross-Origin-Embedder-Policy: require-corp",
    "",
]
for path in sorted(root.iterdir()):
    if path.suffix in {".wasm", ".pck"} and path.stat().st_size > 20 * 1024 * 1024:
        gz = path.with_suffix(path.suffix + ".gz.tmp")
        with path.open("rb") as src, gzip.open(gz, "wb", compresslevel=9) as dst:
            shutil.copyfileobj(src, dst)
        gz.replace(path)
        print(f"gzipped {path.name} -> {path.stat().st_size} bytes")
    if path.suffix == ".wasm":
        headers += [
            f"/{path.name}",
            "  Content-Type: application/wasm",
            "  Cache-Control: public, max-age=0, must-revalidate, no-transform",
            "",
        ]
(root / "_headers").write_text("\n".join(headers).rstrip() + "\n", encoding="utf-8")
print("wrote", root / "_headers")
PY
python3 "$ROOT/scripts/patch_web_export.py" "$ROOT/build/web/index.js"
echo "export ok: $ROOT/build/web"
ls -lh "$ROOT/build/web"
