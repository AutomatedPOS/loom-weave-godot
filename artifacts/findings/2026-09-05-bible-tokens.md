# Findings — bible tokens

Date: 2026-09-05. Seat: Claude Code, cloud session, branch
`claude/loom-theme-accent-tokens-3ixexy`. Source: the accent charter,
`2026-09-04-accent-charter.md`, against bible 4.2 and 4.7. Painting
only. Grok does not paint; the worker is not touched.

## Beats

### 2026-09-05 — Picture

`artifacts/canvas-look/after-bible-tokens.png`, 1440 by 900, captured
by `weave/capture.gd` under Xvfb with opengl3. Look at it first.

Of the three accents, one appears on the first screen: **task**. It
is on the seat's top edge, the clock's now square, the
timeline's cursor, and the selected period with its handles. Those
are the four marks that were orange yesterday. Hazard and changed do
not appear. Nothing on the tree is broken and nothing has a
changed-since state to report, so they have nothing to say. The
pixel count in the capture: 4144 near task, zero near hazard, zero
near changed, zero near the old orange.

### 2026-09-05 — Tokens

`weave/theme/Tokens.gd`. The one orange `ACCENT` is gone. In its
place, three named tokens; the values are in the later beat.

| Token   | Role     | Published as |
| ------- | -------- | ------------ |
| HAZARD  | accent 1 | `hazard`     |
| TASK    | accent 2 | `task`       |
| CHANGED | accent 3 | `changed`    |

All three sit on the Loom Theme type through `COLORS`, so any Control
reads them with `get_theme_color(name, LoomTokens.THEME_TYPE)`. The
precedence rule from 4.7 lives beside them as `ACCENT_RANK`, task then
hazard then changed, and `ACCENT_SHOW`, two. No drawing code consults
the rank yet, because no mark on the canvas wants two accents today.
The rule is in the token file so the day one does, the order is not
invented at the call site.

### 2026-09-05 — Every old use is current task

Eight uses in `weave/Canvas.gd`, three in `weave/Monitor.gd`. All
were position markers: the seat's top edge, the arriving chip's ring
and its leader, the clock's now square, the timeline's cursor and
selected period; and on the hidden monitor, the lived spine, the
trail, and the focus ring. All point at `TASK`. None was hazard.
None was changed-since. No new mark was drawn. Hazard is not painted
on the timeline to use the token. Changed-since is not faked.

### 2026-09-05 — Smokes

`theme_smoke` now asserts the three accents are on the Loom type,
opaque, distinct, none the old orange, the old `accent` name gone,
and the rank task, hazard, changed with two shown. `canvas_smoke`
asserts `Canvas.gd` names `TASK`, not `ACCENT`, and does not name
`HAZARD` or `CHANGED` while it has nothing to say with them; that
line moves the day the canvas has a hazard to show.

A first draft of the orange check was a hue range and it caught a
vermillion that was briefly the hazard. The check is now the one old
value, `Color(0.93, 0.45, 0.13)`.

Import, then `first_screen`, `loadout`, `theme`, `monitor`, `canvas`:
each prints `SMOKE`, exits zero, on Godot 4.3 stable headless.
`grep -rn -E 'Color\(|font_size' weave` returns only `weave/theme/`,
the smokes, and `ThreadCard.gd`. Gear still opens the loadout;
`loadout_smoke` covers paste. Tablet IME files untouched.

### 2026-09-05 — Not this pass

Sky, water, middle bands. Glyph artwork. Hearing. Shape save. Bind.
Port labels. Invented rail chips. A tool. A font. Pan and zoom.
Refresh. `README.md`, whose lines 20 to 22 still say the orange
accent does not match the bible; that is stale after this lands and
is the README's own beat.

### 2026-09-05 — Owner's word: the colours

Glyphs right, colours wrong. The first set, Okabe–Ito minus orange,
had a vermillion for hazard that read as orange, and orange is the
current task, not the error. The error is oxblood. The owner named
his own set, and the accents are now:

| Token   | Role                  | Hex     | On black |
| ------- | --------------------- | ------- | -------- |
| HAZARD  | broken                | #8B1E1E | 2.3:1    |
| TASK    | where you are         | #D99A1F | 8.6:1    |
| CHANGED | moved since last look | #6B8FAE | 6.2:1    |

Oxblood is dark by nature. Six shades were laid on black and #8B1E1E
is the darkest whose three-pixel line still reads; the owner can
pull it darker if the fill areas carry it. Amber is the owner's.
Steel blue is the third because it is cool against two warm marks
and stays distinct from both under red-green colour blindness; a
red, a yellow, and a blue separate by hue and by value. Contrast is
against the black field.

Recaptured `after-bible-tokens.png`: 4144 pixels near task, zero
near hazard, zero near changed, zero near the old orange. The glyph
sheet in `artifacts/glyph-look/` is regenerated on the same values.
Six smokes green.

Close-out:

- **justDid**: Replaced the one orange accent with hazard, task,
  changed on the Loom type, then set them to the owner's oxblood,
  amber, and steel. Pointed every old use at task. Capture and six
  green smokes.
- **next**: Owner's Check on `after-bible-tokens.png`. Owner merges.
  Grok deploys `dord-dev`. Hard refresh. That is Check of the joined
  canvas and the tokens.
- **waitingOn**: The owner's look.
- **generic**: When a palette rule names roles, give every role a
  token even if only one is used today, and let the smoke say which
  ones are allowed to be silent.
