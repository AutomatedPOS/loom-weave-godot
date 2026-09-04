# Interface hand-back — Claude Code to Grok

Repo: `AutomatedPOS/loom-weave-godot`. Branch
`claude/site-interface-design-8hc1nt`, open as PR #13 against
`master`. Not merged by this seat. Date: 2026-09-04. Answers
`HANDOFF.md` beside this file. Both jobs done. Read this, deploy
`dord-dev`, hand the owner the Check.

Four parts:

1. What changed, by file.
2. What is verified, and how.
3. What Grok does now.
4. What stays open, and what is Grok's to write outside `weave/`.

---

## 1. What changed

Four commits on the branch, in order.

| Commit | What |
|---|---|
| `83b13f7` | `artifacts/monitor-look/`: the look packet and a sketch, written before the handoff arrived. No `thread.json`. |
| `39572b1` | The handoff zip's tree, as one commit, before any change. All four smokes passed on it. |
| `605a930` | Paste. |
| `3d1c13d` | Monitor. |

### Interface files

| Path | Change |
|---|---|
| `weave/LoadoutPanel.gd` | Web paste bridge, `Paste` button, `paste_text()` as the one landing, built-in paste action dropped on web only. |
| `weave/Monitor.gd` | Rewritten. One Control, `_draw()` from `TreeLoader`. Spine, PDCA words, transit-map tree, placard, click to focus. No buttons. |
| `weave/theme/Tokens.gd` | `ACCENT`, `GHOST` (published on the `Loom` type as `accent`, `ghost`). Monitor sizes: `LINE_W`, `GHOST_W`, `EDGE_W`, `STATION_R`, `INTERCHANGE_R`, `DASH`, `SPINE_H`, `SPINE_STEP`, `ROW_H`, `COL_W`, `BUS_UP`, `SIGN_ANGLE`, `PLACARD_W`. `BUTTON_MIN_W` 88 → 72. `V_ROW`, `V_ROW_DIM` removed. |
| `weave/theme/LoomTheme.gd` | `_row_type` and its two variations removed. Nothing else. |
| `weave/loadout_smoke.gd` | Paste routing, status, no echo, share on Save, Paste button present. |
| `weave/monitor_smoke.gd` | Spine, PDCA, no buttons, no hand styling, trunk only, branch opens on focus, click hit, no write. |
| `weave/theme_smoke.gd` | Row variations dropped from the list. `accent` and `ghost` are covered by the `COLORS` loop. |

Untouched: `Main.gd`, `Main.tscn`, `SettingsGear.gd`,
`LoadoutSection.gd`, `Loadout.gd`, `TreeLoader.gd`, `capture.gd`,
`ThreadCard.gd`, `first_screen_smoke.gd`, `smoke.gd`. No worker,
export pipeline, deploy, DNS, or host file.

### Packet files

| Path | Change |
|---|---|
| `artifacts/monitor-plan/after-interface.png` | 1440×900, Xvfb + opengl3, `capture.gd`. First screen. |
| `artifacts/monitor-plan/after-interface-focus.png` | Same, with `specs-slot` focused: branch open, trunk on screen. |
| `artifacts/gear-panel-plan/tokens.svg` | `BUTTON_MIN_W` label 88 → 72. |
| `artifacts/findings/2026-09-04-cycle-three.md` | One beat: paste works on the local web build. |
| `artifacts/findings/2026-09-04-interface-handoff.md` | Two beats: handoff taken, monitor restyled. |
| `artifacts/monitor-look/monitor-look.md` | One beat: landed, and what differs from the packet. |

---

## 2. Verified

Godot 4.3 headless, from the repo root:

```
godot --headless --path . --import --quit
godot --headless --path . -s weave/first_screen_smoke.gd
godot --headless --path . -s weave/loadout_smoke.gd
godot --headless --path . -s weave/theme_smoke.gd
godot --headless --path . -s weave/monitor_smoke.gd
```

All four print `SMOKE` and exit 0.

```
grep -rn -E 'Color\(|font_size' weave --include='*.gd' --include='*.tscn'
```

returns only `weave/theme/`, the smokes, and `ThreadCard.gd`.

Web: `./export.sh`, then `build/web` served locally with
`Cross-Origin-Opener-Policy: same-origin` and
`Cross-Origin-Embedder-Policy: require-corp`, driven by Playwright
in Chromium 1194 at 1440×900. Values read back through Export.

| Case | Result |
|---|---|
| Ctrl+V into chat credential | field takes it, masked, status `pasted. Save to keep it on this browser.` |
| second Ctrl+V, different text, same field | appended once; no stale double paste |
| Paste button with speech model focused, caret at end | inserted at the caret |
| Paste button, nothing focused | first empty credential |
| Save, hard reload | key still there, shared to speech and hear |
| touch tap on Paste, no keyboard | first empty credential |
| click the SPECS station | spine grows a station, branch opens, fork and focus rings stack |
| gear after the restyle | loadout opens over the monitor |

**Safari was not run.** Not on this seat. The clipboard read happens
inside the browser's own keydown or pointerup, which is the shape
Safari requires. A refusal shows in the status line as
`paste blocked by the browser. tap Paste again, or long-press a
field.` The owner's tablet is the Safari test.

---

## 3. Grok does now

1. Review the branch. Do not restyle.
2. Merge PR #13 to `master`, or Seth does. Not this seat.
3. `./export.sh`, then `./deploy-weave.sh`. Worker `dord-dev` only.
   Apex left alone.
4. Hand the owner the Check, one hard refresh on `loom.dord.dev`:
   - Black backdrop. Monitor on it. Gear bottom right.
   - Spine reads `01 LOOM-WEAVE-GODOT` then `02 MONITOR` with the
     orange ring. Right end reads `GEAR-PANEL · CHECK`,
     `LOADOUT · CHECK`, `MONITOR · DO`.
   - Tap `SPECS`, far right of the row. Spine grows a station. The
     row under it opens: `SPECS-SLOT` solid, three dashed ghosts.
     The trunk is still there.
   - Tap the gear. Loadout opens. Copy a key elsewhere, come back,
     tap `Paste`. Chat credential fills, masked. Status says
     `pasted`. Save. Hard refresh. Gear. Still there, and speech and
     hear carry it too.
   - If Safari refuses the read, the status says so. Then: tap a
     credential field, long-press, choose Paste from the callout,
     and report which of the two worked.
5. After the Check, the tree moves are Grok's. See section 4.

---

## 4. Open, and Grok's to write

### Tree, outside `weave/`

- `loadout/thread.json` — `pdca` stays `check` until the owner
  pastes a real key on the live weave. Then Act.
- `monitor/thread.json` — `pdca` stays `do` until the owner has seen
  it. `next` still describes the first visible; rewrite it to the
  Check above.
- `issues/credential-paste/thread.json` — stays open until the
  tablet paste works. Then done.
- `gear-panel/thread.json` — unchanged. Its tablet Check is folded
  into the same refresh.
- `artifacts/monitor-look/` — no `thread.json` on purpose. Seth
  names the landing path. Candidates in the packet's section 8.
- `README.md` — still describes the first visible. Not an interface
  file. One paragraph: the monitor is a transit map, spine on top,
  tree in the middle, placard bottom left, click to focus, read only.
  Add `monitor_smoke` is already listed.

### Left for a later pass, each its own plan

- Pan and zoom the field. A row wider than the window closes up
  today; it does not scroll.
- Ghost on or off. Depth right.
- A font. `TEXT_*` sizes stay; a `FONT` token and the Theme's
  `default_font` would tighten the chamber signs.
- Refresh: post-commit hook or Worker. Unpicked. The monitor
  redraws from `TreeLoader` and does not care which.
- Memory checker. Unnamed.
- Iteration counter. OPEN in loom-warp. Within one day the trail's
  order is file order, not history. The field shows that gap.
- Planned dates. No node carries `plannedStart` or `plannedEnd`
  yet. The ghost today is "no date anywhere under it." When a plan
  is dated, the ghost reading can sharpen without a code change to
  the rule's shape.
- `ThreadCard.gd`. Still dead. Still Seth's call.

### One thing noticed

`weave/loadout_defaults.json` prefills a vendor's endpoints and
model names. The vendor grep in `loadout_smoke.gd` covers the
scripts, not that file. Left as prefilled. Grok's rule to keep or
change.

---

## 5. Facts learned this sitting

- Godot's web key listener calls `preventDefault()` on every
  keydown. That cancels the browser's paste, so no `paste` event
  fires for Ctrl/Cmd+V. Godot's own `paste` listener never sees it
  either; the "works on the second try" behaviour was the async
  clipboard read filling a cache one press late.
- A Godot `Button` takes focus on click. A button that acts on the
  focused field needs `focus_mode = FOCUS_NONE`.
- A wrapped `Label` in a free-floating `PanelContainer` reports its
  height for whatever width it had last frame. Size the panel, then
  size it again one frame on.
- A `call_deferred` that re-arms itself floods the message queue and
  crashes the process. One deferred pass, no flag.
- `draw_dashed_line` and `draw_arc` cover every line on the monitor.
  No `Line2D`, no per-node Controls.
