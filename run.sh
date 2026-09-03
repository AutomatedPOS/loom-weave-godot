#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
GODOT="${GODOT:-$HOME/.local/bin/godot}"
if [[ ! -x "$GODOT" ]]; then
  GODOT="$(command -v godot || true)"
fi
if [[ -z "${GODOT}" || ! -x "$GODOT" ]]; then
  echo "godot not found. Install Godot 4.3+ and set GODOT=." >&2
  exit 1
fi

TREE="${LOOM_TREE:-$ROOT/_incoming/loom}"
if [[ ! -f "$TREE/thread.json" ]]; then
  mkdir -p "$(dirname "$TREE")"
  git clone --depth 1 https://github.com/AutomatedPOS/loom.git "$TREE"
fi
export LOOM_TREE="$TREE"
exec "$GODOT" --path "$ROOT" --audio-driver Dummy "$@"
