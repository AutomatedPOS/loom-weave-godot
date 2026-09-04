# Interface handoff — Cloud Code / Claude Code

Repo: `AutomatedPOS/loom-weave-godot`. Godot 4.3, GDScript. Live
weave is worker `dord-dev` at `https://loom.dord.dev/`. Owner
checks from a tablet. This zip is the whole tree as of the Grok
sitting that put a first visible monitor on the window and then
was barred from the interface.

Read this file before touching anything. Then read
`artifacts/interface-handoff/walk-packet-2026-09-04-monitor.md`
(the dream) and look at
`artifacts/monitor-plan/first-visible.png` (what shipped; owner
called it ugly as sin).

Two jobs. In this order:

1. **Paste a credential on the live web loadout.** Cycle three.
   That was the intent of the iteration. It does not work. This
   is the blocker.
2. **Restyle the monitor** to the walk packet. Grok is not
   allowed to touch the interface. You are.

When you are done, push a branch and stop. Seth turns it back
to Grok. Grok deploys. Do not merge to `master`.

---

## 1. Standing rules

- Never commit to `master`. Grok is the sole writer to `master`.
  Branch, PR to Seth, no auto-merge.
- Interface files only: `weave/` scripts and scene, `weave/theme/`,
  the smoke tests, and dated beats under `artifacts/findings/`.
  No worker, export pipeline, deploy, DNS, or host-map changes.
  Do not run `wrangler pages deploy`. Do not deploy worker `dord`.
- Grok will not edit `weave/` again this turn. If you need a
  data or tree change outside `weave/`, write it in findings and
  leave it. Do not wait.
- No vendor names under `weave/`. `loadout_smoke.gd` greps for
  OpenAI and Anthropic and fails the build.
- No secrets in the repo, the export, or the worker. Never log
  a credential. Never print a key into a findings file.
- Backdrop stays black. Gear stays bottom-right, subdued gray,
  opens the loadout. Cards stay off. `ThreadCard.gd` is not the
  monitor; do not put the paper cards back.
- Every colour, spacing step, font size, and control size lives
  in `weave/theme/Tokens.gd`. Never
  `add_theme_color_override`, `add_theme_font_size_override`, or
  `add_theme_stylebox_override` for style. Add a token or a Theme
  type variation. Container `separation` and `margin_*` from
  tokens are layout and allowed.
- Godot does not propagate a Theme across a CanvasLayer. `Main`
  must keep handing `LoomTheme.shared()` to each Control child
  of `Interface`.
- The renderer **reads**. It does not write. No branch-from-node.
- No timers. Refresh mechanism is unpicked (hook vs Worker).
  Do not add polling.
- Do includes commit and push. Unpushed work is invisible.
- Findings: short dated beats in
  `artifacts/findings/2026-09-04-interface-handoff.md` (create
  it) and, for paste, also a beat on
  `artifacts/findings/2026-09-04-cycle-three.md`.

---

## 2. Where the PDCA boxes are

| Piece | Box | Notes |
|---|---|---|
| loadout (cycle 3) | CHECK, blocked | Gear, save, import picker exist. Owner cannot paste an API key on the live weave. That was the point of the cycle. |
| gear-panel | CHECK | Tokens and Theme stand. Not the chew. |
| monitor | DO | Data and a first visible exist. Look is a debug dump. Owner rejected the look. You restyle. |
| Act | not yet | After owner has seen paste work and the monitor is not a list of buttons. |

No duration / iteration number is on the nodes. loom-warp left
that OPEN. Do not invent a field. Path down the tree is the
position.

---

## 3. Job 1 — paste a credential (do this first)

Owner, live `loom.dord.dev`, loadout open: cannot copy-paste
API keys into the credential fields. Tablet and/or browser.
The panel copy already says `defaults are pointed. paste a
credential.` One pasted key is supposed to fill the other
empty credential fields on Save (`LoadoutPanel._share_one_credential`).
None of that matters if the field never receives the paste.

### What is already there

- `weave/LoadoutSection.gd` builds a `LineEdit` per field.
  `credential` has `secret = true`.
- No paste handler. No `JavaScriptBridge` clipboard path.
- Import of a `loadout.json` file works on web (hidden
  `<input type=file>`). That is not a substitute for paste.
- `DisplayServer.clipboard_get()` is empty on the Godot 4.3
  web export. Do not use it as the web path.
- Godot's HTML5 `LineEdit` does not take the browser's paste
  event. Ctrl/Cmd+V and mobile long-press paste die in the
  wasm canvas. This is the expected cause. Confirm, then fix.
- COOP/COEP are already on the worker (`same-origin` /
  `require-corp`). `navigator.clipboard.readText()` still
  works from a user gesture in Chrome. Safari may need the
  `paste` event on `window` / `document` instead of the async
  clipboard API. Handle both.

### What to build

A web paste path that puts clipboard text into the focused
`LineEdit`, including secret credential fields.

Required, all of them:

1. Browser `paste` event (Ctrl/Cmd+V and OS paste) inserts
   into the focused field.
2. A control a tablet can tap without a keyboard — label it
   `Paste`, sit it with Save / Export / Import above the fold —
   that reads the clipboard on that tap and writes the focused
   field, or the first empty credential if nothing is focused.
3. Secret fields accept the paste. Do not turn `secret` off
   as the fix. If a platform blocks paste on secret LineEdits,
   set the text from GDScript after reading JS clipboard.
4. One pasted key still copies into the other empty
   credential fields on Save. Already written. Keep it.
5. Status line says `pasted` (or `pasted. Save to keep it on
   this browser.`) and never echoes the key.
6. Desktop / non-web: keep native paste if it already works;
   do not break it.

### Acceptance

- Headless smokes still print `SMOKE` and exit 0.
- Local web export: Chrome, focus chat credential, paste
  `dummy-key-not-secret`, field accepts it (masked), Save,
  hard refresh, value still there. Repeat with the Paste
  button and no keyboard.
- Safari, same, or a findings beat that names what Safari
  refused and what you did.
- Owner tablet Check: hard refresh `loom.dord.dev`, gear,
  paste a real key, Save, refresh, it is still there. Grok
  deploys after you hand back. You verify on a local serve
  of `build/web/` with COOP/COEP. Do not deploy.

Write the cycle-three findings beat when paste works locally.

Issue node already in the tree: `issues/credential-paste/`.
Leave it `open` until the owner Check. Do not close it.

---

## 4. Job 2 — restyle the monitor

Grok shipped a first visible so the owner could see *where*
he is. It is a vertical button list, a raw PDCA shout, and
an inspector pane. That is not the walk.

### What must stay

- Read-only. Click focuses. Nothing writes a `thread.json`.
- Backdrop black. Gear and loadout still work on top.
- `TreeLoader` walks `res://`, skips `data`, `build`,
  `_incoming`, `trees`. `path_of` is the spine data.
- Open workItems may carry `props: [{name: pdca, value: ...}]`.
  Values in use: loadout `check`, gear-panel `check`,
  monitor `do`. Show those four words. Do not invent a
  schema field for them.
- Public methods `focused_name()`, `pdca_line()`,
  `detail_text()`, `focus_guid(guid)` — `monitor_smoke.gd`
  uses them. Keep the names or update the smoke in the
  same commit.
- `first_screen_smoke.gd` now requires `Interface/Monitor`
  present, panel hidden, gear present, backdrop black.

### What the walk decided (do this)

From `walk-packet-2026-09-04-monitor.md`:

- **Top border: the path spine.** Galaxy → repo → operation
  → iteration. Header, not a pile. Always visible. How you
  get back out. Today there is no galaxy node and no
  iteration counter. Spine starts at this operation and
  walks to the focused node. Do not fake a galaxy.
- **Middle: the repo's own tree.** Two structures on one
  screen. Left-to-right chain, modernized. Each step blooms
  into its own chain underneath — the substations.
- **Deviation:** planned path is a ghost line that keeps
  going; actual forks off. The fork is the thing being
  looked for. Data you have: `plannedStart` / `plannedEnd`,
  `actualStart` / `actualEnd`, states `abandoned` /
  `superseded` as ghost, `open` / `active` / `done` as
  lived. No new field.
- Click a past node: what was done, what was decided, do
  you need more detail. `justDid`, `next`, `waitingOn`,
  `body`, `chose` / `consequences` on decisions. Session
  hangs off the node in the tree. No extra pointer.
- Purpose: trunk stays on screen so breadth never
  disappears. Collapse what you are not in.

PDCA belongs on the spine or on the live node, not as a
second dump of every filename.

### What not to do this pass

- Refresh hook vs Worker. Unpicked.
- Memory-budget checker. Path unnamed.
- RAG.
- Iteration counter field.
- Writing / branching from a node.
- Apollo hook, host map, loom-warp schema.
- Promoting into `loom-weave`.

### Acceptance

- Window is a monitor, not a log. Spine readable at a
  glance. Live path vs ghost path visible. Clicking a done
  node shows close-out without losing the trunk.
- Gear still opens the loadout. Paste from job 1 still
  works.
- All four smokes: `first_screen_smoke`, `loadout_smoke`,
  `theme_smoke`, `monitor_smoke`. Each prints `SMOKE` and
  exits 0.
- `grep -rn -E 'Color\(|font_size' weave --include='*.gd'
  --include='*.tscn'` returns only `weave/theme/`, the
  smokes, and `ThreadCard.gd`.
- Capture a 1440×900 after image under Xvfb + opengl3
  with `weave/capture.gd`. Put it in
  `artifacts/monitor-plan/after-interface.png`.
- PR open. Not merged by you.

---

## 5. File map as of this zip

| Path | Role |
|---|---|
| `weave/Monitor.gd` | First visible. Replace the look. Keep the read. |
| `weave/Main.tscn` | Backdrop, Interface: Monitor, Gear, Panel. Monitor is under the gear so the gear draws on top. |
| `weave/Main.gd` | Theme on each Interface Control. Gear → panel.toggle. |
| `weave/TreeLoader.gd` | Folder walk, parent map, `path_of`, `depth_of`. |
| `weave/ThreadCard.gd` | Dead. Do not resurrect. |
| `weave/LoadoutPanel.gd` | Loadout. Web import lives here. Paste belongs here. |
| `weave/LoadoutSection.gd` | One cap, three fields. Credential is secret. |
| `weave/Loadout.gd` | Model. `user://loadout.json`. No vendor. |
| `weave/theme/Tokens.gd` | The only place a value lives. `V_ROW` / `V_ROW_DIM` were added for the dump. You may replace them. |
| `weave/theme/LoomTheme.gd` | Builds the Theme. CanvasLayer note still stands. |
| `weave/monitor_smoke.gd` | Spine + PDCA + tree + focus. |
| `scripts/where.py` | Text spine. Leave it. Not the interface. |
| `artifacts/monitor-plan/` | Plan, first-visible PNG, artifact thread. |
| `monitor/thread.json` | workItem, `pdca=do`, still open. |
| `loadout/thread.json` | workItem, `pdca=check`, waiting on tablet. Paste is why Check is not closed. |
| `issues/credential-paste/` | The cycle-three hole. |

Run from repo root, Godot 4.3 on PATH or
`$HOME/.local/bin/godot`:

```
godot --headless --path . --import --quit
godot --headless --path . -s weave/first_screen_smoke.gd
godot --headless --path . -s weave/loadout_smoke.gd
godot --headless --path . -s weave/theme_smoke.gd
godot --headless --path . -s weave/monitor_smoke.gd
```

Local web (do not deploy):

```
./export.sh
# serve build/web with COOP same-origin and COEP require-corp
```

---

## 6. Facts learned the hard way

- Theme does not cross a CanvasLayer.
- Smoke tests that instantiate in `_init` must
  `call_deferred` and `await process_frame`.
- `Control` + `_gui_input` did not receive taps on the gear.
  The gear is a `Button`. Main `mouse_filter` is ignore.
- Godot web `instantiateStreaming` hangs if wasm is gzipped
  twice. `workers/serve.mjs` serves `/index.wasm` as gzip
  once. Do not touch that file.
- Native file dialog does not exist on the web display
  server. Import already goes through a browser `<input>`.
  Paste needs the same class of bridge, for clipboard.

---

## 7. Hand back

Push the branch. Comment what you changed for paste (which
browsers) and for the monitor (after PNG). Stop.

Seth gives the branch to Grok. Grok reviews without restyling,
deploys `dord-dev` only, and the owner hard-refreshes
`loom.dord.dev`. That is Check for both jobs.

Do not close `loadout`, `monitor`, or `credential-paste`.
Do not pick the refresh mechanism. Do not flatten the owner.
