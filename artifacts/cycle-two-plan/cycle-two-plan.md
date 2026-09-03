# Cycle two plan

PDCA. This file is the Plan step of the second Weaver turn in
`loom-weave-godot`. It is not a spec of its own.

## Target

Rule the first screen.

- Backdrop is black. True black, not the warm brown of turn one.
- Content slots are empty. The card forms come off.
- The interface track holds one control: a settings gear.
- The gear sits bottom-right, the corner most apps put that chrome.
- The mark is a light, subdued gray on the forefront. Nothing else
  on that track.

The workItem is `first-screen`.

## Why this cycle

Turn one put instantiation on screen, then filled it with a status
view of the loom tree. Cycle one had already said a black screen was
enough, and that the first screen stayed unruled. Cycle two takes
the ruling the owner named from outside: strip the forms, return to
black, leave only the interface gear.

Self-render of the tree is not deleted from the repo. It is off the
window. TreeLoader and the card script stay for a later turn.

## Not this cycle

- A settings panel. The gear is the chrome. What it opens is unruled.
- Slot occupancy, colours beyond black and the gear gray, centre
  object, frame, grid.
- Apollo hook. Still parked.
- Host-map changes. `dord.dev` and `loom.dord.dev` stay as named.
- Promote into `loom-weave`.
- Schema edits in `loom-warp`.

## Interface

This repo's operation seat is the interface for cycle two.

- Writes and checks every `thread.json`.
- Files findings in `artifacts/findings/`.
- The Do runs from the cloud agent. The owner does not sit at the
  desktop for this turn.
- The Do includes commit and push. The owner sees the turn from a
  tablet. Unpushed work is invisible. Check waits until the commit
  is on the remote. Issue: `issues/do-includes-push`.

## Success bar

Cycle two Check passes when Godot loads the main scene and the
viewport is a black field with one subdued gray settings gear in the
bottom-right, and no card forms or interface bar. A leftover title,
just-did line, status line, or paper card is a fail.

## After

The first screen is ruled. Later turns can put content back on slots
or open what the gear means. Not before this Check.
