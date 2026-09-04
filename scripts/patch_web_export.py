#!/usr/bin/env python3
"""Godot copies Content-Encoding onto a new Response of already-decoded
bytes, then calls instantiateStreaming. Safari hangs on the splash.
Force the arrayBuffer path and drop Content-Encoding from the clone.
"""
from __future__ import annotations

import sys
from pathlib import Path


def patch(js: str) -> str:
    old_stream = "if (typeof (WebAssembly.instantiateStreaming) !== 'undefined') {"
    new_stream = "if (false && typeof (WebAssembly.instantiateStreaming) !== 'undefined') {"
    if old_stream not in js:
        raise SystemExit("instantiateStreaming guard not found")
    js = js.replace(old_stream, new_stream, 1)

    old_headers = "}), { headers: response.headers });"
    new_headers = (
        "}), { headers: (function (h) { "
        "h.delete('content-encoding'); "
        "h.delete('Content-Encoding'); "
        "return h; "
        "}(new Headers(response.headers))) });"
    )
    if old_headers not in js:
        raise SystemExit("tracked response headers clone not found")
    js = js.replace(old_headers, new_headers, 1)
    return js


def main() -> int:
    path = Path(sys.argv[1] if len(sys.argv) > 1 else "build/web/index.js")
    text = path.read_text(encoding="utf-8")
    path.write_text(patch(text), encoding="utf-8")
    print(f"patched {path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
