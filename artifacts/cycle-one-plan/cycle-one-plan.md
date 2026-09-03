# Cycle one plan

PDCA. This file is the Plan step of the first Weaver turn in
`loom-weave-godot`. It is not a spec of its own.

## Target

Instantiation one on screen.

- A site exists.
- It is served over HTTPS.
- A Godot web export loads in a browser.
- A black screen is enough.

That is the first screen existing. What the first screen *is* stays
unruled.

The workItem is `instantiation-one`.

## Not this cycle

- Self-render of the loom tree. That workItem stays open. It reads
  the tree once a renderer exists.
- Apollo hook. Parked.
- Slot occupancy, colours, centre object, frame, grid. Slot spec
  already locked depth; it does not say what lands first.
- Promote into `loom-weave`. Nothing has proved out.
- Schema edits in `loom-warp`. The schema loop waits for a block.

## Owner still holds

The domain. This plan does not pick a name. The site cannot go live
without one, and without HTTPS on that name.

## Hosting constraint — talk, do not lock

Godot 4 threaded web export needs a secure context and, if threads
are on:

```
Cross-Origin-Opener-Policy: same-origin
Cross-Origin-Embedder-Policy: require-corp
```

Plain GitHub Pages gives HTTPS and cannot set those headers. Three
live options: threads off, a host that can set the headers, or
Godot's PWA service-worker workaround. The daydream talks this. The
Do does not guess.

## Thumbs

Plan gate from `loom` `PROCESS.md`. New folders, a Godot project, and
a deploy are structural. Three thumbs, then one execution pass.

This turn is a planning lap. Nothing is built.

Pain-32: do not run the Do on thumb 1 alone.

## Interface

This repo's operation seat is the interface for cycle one.

- Writes and checks every `thread.json`.
- Runs the four loom-warp checkers and `card.py` at close-out.
- Files findings in `artifacts/findings/`.
- A finding that hardens becomes an issue node.
- A finding that blocks warp is the cross to the schema loop. This
  seat does not edit `loom-warp`.
- The daydream does not write the tree. Talk comes back here.

## Success bar

Cycle one Check passes when a browser, on the HTTPS name, loads the
Godot export and shows a black screen, or whatever empty canvas the
engine draws. The export is running. A failed wasm load is not a
black screen.

## After

First-screen ruling can start. Self-render can start. Not before.
