# Findings — canvas walk

Date: 2026-09-04. Seat: Claude, chat. Owner walking aloud, seat
capturing. No code touched this sitting.

## Beats

### 2026-09-04 — The pause read

Seat read `_pause/WHERE-WE-ARE.md`, the findings, and the screens.
Diagnosis on the shipped monitor: it is a flat list wearing a
transit map's clothes. Twenty siblings on one horizontal row,
labels rotated and colliding, two thirds of the canvas empty, and
the close-out placard shrunk into a corner. The `05-look-sketch`
had depth; the build flattened it. Token tuning does not fix a
layout that is answering the wrong question.

### 2026-09-04 — Renderer versus composer

The repo builds a renderer: read-only, reads the tree, draws it.
What the owner described wanting is a composer: spatial, mutable,
model-driven. Iterating on the monitor was not converging because
the monitor is not the shape the owner wants. Named here so nobody
sands the monitor again.

### 2026-09-04 — The reference is Minority Report

Not as decoration. The owner wants the building to be the
interaction: say "a square here, pull this data into it," and it
appears. The canvas is the conversation. Pull an image in, zoom it,
grab part of it, move it aside.

### 2026-09-04 — Views durable, data ephemeral

Owner's own split, and it became the load-bearing rule. See the
spec. The views are reusable; the contents are transient. This
later hardened into shape-not-data.

### 2026-09-04 — Inputs left, process middle, outputs right

Owner saw the shape in the reference footage and recognised it.
Seat called it the filesystem shape; owner corrected — it is the
object shape, and the courier's inbox/working/outbox is a copy of
it, not the origin. Correction taken; the spec states it the
owner's way.

### 2026-09-04 — Discard is a port

No trash bin. Things leave to the right through ports and one port
is oblivion. Save and discard become the same gesture with
different targets. Removes deletion as a special case.

### 2026-09-04 — Shape, not data

Owner: you do not save the data, you save the shape. The data is
always there; you rewind the timestamp to get that view. Saved
views are queries, not snapshots. Kills stale cache, sync, and
version-of-a-panel as classes of problem. This is the spec's
strongest constraint and the easiest one to break by accident.

### 2026-09-04 — Personas, processes, tools

Seat pushed back that these read as machinery rather than sources.
Owner rejected the pushback and was right: they are the three left
rails. A persona is a roster item, pre-trained, and pulling one in
is how context loads. A process is run against an object; it plays
out in acts and scenes with attached personas narrating in their
own voices. Tools are the third rail.

Seat's pushback is recorded because it was wrong in a useful way:
the rails are not sorted by what the data is, they are sorted by
what does the work.

### 2026-09-04 — Composition and recursion

Primitives compose by attachment. Persona onto tool, persona onto
process, process onto object. Every spawned window carries the same
slots the field carries, so a composed thing is composable. Owner
flagged the recursion himself.

### 2026-09-04 — A process is a verb

Owner's close: it is not a brief you run, it is a process you run
against an object. Brief is a verb. The report is the one the owner
authored, tailored, and has iterated on, and the schema keeps
being refined by PDCA. Iterative design: get seventy-five percent,
take the next twenty, step back for the remainder.

### 2026-09-04 — Split of seats

Grok and Cursor take the plumbing. Claude Code takes the painting.
Owner and this seat set the scene. Two packets cut from this
sitting: `canvas-plumbing` and `canvas-painting`.

## Owed

1. Process primitives research. Existing taxonomies first, do not
   invent. `artifacts/process-primitives/`.
2. Persona pipe: rail item to live tappable session.
3. Port count and meaning.
4. Tap versus drag.

### 2026-09-04 — First screen drawn

Seat: Claude Code, cloud session, branch `claude/new-session-rxmjop`.
Packet `canvas-painting` landed at its paths. Smokes run before
anything changed: import, then `first_screen`, `loadout`, `theme`,
`monitor`. All four print `SMOKE` and exit zero. No `weave/` file
touched this sitting; the packet says the picture comes first.

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
   one step dimmer. `02 · LOOM` at slot −2, this operation at
   slot −1, the seat at slot 0. Read inward to find yourself,
   outward to get back.
3. One accent, the orange already in `ACCENT`. It marks the seat's
   top edge, the arriving thing's ring and leader, and the
   timeline's cursor and selected period. Nothing else.
4. Tap looks, drag moves. A tap on a window brings it to slot 0 and
   the close-out with it; a tap on a docked persona talks to it. A
   drag moves a thing between slots: rail to window socket is
   attach, window to port is leave, window onto window is nest.
   That is the whole grammar.
5. Rails always visible. The owner loses his place; the cue that is
   always there is the one he asked for. They are narrow: one
   column of touch chips, 48 high and 144 wide. Ports mirror them
   on the right, open toward the field, three of the same drawing:
   save, export, discard. Discard is drawn like the other two.
6. Arriving: a thing pulled from a rail keeps its leader, a dashed
   accent line with transit bends back to the chip it came from,
   and wears the accent ring while it is the newest thing on the
   field at the scrub position. The chip stays lit on the rail; the
   roster is not consumed. Appearing would be a thing with no line
   back. Motion is between slots, per the slot spec, so the
   transition is the leader drawing and the thing stepping to its
   slot, with no intermediate depth.

Assumed, because the plumbing is the other half:

- Ports: three. `SAVE` writes the shape to the browser, `EXPORT`
  writes a file, `DISCARD` is oblivion. Spec OPEN 3.
- Process roster `BRIEF`, `WALK`, `CLOSE`; tool roster `CAPTURE`,
  `TREE`, `CHECKERS`. Names only, to have something on the rails.
- The seat is `04 · CANVAS`, cycle four's Plan. No node exists for
  it yet, so the mock shows this sitting's own close-out.
- The done tiles under the operation are the seat's done siblings
  from the tree: six named, the rest counted.
- The timeline shows four days with hour ticks. Nodes carry a date
  and no time, so a day spreads its nodes in file order. The
  monitor beat on that gap stands.
- Depth drawn as: slot −2 ghost and dashed, slot −1 dim and solid,
  slot 0 ink on surface with the accent top edge. Text takes its
  slot's colour.

Tokens the build will add, none added yet: `TEXT_XL` 24 for the
close-out lines, `TOUCH_H` 48 for a tablet target, `RAIL_W` 144
for rails and ports, `TIMELINE_H` 56, `SEAT_W` 736, and the socket
and port marks at `STATION_R`. Draw order per the slot spec:
backdrop, slots ascending, then the interface track carrying rails,
ports, clock, timeline, and gear.

Not done, on purpose: no `weave/` code. Step three of the packet
starts on the owner's word.

Close-out:

- **justDid**: Landed the canvas-painting packet, ran the four
  smokes green, drew the first screen, rendered it at 1440 by 900.
- **next**: Build to the picture once the owner says yes, or redraw
  once he says what is wrong. Then a `capture.gd` still under Xvfb
  with every change.
- **waitingOn**: The owner. One sentence on `first-screen.png`.
- **generic**: A packet that says picture first abstracts to: run
  what you inherited, land the words, draw the picture from the
  tokens, ship the picture with the assumptions it rests on, stop.
  The build waits on the picture, never the other way round.
