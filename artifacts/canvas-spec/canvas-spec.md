# Canvas spec

The composition model for the weave. This supersedes the monitor as
the thing the window is. The monitor rendered a tree. This is a
surface the owner composes on, with the model beside him.

Written from the owner's walk, 2026-09-04. Where a thing is settled
it is stated flat. Where it is open it is under OPEN at the end.

## The shape

Inputs on the left. Work in the middle. Outputs on the right.

This is not the filesystem shape. It is the object shape: a thing
with inputs, encapsulated behaviour, and outputs. The courier's
inbox/working/outbox is one instantiation of it. So is a Unix pipe.
So is this window. The shape recurs because it is the shape, not
because the renderer borrowed it from the courier.

Landscape only. The bands are horizontal and the reading order is
left to right. A portrait viewport has nowhere to put the rails. A
phone turns sideways or it does not show this interface.

## The three rails

Three input rails on the left edge. In order, top to bottom:

**Personas.** A roster. Each is pre-trained to the organisation's
spec. Pulling a persona onto the field is how context is loaded —
the persona carries what it knows, and that knowledge becomes
available to whatever it is attached to. A persona on the field can
be tapped and talked to directly. Each has its own voice.

**Processes.** A roster of processes the owner has authored. Pulling
one runs it. A process is not a document to read; it is something
you run against an object. "Brief" is a verb. A running process
plays out in acts and scenes, and any personas attached to it narrate
it as it runs.

**Tools.** A roster of tools. A tool does a thing. Alone it is inert.

A rail item is not consumed by being pulled. The roster is a source,
not a queue.

## Composition by attachment

The three rails are primitives. Everything else is composed by
attaching one to another.

- Persona onto tool: the persona operates the tool.
- Persona onto process: the persona walks the process with the
  owner, in its own voice.
- Process onto object: the process runs against that object and
  reports.

Attachment is the only composition operator. There is no wiring
mode, no separate editor, no second grammar. You drag a thing onto
a slot and it is attached.

## Recursion

Every window on the field carries the same slots the field carries.
A composed thing is itself a thing that can be composed. A process
running in a window can have a persona dropped onto it; that window
can then be dropped onto another.

There is no depth limit and no special case at any level. The field
is a window. The window is a field.

## Output ports

Ports on the right edge take things off the field.

Discard is a port. It is not a bin, not a gesture, not a modifier
key. You move a thing to the right and out through whichever port
you mean, and one of the ports is oblivion. Save and discard are the
same motion with different targets.

This keeps the grammar symmetric — things enter left, leave right —
and removes deletion as a special case.

## Shape, not data

**The owner never saves data. The owner saves the shape.**

A saved view is the arrangement: which windows, which attachments,
which slots, what each pane is asking for. It is a query, not a
snapshot.

The data is always in the tree. To see what a shape held at some
moment, you scrub the timeline to that moment and the shape refills
itself from what was true then.

Consequences, all of them wanted:

- Nothing goes stale. There is no cached copy to expire.
- There is no sync problem and no merge. A shape has one version.
- There is no "which copy of this panel is right."
- A shape written today works on data written next month.
- History is not a feature added later. It falls out of the rule.

A renderer that writes a data snapshot into a saved shape has broken
this spec, however convenient it was at the time.

## The timeline

A scale along the bottom edge. Hours, minutes, days. Zoomable in and
out, grabbable, and a period can be selected.

It is not a new data structure. The tree is already dated on every
node, and the accent path already runs through the dated stations in
order. The timeline is that axis, made grabbable, and it is the
control that drives the refill described above.

## The clock

Upper corner. Transparent, not a hard-set panel. It reads the
current position on the timeline, which is not always now.

## What the personas are

The people standing behind the owner. Brains, Archivus, Fixer are
the ones that exist. Brains is the owner's own right hand. They are
already real in the bot network with real inboxes; the rails give
them a face.

## OPEN

1. **Process primitives.** The owner's read is that there is a small
   base set of process types and everything else composes from them.
   Instructional and actionable are two he named. This wants
   research against existing process taxonomies before anyone
   invents one. Held at `artifacts/process-primitives/`.
2. **Persona pipe.** How a persona pulled onto the field becomes a
   thing you can tap and talk to. Endpoints exist in the loadout;
   the binding from rail item to live session does not.
3. Which port is which, and how many.
4. What a tap does versus what a drag does.
5. Whether the rails are always visible or summoned.

## What this does not change

The renderer reads. Nothing on this canvas writes to the tree.
Backdrop stays black. Gear stays bottom-right. Every colour, size,
and font size is a token in `weave/theme/Tokens.gd`. Save stays on
the browser; export writes a file, import brings it back. No vendor
names under `weave/`.
