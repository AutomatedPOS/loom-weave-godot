# Glyph packet

For Cursor. Two things to commit: the grammar and values into the
tier-one bible as canon, and the tiles and tokens into the interface.
Everything in this folder is the packet. Nothing under `weave/` was
touched for it.

Look first: `glyph-modes.png`, both modes on one picture. Then
`glyph-sheet-dark.png` and `glyph-sheet-light.png`, each 1440 by 900.

## Files

| File | What |
| --- | --- |
| `glyph-modes.png` / `.svg` | both modes, one picture: the four tiles, the seven states, the rail chips, the three accents |
| `glyph-sheet-dark.png` / `.svg` | the full reference sheet on the black field |
| `glyph-sheet-light.png` / `.svg` | the same sheet on the white field |
| `tiles/dark/*.svg`, `tiles/light/*.svg` | single 64-unit tiles: `persona-human`, `persona-robot`, `process`, `tool`, each hollow and `-solid`, plus `null-tile` |
| `tokens.json` | both palettes, the tile geometry, the state and modifier rules, machine-readable |
| `glyph-look.md` | the rationale: why each frame, why each skin, sizes, the drag and drop rules, the primitives for the rigged models, the open calls |
| `glyphs.py` | the generator; `python3 glyphs.py <outdir>` remakes every SVG from one geometry |

## What goes into the bible

Section 4.2, machine values. The accents, with the owner's values:

| Accent | Role | Dark | Light |
| --- | --- | --- | --- |
| 1 hazard | broken | #8B1E1E | #8B1E1E |
| 2 current task | where you are | #D99A1F | #A06E10 |
| 3 changed since | moved since last look | #6B8FAE | #4F7291 |

Hazard keeps one value in both modes; oxblood reads on white and,
at the darkest shade whose line still shows, on black. Task and
changed pull down on white so they read; the hue holds.

Section 4.3, the skins as drawn. Persona is the avatar circle with a
round human skin or a boxy robot skin. Process is the flowchart
rectangle with a three-station spine. Tool is the flowchart
predefined-process rectangle with a spanner. The diamond the canvas
uses for tools today is a decision in the borrowed vocabulary and
retires.

Section 4.5 and 4.7, the state and modifier treatment as the sheets
show it: hollow, solid, subdued at 20 %, hazard on the skin; task on
the frame with a pulsing ring, changed on the frame, top two show.

Two modes. The field in light mode is white, and white is absence
there exactly as black is in dark.

## What goes into the interface

- `weave/theme/Tokens.gd`: the dark values are already the live
  tokens on PR #18. Add the light set beside them and a mode switch
  that picks one; `tokens.json` is the source.
- `weave/Canvas.gd` `_glyph()`: replace the circle, square, and
  diamond with the four tiles. The frame is the hit target and the
  drop target; the skin never touches it. If the chip glyph goes to
  24 px, snap the stroke to 1 px rather than scaling 2 down to 0.75.
- Sockets on the seat take the frame shape of the kind they accept,
  so a persona socket is a circle and a process socket a rectangle.

## Open calls for the owner, unchanged from the brief

1. Persona frame: avatar circle, as drawn, or a BPMN pool band.
2. Which persona is human and which is robot. Archivus and Brains
   are placeholders on the sheets.
3. Process skin: the three-station spine, as drawn, or a plain BPMN
   task marker.
4. Chip glyph size on the rail: 12 as today, or 24 as the sheets show.
5. Light-mode task and changed: pulled down as drawn, or the dark
   values held in both modes and the contrast accepted.
