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
