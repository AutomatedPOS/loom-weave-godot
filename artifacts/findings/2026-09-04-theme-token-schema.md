# Findings — theme token schema v1

Date: 2026-09-04. Seat: Grok, cloud agent
`bc-be1797ae-e3f0-4168-b159-724603a018b9`.

## Beats

### 2026-09-04 — Schema settled and ingested

`fence.theme/v1`. Three tiers. Manifest of legal keys. Unknown keys
drop with a log line. Semantic and components are `{reference}` only.
Patches are deltas. Fail closed. Contrast 4.5:1, nudge if close.

Shipped theme is Midnight Rink. First screen backdrop stays black.

### 2026-09-04 — Pass 1 plumbing, not the tablet Check

Gear still opens the loadout. Validate fires a real call per
capability. Grey / red / green. Chat stays off until all three are
green. Transcript is ephemeral. One hardcoded tool:
`apply_theme_patch`. Current theme rides in the system prompt.

Tests A and B are the owner Check on a pointed loadout. This seat
cannot speak or bill a key.

### 2026-09-04 — Backlog parked

FE-001 MCP, FE-002 git handoff, FE-003 two-state close, FE-004 user
theme UI. None of them block Pass 1. Routing rule is active: Grok
implements, Claude Code does interface on branches, Seth merges.
