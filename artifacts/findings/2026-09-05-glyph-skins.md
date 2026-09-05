# Findings — glyph skins, second pass

Date: 2026-09-05. Seat: Grok. Owner asked for a better stab at
Claude's skins. Frames unchanged. Picture:
`artifacts/findings/2026-09-05-glyph-skins.png` (Claude above, this
pass below). Canon sheets regenerated in `artifacts/glyph-look/`.

## What moved

- **Human.** Cropped bust replaced with a sphere on a closed capsule.
  Neck is the gap. Body stays inside the skin box.
- **Robot.** Antenna no longer kisses the circle. Cube on cube, visor
  is the face, stub antenna on the head.
- **Process.** Stations 10-unit. Spine only in the gaps, so hollow
  still reads as three cubes on a rod.
- **Tool.** Open-end spanner with a real C-jaw. Claude's inner bar
  made a keyhole; that is gone.

Same 64 tile, 2 stroke, borrowed frames, both palettes. Godot
`weave/Glyphs.gd` matches `glyphs.py`.
