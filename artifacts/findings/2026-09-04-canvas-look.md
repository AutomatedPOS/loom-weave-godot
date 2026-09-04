# Findings — canvas look

Date: 2026-09-04. Seat: Claude Code, cloud session, branch
`claude/new-session-rxmjop`. Source: the `canvas-painting` packet.
This file carries the painting seat's beats so the walk file stays
Cursor's. The plumbing half is not here.

## Beats

### 2026-09-04 — First screen drawn

Packet landed at its paths. Smokes run before anything changed:
import, then `first_screen`, `loadout`, `theme`, `monitor`. All four
print `SMOKE` and exit zero. No `weave/` file touched this sitting;
the packet says the picture comes first.

The picture: `artifacts/canvas-look/first-screen.png`, 1440 by 900,
rendered from `first-screen.svg` beside it. Every colour, size, and
step in it is a token in `weave/theme/Tokens.gd` or is listed below
as one to add.

The six questions, answered:

1. The image.
2. "Where am I" lives in the centre, in the front slot. The seat's
   window is the largest and brightest thing on the field and
   carries just did, next, and waiting on in the largest type on
   screen. There is no separate placard; the placard became the
   seat. The top border carries only the clock. The path is no
   longer a spine: it is the nested frames, each one slot back and
   one step dimmer. Read inward to find yourself, outward to get
   back.
3. One accent, the orange already in `ACCENT`. It marks the seat's
   top edge, the arriving thing's ring and leader, and the
   timeline's cursor and selected period. Nothing else.
4. Tap looks, drag moves. A tap on a window brings it to slot 0 and
   the close-out with it; a tap on a docked persona talks to it. A
   drag moves a thing between slots: rail to window socket is
   attach, window to port is leave, window onto window is nest.
5. Rails always visible. The owner loses his place; the cue that is
   always there is the one he asked for. Narrow: one column of
   touch chips, 48 high and 144 wide. Ports mirror them on the
   right, open toward the field, three of the same drawing.
6. Arriving: a thing pulled from a rail keeps its leader, a dashed
   accent line with transit bends back to the chip it came from,
   and wears the accent ring while it is the newest thing on the
   field. The chip stays lit on the rail; the roster is not
   consumed. Appearing would be a thing with no line back.

### 2026-09-04 — Owner's word

Picture's right, build it. Two marks: leave the ports unlabelled,
since save fights the shape rule and export already means something
else; and keep this seat's notes in a canvas-look findings file so
they do not collide with Cursor's walk file. The earlier beat moved
here from `2026-09-04-canvas-walk.md`, which is back to the packet's
text.

### 2026-09-04 — Built

`artifacts/canvas-look/after-first-screen.png` is the window,
captured by `weave/capture.gd` under Xvfb at 1440 by 900. Look at it
before reading on.

What landed, all under `weave/`:

- `Canvas.gd`, one Control on the Interface layer, draws the whole
  surface in one `_draw()` from `TreeLoader`. No child controls.
  Rails, field, ports, clock, timeline. Draw order is the slot
  spec's: ancestors as frames back to front, the seat's siblings as
  tiles, the seat at slot 0, then the interface track.
- `Main.tscn` adds `Canvas` under `Interface` and hides `Monitor`.
  The monitor stays in the scene, off the window, so its smoke keeps
  passing and the owner can strike it in its own beat.
- `theme/Tokens.gd` grows a canvas block: `TEXT_XL`, `TOUCH_H`,
  `RAIL_W`, `FIELD_TOP`, `FRAME_STEP`, `SEAT_W`, `SEAT_H`,
  `SEAT_GUTTER`, `SEAT_HEAD`, `CLOSEOUT_STEP`, `SOCKET_STEP`,
  `CHIP_W`, `CHIP_H`, `TILE_W`, `TILE_H`, `TILE_MORE_W`,
  `TIMELINE_H`, `TIMELINE_DAYS`, `HANDLE_W`. No colour added; the
  nine that exist are the whole palette.
- `canvas_smoke.gd`, new. `first_screen_smoke.gd` now wants the
  canvas visible and the monitor hidden. All five smokes print
  `SMOKE` and exit zero.

What the window does:

- The seat is the node in Do, else the latest live node, else the
  root. Today every node but the root is done, so the seat is the
  operation itself, at slot 0, with nothing to frame it. The frames
  appear as soon as the seat is anywhere below the root: tap a
  tile and see them. The picture had two frames because it showed
  a plan under this operation; the tree does not have that node
  yet. Not filled.
- Tap a tile behind the seat and it becomes the seat. Tap a frame's
  label band and the seat steps back out to that ancestor. Tap a
  docked persona and `persona_tapped` fires with its name; nothing
  answers it yet, that is the persona pipe.
- Drag a rail chip onto the seat's socket of the same kind and it
  docks, with its leader back to the rail. The rail keeps the chip.
  A drop on a socket of another kind does nothing. Drag a docked
  chip into any port and it leaves the field. What is docked lives
  in memory only; the shape store is the other half.
- The timeline shows `TIMELINE_DAYS` days ending on the last dated
  day in the tree. Dated nodes are stations, spread through their
  day in path order, since the tree carries dates and no times.
  Press or drag on the band and the position moves; the clock reads
  it and says `NOW` or `−N D`. Tiles dated after the position draw
  as ghosts. The selected period is the day the cursor is in. The
  right handle's width is now.
- Ports are three, the same drawing, open toward the field, no
  text. Which is which is still OPEN 3.

Assumed, because the plumbing is the other half:

- Rosters are constants in `Canvas.gd`: personas Brains, Archivus,
  Fixer; processes Brief, Walk, Close; tools Capture, Tree,
  Checkers. Names only, so the rails hold something. The rail pipe
  replaces them.
- Zoom and period selection by handle are not built. The scale is
  fixed at four days and the period follows the cursor. One beat
  when the timeline's read semantics land.
- No pinch. Touch arrives as emulated mouse, which Godot does by
  default on the web export, so tap and drag work on the tablet.

Not this beat: `README.md` still lists four smokes and describes the
monitor; it is outside the interface files this seat may touch, so
the fifth smoke and the canvas are not written there. Deploy is
Grok's.

Close-out:

- **justDid**: Built the canvas to the approved picture. Five
  smokes green. Capture shipped.
- **next**: Owner's Check on `after-first-screen.png`, then the
  marks. Grok deploys `dord-dev`.
- **waitingOn**: The owner's look, and the plumbing half for
  rosters, the persona pipe, the shape store, and the timeline's
  read semantics.
- **generic**: Build to a picture by making every number in the
  picture a token, drawing in one pass in the picture's slot order,
  and letting the smoke assert the picture's claims: touch targets,
  unlabelled ports, tap looks, drag moves, nothing writes.
