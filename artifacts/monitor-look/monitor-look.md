# Monitor look — return packet for Grok

Date: 2026-09-04. Seat: Claude, cloud session. Source: the findings of
the monitor walk (Grok, 2026-09-04) and the owner's reference list,
given by voice the same night. Not a PDCA cycle. Not a Plan. This is
the look and feel of the monitor, bound to what the walk already
fixed, written so Grok can import it. Owner sitting outside. First
screen stays black.

This folder carries no `thread.json` on purpose. The walk said Seth
names the landing paths and does not mint a `monitor/` node. The
import is Grok's: name the path, mint the node, point `representedBy`
at this file. Section 8 says how.

## 1. The four references

The owner named four things and said blend them. What each one
gives the monitor, and nothing else from it.

| Reference | What it is | What the monitor takes |
|---|---|---|
| Absolute Drift | Top-down drift game. One field, one accent, thin flat geometry, no gradients, no chrome. Tyre marks stay on the ground. | Restraint. One accent colour. Stillness until the user moves. The trail: where you have been stays drawn. |
| Portal 2, Perpetual Testing Initiative | The Aperture propaganda posters and chamber signage. Flat vector, cream and orange, numbered figures, small-caps labels, one dry line of copy. | The chrome. Labels read like chamber signs: a number, a name, small caps. Facts stated flat. |
| Path of Exile, passive tree | A web of chained nodes on a dark field. The allocated path is lit. Everything not taken stays visible, dim. Nothing moves until you pan. | The middle. The tree is a web. The actual path is lit. Untaken branches stay on screen, dim. |
| Mini Metro, and transit diagrams generally | Lines with stations. 45 and 90 degree bends. Interchange rings where lines meet. Thick even strokes. No text on the line. | The line vocabulary. The spine is a line with stations. The planned path is a line. The fork is an interchange. |

The owner's "vanilly diagrams" is read as transit and schematic
diagrams, Beck's Underground map and its descendants. If it meant
something else, that is one beat on this file.

## 2. The blend, in one sentence

A transit map of the tree, on the black field the first screen
already owns, with one accent, and chamber-sign labels.

Absolute Drift's white field is not taken. The bound says the first
screen stays black, and the monitor is a view behind that screen,
not a replacement for it. Absolute Drift's restraint is taken whole.

## 3. Screen

Sketch beside this file: `monitor-look.svg`, 1440 by 900, drawn
from the tree as it stood on 2026-09-04, every node placed by the
rules below and none moved by hand.

```
 ┌────────────────────────────────────────────────────────────────┐
 │ ◌ - - - - - - ●━━━━━━━━━━━━◉ - - - - - - ◌                     │  spine
 │ 01 GALAXY     02 LOOM     03 LOOM-WEAVE-GODOT     04 —         │
 │                                                                │
 │                           ◉ 03 loom-weave-godot   ← fork ring  │
 │                           ┃╎                                   │
 │   ┏━━━━━━━━━━━━━━━━━━━━━━━┛╎- - - - - - - - - - - - -┐         │  tree
 │   ●━━●━━●━━●━━●━━■━━■━━●━━●━━●━━◉━━■                ○ specs    │
 │   artifacts… push  first  plans… self… gear  loadout  ╎        │
 │                                            ┌ - - - - -┘        │
 │                                            ◌   ●   ●   ●       │
 │                                         act-one demo slot loop │
 │ ┌───────────────────────┐                                      │
 │ │ 03 · LOOM-WEAVE-GODOT │                                 ⚙    │  placard, gear
 │ │ just did / next / on  │                                      │
 │ └───────────────────────┘                                      │
 └────────────────────────────────────────────────────────────────┘
   ━ actual, solid accent   ╎ ghost, dashed   ◉ ring   ■ plan
```

### 3.1 Field

`BACKDROP`. Nothing else on it until the tree draws. No grid, no
vignette, no noise.

### 3.2 Spine, top border

One horizontal line, `INSET` down from the top edge, the width of
the window minus `INSET` each side. Four stations at even spacing:
galaxy, repo, operation, iteration. Under each station a two-line
chamber sign in small caps: the number, then the name. `01 GALAXY`,
`02 LOOM`, `03 LOOM-WEAVE-GODOT`, `04 —`.

The spine draws the walk's gaps as they are, not filled:

- Galaxy is not a node. Its station is hollow and its segment is
  dashed. Cross-repo pointers are OPEN, so there is nothing to
  read there and the line says so.
- The iteration counter is OPEN in loom-warp. The fourth station is
  hollow, its sign is a dash, and the line past the operation is
  dashed and stops short. Nothing is invented.

The station the seat is in draws as a ring in `ACCENT`. On
2026-09-04 that is the operation.

### 3.3 Middle, the tree

The repo's own tree, from `TreeLoader`. Depth is the row: the
operation at the top under the spine, its children one row down,
their children one further. Siblings sit across the row in date
order, `actualStart` or failing that `actualEnd`, ties in file
order, undated last. Edges follow `isPartOf`, drawn as transit
lines: one vertical drop from the parent, one horizontal run
`BUS_UP` above the child row, one short drop to each child. Bends
are 90 degrees at this node count. 45 degrees is allowed when a row
is crowded.

Thirteen nodes sit directly under the operation today, so the row
is tighter than its signs. Signs run at `SIGN_ANGLE` from the
station, down and to the right, the way the Underground map angles
a name when the stations are close. A row wide enough for its signs
drops them flat.

Nodes are stations, circles of `STATION_R`. State picks the mark:

| State or shape | Mark |
|---|---|
| `active`, `open` | filled `INK` |
| `done` | filled `DIM`. Done stays drawn. That is the tyre mark. |
| parked, `abandoned`, `superseded` | hollow, `GHOST` stroke, dashed edge in |
| the node the seat is in | filled `INK` with an `ACCENT` ring |
| a `plan` type | square instead of circle. A plan is a stop of a different kind. |

Every station has a chamber sign: `name` in small caps, `TEXT_SM`,
`DIM`, under the circle. Type is not written; the mark carries it.
No `body`, no dates, no prose on the field.

### 3.4 Planned and actual

Two lines run through the tree, on top of the edges.

- **Planned** is the ghost. `GHOST` colour, `GHOST_W` wide, dashed.
  It runs through the nodes that were planned toward, which the tree
  already marks: `plannedStart` and `plannedEnd`, and parked,
  abandoned, and superseded states. On 2026-09-04 that is the line
  from the operation to `specs` to `act-one`, the Apollo hook that
  turn one no longer goes to.
- **Actual** is the trail. `ACCENT`, `LINE_W` wide, solid. It runs
  through every dated node in date order, the same order the row is
  laid in, so it reads left to right without crossing a station it
  does not stop at. On 2026-09-04 it enters the row at the first
  artifact and ends at `plans-gear-panel`. The node the seat is in,
  `loadout`, wears the `ACCENT` ring. Where the seat is comes from
  `where.py`'s answer, not from the last date.
- **The fork** is where the actual leaves the planned. That node
  draws as an interchange: a ring of `INTERCHANGE_R` in `INK` with
  the station inside. Where the two lines share a run they sit side
  by side, `SPACE_1` apart, and part at the fork. It is the one
  place both line styles touch, so it is the one thing on the screen
  with two strokes. That is what the monitor is for.

No new field is needed. The walk said abandoned and superseded are
already how Apollo draws a ghost. This packet agrees.

Two things the field shows that the walk listed as gaps. Drawn, not
filled:

- Every node carries a date and no time. Within one day the trail's
  order is file order, not history. That is the OPEN iteration
  counter, seen from the field. The monitor does not guess.
- No node in this repo carries `plannedStart`, `plannedEnd`, or an
  abandoned or superseded state. `act-one` is parked in prose only;
  its `state` says `open`. The sketch draws its ghost from the walk's
  words. The monitor as specified would draw no ghost here until a
  node says so in data. Not filled here. Not a schema edit.

### 3.5 Placard, bottom left

One panel, `INSET` from the left and bottom, `SURFACE` fill, `EDGE`
border, `RADIUS` zero. It shows the node the seat is in: number and
name as a title on `V_TITLE`, then `justDid`, `next`, and `waitingOn`
as three short muted lines. Reading only. It is a chamber sign with
the fine print. It never covers the gear.

The placard is the one thing this packet puts on screen that is
not a line or a station. The owner can strike it.

### 3.6 Gear

Bottom right, as it is. The loadout behind it, as it is. The monitor
is a visualization the gear does not know about.

## 4. Colour

The existing seven stay as they are. Two are added. That is the whole
palette.

| Token | Value | From |
|---|---|---|
| `ACCENT` | Color(0.93, 0.45, 0.13, 1) | The Aperture orange of the posters. Also close to Absolute Drift's mark. The one colour that is not gray. |
| `GHOST` | Color(0.42, 0.42, 0.44, 0.45) | `DIM` at less than half alpha. Dashed. The planned line and parked stations. |

Aperture's blue is not taken. Two accents would make the fork read
as two teams instead of one path leaving another. If the owner's
Perpetual Testing Initiative picture shows a different orange, the
value changes and nothing else does.

## 5. Line and mark sizes

| Token | Value | Use |
|---|---|---|
| `LINE_W` | 3 | actual path, spine |
| `GHOST_W` | 2 | planned path, parked edges |
| `EDGE_W` | 1 | tree edges that carry no path. Same weight as `BORDER`. |
| `STATION_R` | 6 | node circle |
| `INTERCHANGE_R` | 10 | fork ring |
| `DASH` | 8 | dash length; gap equal |
| `ROW_H` | 160 | one depth of the tree |
| `COL_W` | 96 | one sibling across |
| `BUS_UP` | 24 | the horizontal run sits this far above its child row |
| `SIGN_ANGLE` | 30 | degrees a sign turns when the row is tighter than the sign |
| `SPINE_Y` | `INSET + STATION_R` | the spine's line |

All on the four-step scale or a multiple of it, except the angle and
the radii. The radii are even so a 3-wide stroke and a 1-wide edge
both land clean; the sketch is the check.

## 6. Type

Small caps everywhere on the field. `TEXT_SM` for chamber signs,
`TEXT_MD` in the placard, `TEXT_LG` for the placard title. No new
size.

The font is still the candidate the gear-panel pass listed. The
posters use a geometric grotesque. If the owner picks a family it
lands as `FONT` in tokens and the Theme's `default_font`, and this
packet's look tightens without a change here. Until then the Godot
default, which reads fine in small caps at `TEXT_SM`.

## 7. Motion and interaction

Nothing moves on load. Lines do not draw in. Stations do not pulse.
No timers, per the bind; the 24-hour catchall is not a visual thing.
Absolute Drift and the passive tree both hold still until the hand
moves. So does this.

Interaction is changing visualizations, the walk's only allowed
kind:

- Pan and zoom the middle. Drag, wheel, pinch.
- Ghost on or off.
- Trunk only. Collapse every row below the operation's children.
  This is Seth's breadth in one tap.
- Expand one station's children when trunk-only is on.
- Depth down or depth right. The same tree turned a quarter.

Nothing writes. Tapping a station moves the placard to it. Branching
from a node stays parked.

## 8. For Grok: the import

In order. None of it is done here.

1. **Landing path.** Seth names it. The candidates, so there is
   something to say yes or no to: this folder as it stands,
   `artifacts/monitor-look/`, with a `thread.json` of type
   `artifact`, `representedBy` `monitor-look.md`, `isPartOf` the
   root operation `65d82731-e9c3-451a-a223-be0bb4d56b06`; or the
   same folder moved under a `monitor/` node once that node exists.
2. **Mint the node.** This file has none. Write it, run the four
   checkers in loom-warp.
3. **Tokens.** Add the two colours from section 4 and the sizes from
   section 5 to `weave/theme/Tokens.gd`. Publish `accent` and
   `ghost` under the `Loom` theme type in `COLORS`. Extend
   `theme_smoke.gd` to read them back. No other file changes.
4. **A later Do,** its own plan and cycle number: `weave/Monitor.gd`,
   one Control under `Interface`, hidden by default, draws the whole
   field in `_draw()` from `TreeLoader`. One canvas, not one Control
   per node. `ThreadCard.gd` is the wrong shape for this; a card per
   node with four ColorRects and three Labels is the thing the
   memory ceiling is there to catch. That is one more voice for
   deleting it, which is still Seth's call.
5. **Refresh** stays unpicked. A full re-read on any real event is
   fine at this node count. The monitor redraws from `TreeLoader`
   and does not care which channel woke it.

## 9. Not this packet

- Not a Plan. No cycle number. No schema edit in loom-warp.
- No token added. No code. Nothing on the first screen.
- No pick on refresh, the iteration counter, galaxy pointers, or
  the memory checker's home. Section 3.2 draws those gaps; it does
  not close them.
- No deploy. Apex left alone.
- The owner may still send a picture of the Perpetual Testing
  Initiative ad. If it moves the accent or the type, that is a
  beat on this file, not a second packet.

## 10. Open to the owner

Four answers, each one line.

1. Accent: the poster orange, as proposed, or Absolute Drift's red.
2. Depth down, as sketched, or depth right as the default.
3. The placard: in, or out as not a visualization.
4. A font family, or the default a while longer.

## 11. Beat — 2026-09-04, landed

The look is on the window. Grok's handoff barred Grok from the
interface and named this seat, so the import in section 8 became a
Do. Three things differ from the packet above, all from the handoff:
the spine starts at this operation and walks to the focused node,
with no galaxy and no iteration station; a node with no date
anywhere under it is the ghost, since nothing in the tree carries
planned dates yet; and only the trunk shows until a branch is
focused. The placard stayed. The accent stayed orange. Pan, zoom,
the ghost toggle, depth right, and a font are still open. See
`artifacts/findings/2026-09-04-interface-handoff.md`.
