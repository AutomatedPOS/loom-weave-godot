# loom-weave-godot

First weave: Godot.

Run `./run.sh`. It clones `loom` into `_incoming/loom` if needed and opens the Godot window. Godot 4.3+ on `PATH` or at `$HOME/.local/bin/godot`.

Web: `./export.sh`. Push the weave with `./deploy-weave.sh` (needs
`CLOUDFLARE_API_TOKEN`). That updates worker `dord-dev` on
`loom.dord.dev` only. Do not `wrangler pages deploy`. Do not deploy
worker `dord` (apex / www).

The first weave is this window: a black screen. The interface track
holds one settings gear, bottom-right, subdued gray. Cards are off.

Tree: `thread.json` at the root, type `operation`. Operations do not
end; the render loop is continuous. A spec, once written, lands in
`artifacts/<name>/` beside its own `thread.json`, and the `workItem`
that produced it points across at the file. Validate with the four
checkers in `loom-warp`.

The render loop is PDCA. A spec is the plan step of a turn, not a
plan of its own. Cycle two Plan is `plans/cycle-two`. The Do is
`first-screen`: black backdrop, no card forms, settings gear on the
interface track. The Do includes commit and push. Check waits until
the commit is on the remote. The owner reviews from a tablet.

Artifacts owed from the 2026-09-03 act-one walk:

1. ~~Slot spec~~ — landed, `artifacts/slot-spec/`.
2. Act-one storyboard — seven-step intro, 45-second budget. Parked:
   written for the Apollo hook, and turn one no longer goes there.
3. Transmission loop spec — capture, encode, extract, transmit,
   wave, weave; two-tier local/remote.
4. Demo seed list — Apollo galaxy (mission 13 built, rest grayed),
   Enron galaxy (RICE at the core).

Turn one put a status view of Loom's own tree on screen. Cycle two
took the cards off. The Apollo read-only web export stays owed, later.
