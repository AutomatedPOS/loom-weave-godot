# loom-weave-godot

First weave: Godot.

Run `./run.sh`. It clones `loom` into `_incoming/loom` if needed and opens the Godot window. Godot 4.3+ on `PATH` or at `$HOME/.local/bin/godot`.

Web: `./export.sh`. Push the weave with `./deploy-weave.sh` (needs
`CLOUDFLARE_API_TOKEN`). That updates worker `dord-dev` on
`loom.dord.dev` only. Do not `wrangler pages deploy`. Do not deploy
worker `dord` (apex / www).

The first weave is this window: a black backdrop, the monitor on
it, and one settings gear bottom-right. The monitor is a transit
map: spine on top, tree in the middle, placard bottom left.
Click to focus. Read only. The gear opens the loadout. Cards
stay off.

Every colour, size, and font size the interface uses is a token in
`weave/theme/Tokens.gd`. `weave/theme/LoomTheme.gd` builds the one
Theme from them. Do not style a node by hand; add a token or a type
variation. Smoke: `godot --headless --path . --import --quit`, then
`-s weave/first_screen_smoke.gd`, `-s weave/loadout_smoke.gd`,
`-s weave/theme_smoke.gd`, and `-s weave/monitor_smoke.gd`. Each
prints `SMOKE` and exits zero.

Tree: `thread.json` at the root, type `operation`. Operations do not
end; the render loop is continuous. A spec, once written, lands in
`artifacts/<name>/` beside its own `thread.json`, and the `workItem`
that produced it points across at the file. Validate with the four
checkers in `loom-warp`.

The render loop is PDCA. A spec is the plan step of a turn, not a
plan of its own. Cycle four Plan is the canvas: a surface the owner
composes on, with the model beside him. Plumbing is
`canvas-plumbing`. Painting is the other half and is not this
seat. A saved shape is a query, not a snapshot. `scripts/canvas_model.py`
holds the contract; `python3 scripts/test_canvas_model.py` fails if
a shape carries tree data. Nothing on the canvas writes to the tree.

Cycle three Do is `loadout`. Chat, speech, and hear are set after
deploy, not in the base. Save stays on that browser. Export writes a
file; import brings it back after a wipe. No vendor. The Do includes
commit and push. Check waits until the commit is on the remote. The
owner reviews from a tablet.

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
