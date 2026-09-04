# Gear panel pass — handoff for Cursor

Repo: `AutomatedPOS/loom-weave-godot`. Godot 4.3, GDScript, web export
served by a Cloudflare worker at `loom.dord.dev`.

Read this whole file before touching anything. It has four parts:

1. Standing rules. Never break these.
2. Current state. What is already done and where.
3. Work to do, in order, with acceptance checks.
4. Full specification, in case you have to rebuild from scratch.

---

## 1. Standing rules

- Never commit to `master`. Grok is the sole writer to `master`.
  Work on a branch and open a PR to Seth. No auto-merge.
- Interface files only. `weave/` scripts and scene, `weave/theme/`,
  the smoke tests, and the packet under `artifacts/`. No worker,
  export, deploy, or host changes.
- No vendor names anywhere under `weave/`. `loadout_smoke.gd` greps
  for OpenAI and Anthropic and fails the build if it finds them.
- No secrets in the repo, the export, or the worker.
- The first screen stays black with one gear bottom-right, subdued
  gray. Cards stay off.
- Every colour, spacing step, font size, and control size lives in
  `weave/theme/Tokens.gd` and nowhere else. Never call
  `add_theme_color_override`, `add_theme_font_size_override`, or
  `add_theme_stylebox_override` for style. Add a token or a Theme
  type variation instead. Container `separation` and `margin_*`
  constants are layout and may be set from tokens.
- The Do of a turn includes commit and push. Unpushed work is
  invisible to the owner, who checks from a tablet.
- Record what you did as dated beats in
  `artifacts/findings/2026-09-04-gear-panel.md`. Short paragraphs,
  one per event, headed `### YYYY-MM-DD — title`.

---

## 2. Current state

Branch `claude/interface-files-organization-5hfvis`, open as PR #10
against `master`. Everything in section 4 below is implemented on
that branch and passes the smoke tests on Godot 4.3 headless.

File map on the branch:

| Path | Role |
|---|---|
| `weave/theme/Tokens.gd` | `class_name LoomTokens`. Every design value. Constants only, plus `panel_bottom_inset()`. |
| `weave/theme/LoomTheme.gd` | `class_name LoomTheme`. `build()` makes a Theme from the tokens. `shared()` caches one. Helper `well_box(pad_x)`. |
| `weave/Main.gd` | Hands `LoomTheme.shared()` to each Control directly under the `Interface` CanvasLayer. Sets backdrop colour from the token. Wires gear to panel. |
| `weave/Main.tscn` | `Main` Control, `Backdrop` ColorRect, `Interface` CanvasLayer at layer 64, `Gear` Button, `Panel` PanelContainer hidden. Gear and Panel carry only type and script. |
| `weave/SettingsGear.gd` | Self-drawn cog. Reads `ink`, `ink_hover`, `backdrop` from the Theme type `Loom`. Sizes itself from tokens in `_place()`. |
| `weave/LoadoutSection.gd` | `class_name LoadoutSection extends VBoxContainer`. One capability block. `setup(cap)`, `edit(field)`, `read()`, `write(block)`. |
| `weave/LoadoutPanel.gd` | `extends PanelContainer`. Builds MarginContainer, ScrollContainer, VBox, title, subtitle, Save Export Import row, status, one section per `Loadout.CAPS`. `field_edit(cap, field)` public. `_place()` anchors above the gear, clamps height to the viewport. |
| `weave/Loadout.gd` | Model. `CAPS`, `FIELDS`, `SECRET_FIELDS`, `is_secret()`, `endpoints_without_scheme()`, save and load against `user://loadout.json`. |
| `weave/first_screen_smoke.gd` | Black backdrop, gear present, panel hidden. Scene checks deferred one frame. |
| `weave/loadout_smoke.gd` | Model round trip, panel shows saved value through `field_edit`, vendor grep. Scene checks deferred one frame. |
| `weave/theme_smoke.gd` | Tokens round-trip through the Theme; Interface children carry the shared Theme; no node under the panel has a style override; panel inside viewport; unsaved edit survives toggle. |
| `artifacts/gear-panel-plan/` | `gear-panel-plan.md`, `tokens.svg`, before and after PNGs, `thread.json`. |
| `plans/gear-panel/thread.json`, `gear-panel/thread.json` | Tree records for the plan and the workItem. WorkItem state is `open` until the tablet Check passes. |

Run the tests like this, from the repo root, with Godot 4.3 on PATH
or at `$HOME/.local/bin/godot`:

```
godot --headless --path . --import --quit
godot --headless --path . -s weave/first_screen_smoke.gd
godot --headless --path . -s weave/loadout_smoke.gd
godot --headless --path . -s weave/theme_smoke.gd
```

Each prints a line starting `SMOKE` and exits zero.

Two facts learned the hard way, so you do not relearn them:

- Godot does not propagate a Theme across a CanvasLayer. Setting
  `theme` on the Window or on `Main` does not reach `Interface/Gear`
  or `Interface/Panel`. That is why `Main._ready` loops over the
  CanvasLayer's Control children and sets `theme` on each.
- A node added to `root` inside `SceneTree._init` has not had
  `_enter_tree` or `_ready` run yet. Smoke tests that look at the
  scene must `call_deferred` and `await process_frame` first.

---

## 3. Work to do, in order

Do these on the PR #10 branch unless Seth says to start a new one.
If you start a new one, name it `interface/gear-panel-cleanup` and
cherry-pick the commit from PR #10 onto it first.

### 3.1 Verify the branch locally

1. `git fetch origin claude/interface-files-organization-5hfvis` and
   check it out.
2. Run the four commands above. All three smoke lines must appear.
3. Run `./run.sh` and open the window. Click the gear. Confirm:
   black screen, gray gear bottom-right, panel opens above the gear,
   three sections of three fields, Save Export Import above the fold,
   Escape closes, reopening keeps typed text.
4. Type `abc` in chat endpoint, press Save. Status must read
   `saved on this browser. chat endpoint has no http:// or https://`.
   Fix the endpoint to `https://example.invalid/v1`, Save again,
   status must read `saved on this browser`.

Acceptance: all four steps behave as described. Write one findings
beat.

### 3.2 Verify Import on the web build

This is the one thing not verified. The web display server has no
native file dialog, so the branch uses a browser file input through
`JavaScriptBridge`. The code is in `LoadoutPanel.gd` under the
comment `web import`.

1. Install the Godot 4.3 web export templates if missing.
2. Run `./export.sh`. It clones `loom` into `_incoming/loom` if
   needed and writes `build/web/`.
3. Serve `build/web/` locally with the two headers the game needs:
   `Cross-Origin-Opener-Policy: same-origin` and
   `Cross-Origin-Embedder-Policy: require-corp`. Any static server
   that lets you set headers is fine. Do not deploy.
4. Open it in Chrome and in Safari. Click the gear, then Import. A
   file picker must open. Pick a `loadout.json` written by Export.
   Fields must fill and the status must read
   `imported. Save to keep it on this browser.`
5. If the picker does not open, the likely cause is the browser
   refusing `input.click()` outside a user gesture. Check the
   console. Fallbacks, in order of preference:
   a. Call `_web_input.click()` synchronously inside the button's
      `pressed` handler with no `await` before it. It already is;
      confirm nothing deferred crept in.
   b. Use `JavaScriptBridge.eval` to attach a `pointerdown` listener
      on the canvas that opens the picker while a flag set from
      GDScript is true. Set the flag in `_on_import`, clear it in
      the change handler.
   c. As a last resort, show the file input visibly over the canvas
      for one tap.
6. If the picker opens but fields do not fill, log
   `_web_reader.result` and check `_import_text` receives a string.

Acceptance: Import works in both browsers on the local build. Write
a findings beat saying which browsers, and what if anything you
changed. Push.

### 3.3 Fix `capture.gd`

`weave/capture.gd` calls `img.flip_y()` on the viewport image. Under
Xvfb with the OpenGL renderer the image is already upright, so the
saved PNG is upside down. Make the flip conditional. Simplest robust
check: after `get_image()`, sample the pixel at the gear's centre
(bottom-right, `INSET + GEAR_SIZE / 2` in from each edge). If it is
not near `LoomTokens.INK`, flip and sample again. Read the offsets
from `LoomTokens`, do not hardcode them.

Acceptance: `godot --path . -s weave/capture.gd` under a display
writes `user://first-screen.png` with the gear at bottom-right on
whatever renderer you have. Push.

### 3.4 Decide the dead files

`weave/ThreadCard.gd` is referenced by nothing. `weave/TreeLoader.gd`
is used only by `weave/smoke.gd`. Both carry their own palettes and
are off the interface track. Ask Seth: delete `ThreadCard.gd`, or
keep it for the parked card view. Do not delete without an answer.
If told to delete, remove it and add a findings beat. Do not touch
`TreeLoader.gd` either way.

### 3.5 Hand off for deploy and Check

Deploy is not yours. `./deploy-weave.sh` needs a Cloudflare token
the owner holds, and updates worker `dord-dev` only. Never run
`wrangler pages deploy`. Never deploy worker `dord`.

When 3.1 through 3.3 are pushed, comment on PR #10 with the smoke
output, the browsers Import passed in, and a link to the after
captures. The owner's tablet Check is: hard refresh on
`loom.dord.dev`, black screen, gear, panel opens, a saved endpoint
survives the refresh, Import opens a picker.

After the Check passes and the PR merges, a later turn sets
`gear-panel/thread.json` state to `done` with an `actualEnd`. Do not
do that before the Check.

### 3.6 Candidates for the pass after this one

Each is its own plan. Do not start them in this PR.

- A font resource. Add `FONT` to tokens, set `default_font` on the
  Theme. Sizes stay as they are.
- A light palette. Second colour set in tokens, a `variant`
  argument to `LoomTheme.build()`, a token to pick which.
- Corner radius. `RADIUS` is already a token at 0.
- A fourth capability. Add it to `Loadout.CAPS`. Nothing else
  should need to change; if something does, that is a bug in this
  pass.

---

## 4. Full specification

Use this if you are told to rebuild from `master` on a fresh branch
instead of continuing PR #10. It describes the end state; the branch
is a working reference implementation of it.

### 4.1 Tokens

`weave/theme/Tokens.gd`, `class_name LoomTokens extends RefCounted`.

Colours, Godot `Color(r, g, b, a)` floats:

| Name | Value | Use |
|---|---|---|
| BACKDROP | 0, 0, 0, 1 | window ground, gear hub |
| INK | 0.68, 0.68, 0.70, 1 | text, gear, focused borders |
| INK_HOVER | 0.78, 0.78, 0.80, 1 | gear on hover |
| DIM | 0.42, 0.42, 0.44, 1 | subtitle, status, placeholders |
| SURFACE | 0.04, 0.04, 0.045, 0.96 | panel fill |
| WELL | 0.10, 0.10, 0.11, 1 | field and button fill |
| EDGE | 0.22, 0.22, 0.24, 1 | borders, selection |

Publish those seven on the Theme under type `Loom` with the
lower-case names `backdrop`, `ink`, `ink_hover`, `dim`, `surface`,
`well`, `edge`. Keep a `COLORS` dictionary mapping name to value so
the builder and the test iterate the same list.

Spacing: SPACE_1 4, SPACE_2 8, SPACE_3 12, SPACE_4 16, SPACE_5 24.
Type: TEXT_SM 12, TEXT_MD 14, TEXT_LG 18. No font family.
Sizes: BORDER 1, RADIUS 0, CONTROL_H 36, BUTTON_MIN_W 88,
GEAR_SIZE 32, INSET 16, PANEL_W 384, PANEL_H_MAX 760.
Variations: V_TITLE `TitleLabel`, V_MUTED `MutedLabel`,
V_GEAR `GearButton`.
Helper: `panel_bottom_inset()` returns INSET + GEAR_SIZE + SPACE_3.

### 4.2 Theme

`weave/theme/LoomTheme.gd`, `class_name LoomTheme`. Static
`build() -> Theme` and static `shared() -> Theme` that caches.

- `default_font_size` TEXT_MD.
- Type `Loom`: the seven colours.
- `Label`: font_color INK, font_size TEXT_MD. Variation
  `TitleLabel` font_size TEXT_LG. Variation `MutedLabel` font_color
  DIM, font_size TEXT_SM.
- `LineEdit`: `normal` and `read_only` are a well box with SPACE_2
  side padding; `focus` is the same with border INK. font_color INK,
  font_placeholder_color DIM, caret_color INK, font_selected_color
  INK, selection_color EDGE, font_size TEXT_MD.
- `Button`: `normal` and `disabled` are a well box with SPACE_3 side
  padding; `hover` and `pressed` are the same with border INK;
  `focus` empty. All font colour states INK, disabled DIM, font_size
  TEXT_MD. Variation `GearButton`: every stylebox state empty.
- `PanelContainer` `panel`: bg SURFACE, border EDGE at BORDER,
  radius RADIUS.
- `ScrollContainer` `panel`: empty.
- `well_box(pad_x)`: StyleBoxFlat, bg WELL, border EDGE at BORDER,
  radius RADIUS, left and right content margin pad_x.

### 4.3 Scene and Main

`weave/Main.tscn`: `Main` Control full rect, mouse_filter ignore,
script `Main.gd`. `Backdrop` ColorRect full rect, mouse_filter
ignore, no colour set. `Interface` CanvasLayer layer 64. `Gear`
Button with script, nothing else. `Panel` PanelContainer with
script, `visible = false`, nothing else.

`Main.gd`: in `_ready`, loop `$Interface.get_children()`, set
`theme = LoomTheme.shared()` on each Control. Set
`$Backdrop.color = LoomTokens.BACKDROP`. Connect the gear's
`pressed` to the panel's `toggle`.

### 4.4 Gear

`weave/SettingsGear.gd`, `class_name SettingsGear extends Button`.
Named shape constants: TEETH 8, TIP_RATIO 0.48, VALLEY_RATIO 0.70,
HOLE_RATIO 0.28, TOOTH_TIP_HALF 0.16, TOOTH_VALLEY_HALF 0.30. In
`_ready`: variation V_GEAR, flat, no focus, pointing-hand cursor,
`_place()`, connect hover signals. `_place()`: min size GEAR_SIZE
square, anchors bottom-right, offsets so the square sits INSET from
both edges. `_draw()`: ink from
`get_theme_color("ink" or "ink_hover", "Loom")`, hub from
`"backdrop"`, polygon from the ratios, circle for the hub.

### 4.5 Section

`weave/LoadoutSection.gd`, `class_name LoadoutSection extends
VBoxContainer`. `setup(cap)`: name the node after the cap,
separation SPACE_1, one Label with the cap as text, then for each
`Loadout.FIELDS` a LineEdit named after the field, placeholder the
field, `secret = Loadout.is_secret(field)`, min height CONTROL_H,
horizontal expand fill. Keep a dictionary field to LineEdit.
`edit(field)`, `read()` returning a block with `strip_edges()`
applied, `write(block)`.

### 4.6 Panel

`weave/LoadoutPanel.gd`, `class_name LoadoutPanel extends
PanelContainer`.

- `_ready`: hidden, `_build()`, `_place()`, connect
  `get_viewport().size_changed` to `_place`, load from store once.
- `toggle`, `open` (just show), `close` (hide, clear status).
  Escape closes when visible.
- `field_edit(cap, field)` public.
- `_place()`: anchors bottom-right; width PANEL_W; height the lesser
  of PANEL_H_MAX and viewport height minus `panel_bottom_inset()`
  minus INSET; right edge INSET in; bottom edge
  `panel_bottom_inset()` up.
- `_build()`: MarginContainer with all four margins SPACE_4;
  ScrollContainer with horizontal scroll disabled; VBox with
  separation SPACE_3 and horizontal expand. Children in order: Label
  `loadout` on V_TITLE; Label
  `point each after deploy. nothing is in the base.` on V_MUTED;
  HBox separation SPACE_2 with Buttons Save, Export, Import at
  BUTTON_MIN_W by CONTROL_H; status Label on V_MUTED; one
  LoadoutSection per `Loadout.CAPS`, held in a dictionary by cap.
- Save: read all sections into a fresh `Loadout.empty_data()`,
  write it back to the fields so trimming shows, `save()`. On
  failure status `save failed`. Otherwise `saved on this browser`,
  with `. <caps> endpoint has no http:// or https://` appended when
  `endpoints_without_scheme()` is non-empty.
- Export: on web, `JavaScriptBridge.download_buffer` of the JSON as
  `loadout.json`. On desktop, native save dialog if
  `DisplayServer.has_feature(FEATURE_NATIVE_DIALOG_FILE)`, else
  write to `OS.get_user_data_dir()/loadout.json` and say where.
- Import: on web, a hidden `<input type=file accept=.json>` made
  once through `JavaScriptBridge.get_interface("document")`, a
  `change` listener from `JavaScriptBridge.create_callback`, a
  `FileReader` from `JavaScriptBridge.create_object`, `readAsText`,
  then the `onload` callback passes `reader.result` to
  `_import_text`. On desktop, native open dialog behind the same
  feature check, with `no file picker on this platform` if absent.
- `_import_text`: `loadout.from_text`; on failure `import
  rejected`; else write fields and say
  `imported. Save to keep it on this browser.`

### 4.7 Model additions

`weave/Loadout.gd`: `const SECRET_FIELDS := ["credential"]`,
`static func is_secret(field)`, and
`func endpoints_without_scheme() -> Array[String]` returning the
caps whose trimmed endpoint is non-empty and does not start with
`http://` or `https://`.

### 4.8 Tests

- `first_screen_smoke.gd`: instantiate, add to root, then in a
  deferred function after `await process_frame`: backdrop is
  BACKDROP, no `Slots`, no `Interface/Bar`, gear exists with a
  script, panel hidden. Print `SMOKE first-screen black + gear`.
- `loadout_smoke.gd`: keep the existing model checks. Scene checks
  deferred as above, using `field_edit`. Vendor grep covers
  `Loadout.gd`, `LoadoutPanel.gd`, `LoadoutSection.gd`, `Main.gd`,
  `theme/Tokens.gd`, `theme/LoomTheme.gd`.
- `theme_smoke.gd`: in `_init`, build the Theme and check every
  `COLORS` entry, the LineEdit normal box, the PanelContainer box,
  the three variation bases, title size, muted colour. Deferred:
  every Control child of `Interface` has the shared Theme; backdrop
  is the token; gear on V_GEAR with no stylebox override and reads
  INK; panel is a PanelContainer with `CAPS.size()` sections and
  every field present with the right secret flag and no overrides;
  no Label or Button under the panel has an override; after
  `toggle()` the panel rect is inside the viewport and PANEL_W wide;
  an edit typed into a field survives `close()` then `open()`.
  Print `SMOKE theme: tokens flow through LoomTheme, no hand
  styling`.

### 4.9 Packet

`artifacts/gear-panel-plan/gear-panel-plan.md` is the PDCA plan.
`tokens.svg` is generated from `Tokens.gd` by reading the constants
with a regex; regenerate it if a token changes. `before-panel-open.png`,
`after-panel-open.png`, `after-first-screen.png` are 1440 by 900
captures taken under Xvfb with `--rendering-driver opengl3`.
`thread.json` beside them is type `artifact`, `representedBy`
`gear-panel-plan.md`, `isPartOf` the root operation GUID
`65d82731-e9c3-451a-a223-be0bb4d56b06`.

### 4.10 Definition of done

- Four smoke commands print their `SMOKE` line and exit zero.
- `grep -rn -E 'Color\(|font_size' weave --include='*.gd'
  --include='*.tscn'` returns only `weave/theme/`, the smoke tests,
  and `ThreadCard.gd`.
- First screen is black with the gear bottom-right.
- Panel opens above the gear, saves, and the save survives a hard
  refresh on the deployed weave.
- Import opens a picker on the tablet.
- PR open to Seth, not merged by you.
