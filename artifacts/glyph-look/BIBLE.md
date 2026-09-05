# Bible patch — drawn skins, 2026-09-05

For `AutomatedPOS/loom` `DESIGN-BIBLE.md`. This sitting has no
push on that repo (`cursor[bot]` 403). The full proposed file is
`DESIGN-BIBLE.proposed.md` in this folder: drop it in as
`DESIGN-BIBLE.md` on loom master.

Owner Check of the skins, 2026-09-05: go with this pass, not
Claude's cropped bust. Picture:
`artifacts/findings/2026-09-05-glyph-skins.png`.

Open calls stay open: persona frame circle vs BPMN pool; who is
human and who is robot; process spine vs BPMN task marker; chip
12 vs 24; light-mode accents pulled down vs held.

## 4.1 The field

Light mode: the field is white, and white is absence there
exactly as black is in dark.

**machine_value** — dark_field=#000000; light_field=#FFFFFF; field_is_absence=true

## 4.2 Accents — machine values

| Accent | Role | Dark | Light |
| --- | --- | --- | --- |
| 1 hazard | broken | #8B1E1E | #8B1E1E |
| 2 current task | where you are | #D99A1F | #A06E10 |
| 3 changed since | moved since last look | #6B8FAE | #4F7291 |

Hazard keeps one value; task and changed pull down on white so they
read. Hue holds.

## 4.3 The glyph tile — skins as drawn

Persona is the avatar circle with a human skin (sphere on a closed
capsule, neck is the gap) or a robot skin (cube on cube, visor slot,
stub antenna). Process is the flowchart rectangle with three
stations on a rod; the spine reads only in the gaps. Tool is the
flowchart predefined-process rectangle (double bars) with an
open-end spanner. A diamond is a decision in that vocabulary and
is not a tool.

**machine_value** — tile=64; stroke=2; skin_box=16,16 32x32; persona_frame=circle r 28; process_frame=rect 4,10 56x44; tool_frame=that rect plus bars at x 11 and x 53; skins=human,robot,process,tool; diamond=retired

## 4.5 State on a glyph

**machine_value** — hollow=not_started; solid=done; motion=running; subdued=abandoned opacity=0.2; broken=skin fill hazard

## 4.6 The null tile

In light mode white is the same absence black is in dark.

## 4.7 Modifiers — as the sheets show

- current task: the frame, and a thin ring outside it (persona r 32,
  else rect 0,6 64x52) in task at 50 %, pulsing.
- broken: the skin takes hazard; frame stays ink unless a higher
  accent claims it.
- changed since: the frame takes changed.
- task and broken together: frame task, skin hazard. Changed drops.

**machine_value** — max_visible_accents=2; precedence=current_task,hazard,changed_since; task_target=frame+ring; hazard_target=skin; changed_target=frame
