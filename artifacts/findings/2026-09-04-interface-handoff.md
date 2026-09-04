# Findings — interface handoff

Date: 2026-09-04. Seat: Grok, cloud agent
`bc-cac43192-0a08-4952-8d2e-c06eadc396e9`. Owner sitting
outside. Grok barred from the interface.

## Beats

### 2026-09-04 — Owner rejected the first visible

Monitor Do put spine, PDCA line, and a button list on
`loom.dord.dev`. Owner: ugly as sin. Grok does not touch
`weave/` again this turn.

### 2026-09-04 — Paste is the cycle-three hole

Owner cannot copy-paste API keys into the loadout. That was
the intent of the iteration. No clipboard bridge exists.
`DisplayServer.clipboard_get` is empty on the web export.
Issue `issues/credential-paste/`.

### 2026-09-04 — Packet for Cloud Code

`artifacts/interface-handoff/HANDOFF.md` plus a zip of the
tree. Job 1 paste. Job 2 restyle the monitor to the walk.
Hand back to Grok for deploy. No merge to master.

### 2026-09-04 — Handoff taken, paste first

Seat: Claude, cloud session. Branch
`claude/site-interface-design-8hc1nt`. The zip's tree is on the
branch as one commit; all four smokes passed before any change.
Paste is in `LoadoutPanel.gd`: a page-side clipboard bridge, a Paste
button beside Save Export Import, `paste_text` as the one landing.
`BUTTON_MIN_W` went 88 to 72 so four buttons fit the panel width.
Six browser cases pass in Chromium. Beat with detail on the
cycle-three findings. Monitor restyle is next.

### 2026-09-04 — Monitor restyled to the walk

`weave/Monitor.gd` is now one Control that draws the field in
`_draw()` from `TreeLoader`. No buttons, no row list. The spine
runs along the top border from this operation to the focused node,
each station with a chamber sign, number then name; no galaxy, no
iteration, nothing faked. The open PDCA words sit at the spine's
right end. The middle is the tree as a transit map: depth as rows,
siblings in date order, stations as circles, plans as squares. Live
nodes are ink, done nodes dim and still drawn. A node with no date
anywhere under it is the ghost, hollow and dashed, on a dashed run:
the plan that keeps going. The actual path is one accent line
through every dated station in date order. A node with both lived
and ghost children is a fork and wears an ink ring; today that is
`specs`. The focused node wears the accent ring and speaks on a
placard bottom left: number, name, type, state, word, then just did,
next, waiting on, body. Click a station to focus it. Only the trunk
shows by default; the branch the seat is in opens under it, so
breadth never leaves the screen. Nothing writes. Tokens added:
`ACCENT`, `GHOST`, and the line, station, row, and placard sizes.
`V_ROW` and `V_ROW_DIM` are gone with the buttons. Captures under
Xvfb and opengl3: `artifacts/monitor-plan/after-interface.png`, and
`after-interface-focus.png` with a done node in a branch focused.
Gear and loadout still work on top; the six paste cases still pass
on the web build. Not this pass: pan and zoom, a ghost toggle, depth
right, a font. `README.md` still describes the first visible; not an
interface file, left for Grok. Owner Check is the hard refresh.

### 2026-09-04 — Hand-back to Grok

`artifacts/interface-handoff/HANDBACK.md` plus a zip of the tree.
PR #13 open against master. Grok reviews, deploys `dord-dev`, owner
hard-refreshes for Check. Tree moves after the Check are listed in
the hand-back. Nothing merged by this seat.
