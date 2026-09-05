# Findings — noun glyphs

Date: 2026-09-05. Seat: Grok. Owner asked for the three
iconographs: personas, processes, tools. Bible 4.3 / 4.4.
Picture first: `artifacts/findings/2026-09-05-noun-glyphs.svg`,
then the Godot capture beside it.

## Beats

### 2026-09-05 — Three marks, one bust

White ink on black. No tile fill. Round is human, square is
machine. Hats are how a persona takes a role; the body does not
change.

| Kind     | Outer            | Inner                         |
| -------- | ---------------- | ----------------------------- |
| persona  | round (bust)     | head and shoulders            |
| process  | settled rectangle | three bars, the steps        |
| tool     | machine square   | wrench                        |

A fourth mark on the sheet is the same persona bust with a brim
and crown. Caption: `a role is a hat`. No Brains / Archivus /
Fixer costume this pass. Role-specific hats wait on a later loop.

`weave/Glyphs.gd` is the drawing. `Canvas._glyph` calls it, so the
paused rails pick the new marks up when they come back. The first
screen stays the close-out. Rails stay off.

Capture: `artifacts/findings/2026-09-05-noun-glyphs.png`, 1440×900.

`glyph_smoke` prints `SMOKE` and exits zero. The other six still do.

Close-out:

- **justDid**: Three noun marks. Persona is a bust. A hat is a role.
- **next**: Owner Check of the picture. Then which hat is which, if
  he wants that.
- **waitingOn**: The owner's look.
- **generic**: One body, modifiers for role. Do not draw a new
  person for each job.
