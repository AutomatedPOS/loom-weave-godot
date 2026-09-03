#!/usr/bin/env bash
# Push the web export to the weave worker only.
# Host: loom.dord.dev. Worker: dord-dev.
# Needs CLOUDFLARE_API_TOKEN. Does not touch dord / www / Pages.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
if [[ ! -f "$ROOT/build/web/index.html" ]]; then
  echo "no build/web. Run ./export.sh first." >&2
  exit 1
fi
if [[ -z "${CLOUDFLARE_API_TOKEN:-}" ]]; then
  echo "CLOUDFLARE_API_TOKEN is empty. Cannot deploy." >&2
  exit 1
fi
exec npx --yes wrangler@4 deploy --config "$ROOT/wrangler.dord-dev.toml"
