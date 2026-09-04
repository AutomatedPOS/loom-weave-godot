# Cycle four plan

PDCA. This file is the Plan step of the fourth Weaver turn in
`loom-weave-godot`. The walk of 2026-09-04 and the canvas spec are
the daydream this Plan reacts to. It is not a spec of its own.

The workItem is `canvas-plumbing`. Painting is a second packet,
not this seat.

## Target

Stop rendering the tree as the window. The window is a surface
the owner composes on. The model stays beside him in the tree.

This Plan's Do is plumbing only: the things under the surface that
have to exist before a pixel means anything. The look of the first
screen is the other half.

## This Do

Run in this order. The first is a gate: rails cannot be built
against an unknown set.

1. **Process primitives.** Research existing taxonomies. Land the
   reading at `artifacts/process-primitives/`. Do not invent a
   third kind to look complete.
2. **Three rosters in the tree.** Personas, processes, tools. Each
   roster is a source of truth: a parent node whose children are the
   rail. Address a rail item by its guid. The personas that exist
   are Brains, Archivus, and Fixer.
3. **Persona pipe.** Bind a roster guid to a live session through
   the loadout that already exists. Do not talk to a model. Do not
   invent an inbox protocol.
4. **Attachment.** One operator. A representation that survives in
   a shape and does not carry data.
5. **Shape store.** A saved shape is a query: windows, attachments,
   slots, what each pane is asking for. No node body, no children
   list, no transcript, no credential.
6. **Timeline refill.** At time T, each pane's ask is read against
   the dated tree. Work out what that read is. Do not invent a new
   date field.

## Not this cycle

- Anything under `weave/`. Layout, colour, spacing, tokens, and
  the first screen's look. If plumbing needs an interface change,
  it goes in findings and waits.
- Talking to a model. Cycle three parked that; the pipe binds, it
  does not chat.
- Port count and meaning (spec OPEN 3).
- Tap versus drag (spec OPEN 4).
- Rails always visible or summoned (spec OPEN 5).
- Writing from the canvas to the tree.
- Schema edits in `loom-warp`.
- Host-map changes. Apex left alone. No Pages deploy. `dord-dev`
  only if a later sitting has something to put on the window.
- Inventing authored processes or tools the owner did not name.
- Inventing inbox URLs, voices, or credentials for the personas.

## Where the spec is OPEN

Do not close these by guessing. What would close each one:

1. **Process primitives.** The research can recommend. It cannot
   rule. Close it when the owner says the two kinds are exhaustive,
   or names a third. The live question is whether Dietz's third
   layer (forma / datalogical) is a process kind or is the tools
   rail.
2. **Persona pipe.** Binding through the loadout can be designed
   now. The bot-network inbox still needs its address format, with
   no credential in the tree. Close it when that format is named.
3. **Ports.** A named list from the owner. Cycle three already has
   save-on-the-browser and export-a-file; the spec already names
   discard. Those are candidates, not a ruling.
4. **Tap versus drag.** A ruling from the owner. Plumbing treats
   drag as attach and leave; tap as look and talk. That is a
   reading, not a close.
5. **Rail visibility.** A ruling from the owner. Plumbing does not
   care; the roster is a source either way.

Hours and minutes on the timeline want a ruling too. Every date
on a node is a UTC calendar day. A refill at 14:00 is the same
read as a refill at 09:00 on that day, until a time field exists.
Do not invent one. loom-warp left the iteration counter OPEN;
this is the same class of hole.

## Success bar

This sitting is Plan plus plumbing Do. It passes when:

- The Plan is on the remote.
- Process primitives are a researched artifact, not an invented
  list.
- The three roster parents exist in the tree. The three named
  personas are children of the personas roster. The only process
  child is `brief`, which the owner named. The tools roster has no
  children.
- A shape file round-trips without a data snapshot. A test that
  plants a body, a child list, a transcript, or a credential in
  a shape fails the build.
- Refill at T hides a node whose `actualStart` is after T, and
  includes a node that had begun by T.
- Nothing under `weave/` changed.
- The four loom-warp checkers that this seat can run are green.

A shape that embeds tree data is a fail, even if the window looks
right.

## After

Check is the owner look at this branch. Act waits on that.
Painting is parallel. Do not wait on it, and do not merge it.
