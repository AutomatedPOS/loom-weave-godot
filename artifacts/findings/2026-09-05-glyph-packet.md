# Findings — glyph packet

Date: 2026-09-05. Seat: Grok. Owner handed the glyph-look packet
from the extra commits on PR #18's branch. Hats from the first
noun pass (PR #22) are superseded. Picture first:
`artifacts/glyph-look/glyph-modes.png`, then the two sheets.

## Beats

### 2026-09-05 — Packet landed

`artifacts/glyph-look/` is in this repo. One geometry in
`glyphs.py` makes every file. `tokens.json` is the source for both
palettes, the 64-unit tile, and the state and modifier rules.

Four tiles: human (circle + round head and shoulders), robot
(same circle, boxy head, visor, antenna), process (flowchart
rectangle + three-station spine), tool (double-barred rectangle +
spanner). Null is a dashed square. Diamond retired.

Accents, both modes:

| Accent  | Dark    | Light   |
| ------- | ------- | ------- |
| hazard  | #8B1E1E | #8B1E1E |
| task    | #D99A1F | #A06E10 |
| changed | #6B8FAE | #4F7291 |

Light is a true inverse. Hazard keeps oxblood. Task and changed
pull down on white so they read (open call five if the owner would
rather hold one value).

Interface: `LoomTokens.apply_mode` picks dark or light.
`Canvas._glyph` draws the four tiles at 24 px with stroke snapped
to 1 px. Empty sockets are the frame of the kind, 48 px, no skin.
Drop tests `frame_has_point`. Rail chips stay tablet-size; the
frame is the socket hit, not a smaller grab on the chip.

Placeholders only: Archivus human, Brains robot. Owner still
decides who is which.

Bible patch for loom: `artifacts/glyph-look/BIBLE.md`. This sitting
cannot push `AutomatedPOS/loom`.

First screen stays the close-out. Rails stay off. Nothing in the
packet restored them.

Godot after-image: `artifacts/findings/2026-09-05-glyph-packet.png`
when the capture ran.

`glyph_smoke` and `theme_smoke` cover both palettes, the four
skins, stroke snap, and frame-as-hit. The other smokes stay green.

Close-out:

- **justDid**: Packet tiles in the interface. Diamond retired. Both palettes.
- **next**: Owner Check of glyph-modes.png. Then the open calls, one at a time.
- **waitingOn**: The owner's look.
- **generic**: Frame is the hit. Skin swaps. Hats are not the grammar.
