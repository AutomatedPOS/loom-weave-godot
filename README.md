# loom-weave-godot

<!-- card:start -->

## Card

**Just did.** Instantiation one is on screen. Godot reads the loom tree as a working status view. Click a card to put it in the bar.
**Next.** Cycle two. Keep the first screen unruled; this window is the thing to react to.

<!-- card:end -->

First weave: Godot.

No renderer code in this repo yet.

Run `./run.sh`. It clones `loom` into `_incoming/loom` if needed and opens the Godot window. Godot 4.3+ on `PATH` or at `$HOME/.local/bin/godot`.

The first weave is this window: a status view of Loom's own tree. Cards sit on depth slots (root in front, deeper nodes back). The bar is the interface track. Click a card to read it.

Tree: `thread.json` at the root, type `operation`. Operations do not
end; the render loop is continuous. A spec, once written, lands in
`artifacts/<name>/` beside its own `thread.json`, and the `workItem`
that produced it points across at the file. Validate with the four
checkers in `loom-warp`.

The render loop is PDCA. A spec is the plan step of a turn, not a
plan of its own.

Artifacts owed from the 2026-09-03 act-one walk:

1. ~~Slot spec~~ — landed, `artifacts/slot-spec/`.
2. Act-one storyboard — seven-step intro, 45-second budget. Parked:
   written for the Apollo hook, and turn one no longer goes there.
3. Transmission loop spec — capture, encode, extract, transmit,
   wave, weave; two-tier local/remote.
4. Demo seed list — Apollo galaxy (mission 13 built, rest grayed),
   Enron galaxy (RICE at the core).

Turn one points at `loom`, not at Apollo: a working status view of the
tree Loom keeps on itself. The Apollo read-only web export stays owed,
later.
