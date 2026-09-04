# Feature Enhancement Backlog

**Status:** open, unordered
**Owner:** Seth

Parked ideas. Nothing here blocks Pass 1. Each becomes an order file
when pulled.

---

## FE-001 — MCP layer for interface control

**Replaces:** the hardcoded `apply_theme_patch` function and
current-theme-in-system-prompt approach used in Pass 1.

Expose an MCP server inside the app. The model asks for what it needs
and acts, instead of receiving scene context stuffed into every prompt.

Tool surface (draft):

- `get_current_theme` — returns resolved active theme
- `list_theme_keys` — returns the legal key manifest
- `apply_theme_patch` — accepts a partial patch, runs validation,
  applies or rejects with reason

Why it's better: the model can't hallucinate keys, because the tool
tells it what exists. And "make it darker" gets a reference point — it
can read the current value before proposing a new one.

**Refactor, not a blocker.** Pin until Pass 1 passes.

---

## FE-002 — Session persistence and Git handoff

Let the user save a working session and submit it. Adds a Git API key
to the settings panel; the interface can then read, branch, commit,
and push on the user's behalf.

Target user: someone who has real work product in a session but no
idea how to use Git.

**Note:** this is a separate product, not a feature. Scope it on its
own before committing to it.

---

## FE-003 — Two-state close on order files

Feature requests do not close on implementation. They close on
acceptance.

- Implementer (Grok) moves an order to **resolved** when the work is
  done.
- Order stays in **resolved** until Seth confirms.
- Only Seth flips **resolved → closed**.

Fits the existing four-value status schema. `resolved` and `closed`
are distinct states; the last transition is human-only.

---

## FE-004 — User theme authoring UI

Beyond LLM generation: let the end user pick favorite colors directly
and save named themes. Writes the same token file the LLM produces —
no second code path.

---

## Routing rule (active now, not a backlog item)

Not a feature — a standing rule for how work gets assigned.

| Work type | Who | Where |
|---|---|---|
| All implementation, plumbing, game logic | Grok | `main` — **sole writer** |
| Interface and visual design work | Claude Code | Feature branches only, PR to Seth |

Constraints:

- Claude Code gets **branch access only**. Never writes to `main`.
- Claude Code's branches are scoped to **interface files only**. If it
  starts touching game logic, that's merge pain — reject the PR.
- Seth reviews and merges every PR. No auto-merge.
- Grok owns `main` and is the only thing committing to it directly.

Rationale: single writer to `main` means they can't collide, because
they're never writing the same ref. Claude Code (Opus / Fable) does
materially better interface design work than Grok, so route visual
work there and let Grok implement everything else.

**Reference material:** Game UI Database, Interface In Game —
screenshot collections for menu system reference.
