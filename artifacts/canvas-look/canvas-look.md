# Canvas look

The visual brief for the canvas. Composition model is in
`artifacts/canvas-spec/canvas-spec.md`; read it first. This file is
only about what it looks like.

## Why the last one failed

`artifacts/monitor-plan/after-interface.png` is the shipped monitor.
The owner rejected it. The reasons are specific and none of them are
colour:

- Twenty sibling nodes on one horizontal row. Depth was in the
  sketch and the build flattened it.
- Labels rotated to forty-five degrees and colliding with each
  other. Rotated text is what a layout does when it has run out of
  room; it is a symptom, not a style.
- Two thirds of the canvas empty while the content is crushed into
  a band.
- The close-out placard — just did, next, waiting on, the thing the
  owner actually reads — shrunk into a bottom corner at the smallest
  size on screen.
- Nothing tells you where to look first.

The last three iterations tuned tokens against a layout that was
answering the wrong question. Do not tune. Redraw.

## Draw before you code

The owner's Check has to be a picture, and it has to arrive while
the change is still warm. The loop that has been running is six
hops long and one turn takes a day.

So: **mock the screen as an image before touching `weave/`.** SVG or
a still. Get the owner's word on the picture. Then build to the
approved picture. `artifacts/monitor-look/monitor-look.svg` was a
first attempt at this and the owner was not happy with it, so the
next one is drawn, not described.

When you do build, ship a 1440×900 capture with every change,
before any prose. `weave/capture.gd` already does this under Xvfb.
The owner replies to the picture. Prose is optional.

## The frame

Landscape only. Reading order is left to right, and the bands are
horizontal. A portrait viewport has nowhere to put the rails.

Three regions:

- **Left rails.** Three of them, stacked: personas, processes,
  tools. Rosters, not queues — pulling from one does not empty it.
- **The field.** The middle. Where the work is. Most of the screen.
- **Right ports.** Where things leave. One of the ports is
  discard. It must not look like a bin or a special case; it is a
  port among ports.

Plus two edges:

- **Timeline** along the bottom. A scale in hours, minutes, days.
  Zoomable, grabbable, and a period can be selected. This is the
  control that refills every shape on the field, so it is not
  decoration and it should not read as a footer.
- **Clock** in an upper corner. Transparent, not a panel. It shows
  where you are on the timeline, which is not always now.

## What the owner is trying to see

He said it plainly: he is trying to get what is in his head out of
his head and onto a surface. He runs a lot and loses his place, and
a visual cue that is always there keeps him in it.

So the first screen has to answer *where am I and what is the next
move* before it answers anything else. That is the close-out ritual
— just did, next, waiting on — and in the last build it was the
smallest thing on screen. It probably wants to be among the
largest, or to be the thing your eye lands on first.

Everything else on the screen is in service of that.

## Rules that hold

- Backdrop stays black.
- Gear stays bottom-right, subdued gray, opens the loadout.
- Cards stay off. `ThreadCard.gd` is not the monitor; do not put
  the paper cards back.
- Every colour, spacing step, font size, and control size is a
  token in `weave/theme/Tokens.gd`. Never
  `add_theme_color_override`, `add_theme_font_size_override`, or
  `add_theme_stylebox_override` for style. Add a token or a Theme
  type variation. Container `separation` and `margin_*` from tokens
  are layout and allowed.
- Godot does not propagate a Theme across a CanvasLayer. `Main`
  must keep handing `LoomTheme.shared()` to each Control child of
  `Interface`.
- The renderer reads. It does not write.
- No vendor names under `weave/`.
- The owner reviews from a tablet. Touch targets, not mouse
  targets.

## Depth

`artifacts/slot-spec/slot-spec.md` is the depth contract and it is
complete. Things occupy integer slots, zero at the viewer, negative
away, positive toward. Motion is between slots, never within one.
The canvas is layered, so this spec is now load-bearing rather than
theoretical. Draw to it.

## Questions the mock should answer

Each one a picture or a sentence.

1. What does the first screen look like when it is right? One
   image.
2. Where does "where am I" live — top border, centre, or placard?
3. One accent colour, and which one.
4. What does a tap do, and what does a drag do?
5. Are the rails always visible or summoned?
6. How does a thing entering from a rail read as *arriving* rather
   than *appearing*?

## Not your half

Rosters, the persona pipe, the shape store, process primitives, and
the timeline's read semantics are Grok's. If you need one of them
to draw, assume the simplest thing and note the assumption in
findings. Do not wait, and do not build the plumbing yourself.
