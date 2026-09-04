# Findings — canvas plumbing

Date: 2026-09-04. Seat: Grok, cloud agent. Packet
`canvas-plumbing`. `weave/` not touched. Painting is the other
half.

## Beats

### 2026-09-04 — Packet landed

Spec, walk findings, and `plans/canvas/` at the paths the packet
named. The plan node is guid `0c06c5de-3c59-4526-a0a8-81dafca13a80`
and points at the spec, not at a second plan file. `artifacts/canvas-plan/`
is the Do list this seat wrote against that spec. Do is
`canvas-plumbing`.

### 2026-09-04 — Plan node is the packet's

First landing minted a guid and marked the plan done. Wrong. The
packet's node is `active`, points at `canvas-spec.md`, and waited
on primitives. Primitives are now researched. Close-out on that
node was rewritten; identity was not.

### 2026-09-04 — Primitives, not invented

Instructional and actionable already sit on Dietz
informa/performa, Gery instruction/performance, Searle
assertive/directive, and OPM enable/transform. Malone's
Create/Destroy/Modify/Preserve specialise actionable. Dietz forma
is the one extra kind the literature insists on; it was not added.
It may be the tools rail. Spec OPEN 1 stays open.

### 2026-09-04 — Three rosters in the tree

Parents at `rosters/personas`, `rosters/processes`, `rosters/tools`.
Address is guid. Personas: Brains, Archivus, Fixer. The only
process child is `brief`, which the owner named. Tools has no
children. WALK, CLOSE, CAPTURE, TREE, CHECKERS are not nodes.

### 2026-09-04 — Pipe binds, it does not talk

`bind(persona_guid, loadout)` needs the guid on the personas rail
and a chat endpoint. The binding is `{ persona, cap: "chat" }`.
Credential stays in the loadout. No HTTP client. Inbox address
format is OPEN.

### 2026-09-04 — Shape is a query

Allowlist: windows, attachments, slots, asks. Refill at T reads
the dated tree and does not write back. A body, a child list, a
transcript, or a credential in a shape fails
`scripts/test_canvas_model.py`. Twenty-five tests, all green.
Hours on the timeline do not change the read: nodes are UTC days.

### 2026-09-04 — Interface, left for painting

- Rails read children of the three roster parents, by the `roster`
  prop, not by folder name.
- Save of a shape wants the same two stores as loadout:
  `user://` on the browser, export a file. That is a `weave/`
  change. Not done.
- TreeLoader will now show the roster nodes on the monitor. They
  are real. Do not hide them by editing `weave/`.
- GDScript port of `scripts/canvas_model.py` waits until this
  seat may touch the engine side of the window.

### 2026-09-04 — Painting merged, rails join the tree

Owner merged PR 15. Plumbing had one conflict: a wrap in the spec.
Took master's wrap. Rails no longer use stand-in names. They read
the roster parents. Tools is empty. Walk, Close, Capture, Tree,
Checkers are off the window. Docked chips still live in memory;
shape save on the browser still waits.

## Owed, still

Spec OPEN 3, 4, 5. Inbox format. Authored processes besides brief.
Any tool. Time of day. Whether talk persists (under the current
rule it does not).

## Close-out

- **justDid**: Merged painting. Rails read the tree. Invented
  roster names are off the window.
- **next**: Owner merge of PR 16. Deploy if the joined window is
  accepted.
- **waitingOn**: Owner merge. OPEN 1, 3. Inbox format. Any tool.
- **generic**: A view that must not go stale abstracts to a query:
  store which panes, which attachments, which asks; refill from
  the dated source at T; never copy the rows into the saved view.
