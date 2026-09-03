#!/usr/bin/env bash
# Idempotent Cloud Agent bootstrap for loom-weave-godot.
# Installs Godot 4.3, the web export templates, the loom tree, and imports
# the project so a fresh clone opens with ./run.sh.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GODOT_VERSION="4.3-stable"
GODOT_BIN="$HOME/.local/bin/godot"
TEMPLATE_DIR="$HOME/.local/share/godot/export_templates/4.3.stable"

# 1. System packages: a virtual display + Mesa so the GL window renders
#    headlessly, plus the tools the run/export scripts shell out to.
if command -v apt-get >/dev/null 2>&1; then
  sudo apt-get update -y
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    xvfb libgl1 libgl1-mesa-dri libglx-mesa0 mesa-libgallium \
    libxcursor1 libxinerama1 libxrandr2 libxi6 libxkbcommon0 \
    fontconfig unzip curl python3 ca-certificates
fi

# 2. Godot engine binary.
mkdir -p "$HOME/.local/bin"
if [[ ! -x "$GODOT_BIN" ]] || ! "$GODOT_BIN" --version 2>/dev/null | grep -q "^4.3"; then
  tmp="$(mktemp -d)"
  curl -fL -o "$tmp/godot.zip" \
    "https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}/Godot_v${GODOT_VERSION}_linux.x86_64.zip"
  unzip -o "$tmp/godot.zip" -d "$tmp" >/dev/null
  mv "$tmp/Godot_v${GODOT_VERSION}_linux.x86_64" "$GODOT_BIN"
  chmod +x "$GODOT_BIN"
  rm -rf "$tmp"
fi

# 3. Web export templates (used by ./export.sh). Optional but keeps the
#    documented web flow working.
if [[ ! -f "$TEMPLATE_DIR/web_release.zip" ]]; then
  tmp="$(mktemp -d)"
  curl -fL -o "$tmp/templates.tpz" \
    "https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}/Godot_v${GODOT_VERSION}_export_templates.tpz"
  unzip -o "$tmp/templates.tpz" -d "$tmp" >/dev/null
  mkdir -p "$TEMPLATE_DIR"
  cp "$tmp"/templates/* "$TEMPLATE_DIR/"
  rm -rf "$tmp"
fi

# 4. Loom tree: the status view reads this. run.sh also clones it on demand,
#    but pre-seeding it means the first ./run.sh opens with data.
TREE="$ROOT/_incoming/loom"
if [[ ! -f "$TREE/thread.json" ]]; then
  git clone --depth 1 https://github.com/AutomatedPOS/loom.git "$TREE"
fi

# 5. Import so a fresh clone opens without the editor re-importing on launch.
"$GODOT_BIN" --headless --path "$ROOT" --import --quit >/dev/null 2>&1 || true

echo "install ok: godot $("$GODOT_BIN" --version), $(find "$TREE" -name thread.json | wc -l) loom nodes"
