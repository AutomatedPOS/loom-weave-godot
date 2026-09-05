# Bible patch — glyph packet, 2026-09-05

For `AutomatedPOS/loom` `DESIGN-BIBLE.md`. This sitting cannot
push that repo. Land these replacements on the next loom commit.
Source: `artifacts/glyph-look/PACKET.md` and `tokens.json`.
Picture: `glyph-modes.png`.

Open calls stay open: persona frame circle vs BPMN pool; who is
human and who is robot; process spine vs BPMN task marker; chip
12 vs 24; light-mode accents pulled down vs held.

## 4.2 Accents — machine values

Keep the existing rule_text. Add both-mode values to machine_value.
Hazard keeps one value; task and changed pull down on white so they
read. Hue holds.

| Accent | Role | Dark | Light |
| --- | --- | --- | --- |
| 1 hazard | broken | #8B1E1E | #8B1E1E |
| 2 current task | where you are | #D99A1F | #A06E10 |
| 3 changed since | moved since last look | #6B8FAE | #4F7291 |

**machine_value** — accent_1=hazard #8B1E1E / #8B1E1E; accent_2=current_task #D99A1F / #A06E10; accent_3=changed_since #6B8FAE / #4F7291. Colour-blind-safe set, swappable. Orange is out. Contrast is against each mode's field.

## 4.3 The glyph tile — skins as drawn

Keep the two-frame rule. Add the skins the packet drew:

Persona is the avatar circle with a round human skin or a boxy
robot skin. Process is the flowchart rectangle with a three-station
spine. Tool is the flowchart predefined-process rectangle (double
bars) with a spanner. The diamond the canvas used for tools is a
decision in the borrowed vocabulary and retires.

**do_examples** — A persona drawn as a man, a woman, a dragon, an
animal — the slot in the grammar does not change. Human and robot
share the circle; the silhouette channel says who.

**dont_examples** — Inventing a new shape. A diamond for a tool.

**machine_value** — persona_frame=circle r 28 in a 64 tile; process_frame=rect 4,10 56x44; tool_frame=that rect plus bars at x 11 and x 53; skins=human,robot,process,tool; diamond=retired.

## 4.5 State on a glyph

Keep hollow / solid / motion / subdued / broken. Subdued is the
whole tile at 20 % opacity (eighty percent knocked back). Broken
takes hazard on the skin; the frame stays ink unless a higher
accent claims it.

**machine_value** — hollow=not_started; solid=done; motion=running; subdued=abandoned opacity=0.2; broken=skin fill hazard.

## 4.7 Modifiers — treatment as the sheets show

Keep ranked task, hazard, changed, two show. Add where each lands:

- current task: the frame takes TASK, and a thin ring outside it
  (persona r 32, else rect 0,6 64x52) in TASK at 50 %, pulsing.
- broken: the skin takes HAZARD; no fill of its own.
- changed since: the frame takes CHANGED.
- task and broken together: frame task, skin hazard. Changed drops.

**machine_value** — max_visible_accents=2; precedence=current_task,hazard,changed_since; task_target=frame+ring; hazard_target=skin; changed_target=frame.

## Two modes (under 4.1 / 4.2)

The field in light mode is white, and white is absence there
exactly as black is in dark. Geometry is identical. Palettes live
in `artifacts/glyph-look/tokens.json`.
