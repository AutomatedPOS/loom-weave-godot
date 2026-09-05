#!/usr/bin/env bash
# Idempotent Cloud Agent setup for loom-weave-godot.
# Installs Godot 4.3 (editor + web export templates), fetches the loom
# tree, imports the project, and produces the web export. Safe to rerun.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GODOT_VERSION="${GODOT_VERSION:-4.3-stable}"
GODOT_BIN="$HOME/.local/bin/godot"
TEMPLATE_DIR="$HOME/.local/share/godot/export_templates/4.3.stable"
BASE_URL="https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}"

mkdir -p "$HOME/.local/bin"

# 1. Godot editor binary (headless-capable).
if [[ -x "$GODOT_BIN" ]] && "$GODOT_BIN" --version 2>/dev/null | grep -q "^4.3"; then
  echo "godot already installed: $("$GODOT_BIN" --version)"
else
  echo "installing Godot ${GODOT_VERSION} editor..."
  tmp="$(mktemp -d)"
  curl -fL --retry 4 -o "$tmp/godot.zip" \
    "${BASE_URL}/Godot_v${GODOT_VERSION}_linux.x86_64.zip"
  unzip -o "$tmp/godot.zip" -d "$tmp" >/dev/null
  mv "$tmp/Godot_v${GODOT_VERSION}_linux.x86_64" "$GODOT_BIN"
  chmod +x "$GODOT_BIN"
  rm -rf "$tmp"
  echo "installed: $("$GODOT_BIN" --version)"
fi

# 2. Web export templates.
if [[ -f "$TEMPLATE_DIR/web_release.zip" ]]; then
  echo "export templates already present"
else
  echo "installing export templates ${GODOT_VERSION}..."
  tmp="$(mktemp -d)"
  curl -fL --retry 4 -o "$tmp/templates.tpz" \
    "${BASE_URL}/Godot_v${GODOT_VERSION}_export_templates.tpz"
  unzip -o "$tmp/templates.tpz" -d "$tmp" >/dev/null
  mkdir -p "$TEMPLATE_DIR"
  cp -r "$tmp"/templates/* "$TEMPLATE_DIR"/
  rm -rf "$tmp"
  echo "export templates installed in $TEMPLATE_DIR"
fi

# 3. Loom tree dependency (the data the interface renders).
TREE="${LOOM_TREE:-$ROOT/_incoming/loom}"
if [[ -f "$TREE/thread.json" ]]; then
  echo "loom tree present at $TREE"
else
  echo "cloning loom tree into $TREE..."
  mkdir -p "$(dirname "$TREE")"
  git clone --depth 1 https://github.com/AutomatedPOS/loom.git "$TREE"
fi
export LOOM_TREE="$TREE"

# 4. Import the project so resources resolve.
echo "importing Godot project..."
"$GODOT_BIN" --headless --path "$ROOT" --import --quit >/dev/null 2>&1 || true

# 5. Web export (produces build/web served by the web-preview terminal).
echo "building web export..."
GODOT="$GODOT_BIN" LOOM_TREE="$TREE" "$ROOT/export.sh"

echo "cloud-agent-install complete"
