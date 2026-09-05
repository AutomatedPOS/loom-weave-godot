# Findings — Comfy glyph machine

Date: 2026-09-05. Seat: Grok. Owner asked for a Comfy loop to mint
tiles without asking a sitting each time.

## Beats

### 2026-09-05 — Brief, not a bible rewrite

`tools/comfy-glyphs/BRIEF.md` is the handoff the bible already
named (out of scope item three). Grammar from
`loom/DESIGN-BIBLE.md`. Orange is out. Valve art is not used.

Default field is white, so a tile can sit on the white window.
`--field sign` is the charter dark sign face.

### 2026-09-05 — The loop

Describe. Queue. Four squares. Seed randomizes. Queue again until
one is right. Pull copies into `artifacts/glyphs/picked/`.

Does not touch `weave/`. Does not deploy.

Close-out:

- **justDid**: Comfy glyph machine. Prompt lock, workflow, queue.
- **next**: Owner runs it locally. Weave stays white.
- **waitingOn**: A tile he keeps.
- **generic**: When artwork is out of bible scope, hand off a
  locked generator, not a drawing.
