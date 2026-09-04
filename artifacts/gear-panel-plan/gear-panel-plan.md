# Gear panel plan

PDCA. This file is the Plan step of a refinement pass in
`loom-weave-godot`, keyed on the interface track: the settings gear
and the loadout panel it opens. It runs beside cycle three, whose
Act still waits on the owner's tablet Check. It does not claim a
cycle number.

The workItem is `gear-panel`. The Do landed with this Plan, in the
same commit set, because the audit that motivated it had already
established every fact the Plan needed.

## Target

Same screen, same behaviour, one source for every style value. After
this pass:

- Every colour, font size, spacing step, and control size the
  interface uses is a named token in `weave/theme/Tokens.gd`.
- One Theme, built from those tokens by `weave/theme/LoomTheme.gd`,
  styles every Control on the interface track.
- No script in `weave/` applies a colour, font size, or stylebox by
  hand. Type variations replace per-node overrides.
- The repeated capability block is one component,
  `weave/LoadoutSection.gd`, and fields are found by name.
- A regression test, `weave/theme_smoke.gd`, fails the build if any
  of the above slips.

## What the audit found

The read pass of 2026-09-04 inventoried the panel before any change.
In short:

1. No central style seam. Colours were script constants, applied as
   per-node theme overrides, with StyleBoxFlat objects built inside
   factory functions.
2. Palette duplicated. Gear and panel each declared INK with the
   same value. `ThreadCard.gd` carried a third, unrelated palette.
3. The chat, speech, hear and endpoint, credential, model lists were
   written out five times in the panel. Field lookup was `i * 3 + j`
   index math tied to build order. The LineEdit name was set and
   never read.
4. Edit and button styleboxes were built per widget, twelve and six
   per panel, from near-identical code.
5. Panel geometry was fixed in the scene as offsets. No response to
   a short viewport.
6. The one-pixel border was four ColorRects.
7. Unsaved edits were discarded on toggle, because open() reloaded
   from disk.
8. Import on the web build went through the native dialog API,
   which the web display server does not implement.
9. The loadout smoke test called a private method on the panel.
10. Gear geometry was five unnamed floats.

## Token set

Source: `weave/theme/Tokens.gd`. Sheet: `tokens.svg` beside this
file, generated from the source.

| Token | Value | Was |
|---|---|---|
| BACKDROP | Color(0, 0, 0, 1) | Backdrop ColorRect, gear hub, clear colour |
| INK | Color(0.68, 0.68, 0.70, 1) | INK in gear and in panel |
| INK_HOVER | Color(0.78, 0.78, 0.80, 1) | INK_HOVER in gear |
| DIM | Color(0.42, 0.42, 0.44, 1) | DIM in panel |
| SURFACE | Color(0.04, 0.04, 0.045, 0.96) | PANEL in panel |
| WELL | Color(0.10, 0.10, 0.11, 1) | WELL in panel |
| EDGE | Color(0.22, 0.22, 0.24, 1) | EDGE in panel |
| SPACE_1 | 4 | section gap |
| SPACE_2 | 8 | button gap, edit side padding |
| SPACE_3 | 12 | column gap (was 10), button side padding (was 10), gap above gear (was 12) |
| SPACE_4 | 16 | panel padding (was 16 sides, 14 top and bottom) |
| SPACE_5 | 24 | reserved |
| TEXT_SM | 12 | subtitle, status |
| TEXT_MD | 14 | captions, fields, buttons, default |
| TEXT_LG | 18 | title |
| BORDER | 1 | every border |
| RADIUS | 0 | every corner |
| CONTROL_H | 36 | field and button height |
| BUTTON_MIN_W | 88 | button width |
| GEAR_SIZE | 32 | gear square |
| INSET | 16 | distance from the window edge |
| PANEL_W | 384 | panel width |
| PANEL_H_MAX | 760 | panel height, before clamping to the viewport |

Three spacing values moved to sit on a 4-step scale: 10 became 12
twice, and 14 became 16 once. Nothing else changed size. The
before and after captures beside this file show the difference.

The Theme publishes the seven colours under type `Loom`, so any
Control can read them with `get_theme_color(name, "Loom")`. The gear
draws with those. Three type variations exist: `TitleLabel`,
`MutedLabel`, and `GearButton`.

## Steps, as executed

Each step names its files and its acceptance check.

### 1. Tokens

`weave/theme/Tokens.gd`. Constants only, plus one helper for the
panel's bottom inset. Accept: every literal from the audit's table
appears here once and nowhere else in `weave/`.

### 2. Theme builder

`weave/theme/LoomTheme.gd`. `build()` returns a Theme; `shared()`
caches one. Sets Label, LineEdit, Button, PanelContainer, and
ScrollContainer items, the three variations, and the `Loom` colour
type. One helper, `well_box`, replaces the four copies of the
sunken-face stylebox. Accept: `theme_smoke.gd` reads every token
back out of the built Theme.

### 3. Apply the theme

`weave/Main.gd`. Main hands `LoomTheme.shared()` to every Control
directly under the `Interface` CanvasLayer. This is the one place
the theme is installed. Godot does not propagate a Theme across a
CanvasLayer, so setting it on the Window or on Main would not reach
the gear or the panel. Main also sets the backdrop colour from the
token. Accept: `theme_smoke.gd` checks each Interface child carries
the shared Theme.

### 4. Gear

`weave/SettingsGear.gd`. Variation `GearButton` replaces four
stylebox overrides. Colours come from the Theme at draw time. Size
and inset come from tokens and are applied in `_place()`; the scene
no longer carries offsets. The five geometry ratios are named
constants with a comment saying they are shape, not style. Accept:
first-screen smoke still passes; theme smoke checks the gear has no
override and reads INK from the Theme.

### 5. Section component

`weave/LoadoutSection.gd`, new. A VBoxContainer that builds one
caption and one LineEdit per `Loadout.FIELDS`, keyed by field name.
`read()` trims edges. `write()` fills from a block. `edit(field)`
returns the LineEdit. `Loadout.gd` gains `SECRET_FIELDS` and
`is_secret()` so the section does not spell "credential". Accept:
theme smoke finds exactly `Loadout.CAPS.size()` sections and one
edit per field with the right secret flag.

### 6. Panel

`weave/LoadoutPanel.gd`. Now a PanelContainer. Structure is
PanelContainer, MarginContainer, ScrollContainer, VBoxContainer.
The Theme's PanelContainer stylebox draws surface and border, so the
background ColorRect and the four border rects are gone. Labels use
variations. Buttons and edits have no overrides. The three lists
are gone; the panel iterates `Loadout.CAPS` and holds sections in a
dictionary by cap. `field_edit(cap, field)` is the public lookup.
`_place()` anchors bottom-right above the gear and clamps height to
the viewport, and re-runs on viewport resize. `open()` no longer
reloads from disk, so unsaved edits survive a toggle. Accept: loadout
smoke passes through `field_edit`; theme smoke checks no hand
styling, in-viewport placement, width equal to the token, and that
an unsaved edit survives close and open.

### 7. Import and Save

Same file. On web, Import opens a browser file picker through
`JavaScriptBridge`: a hidden file input, a change listener, a
FileReader. On desktop it checks for the native dialog feature
before calling it and says so if it is missing. Save trims every
field, then names any capability whose endpoint lacks `http://` or
`https://` in the status line. Save still proceeds. Accept: the
desktop path is unchanged and covered by loadout smoke. The web
path is not runnable headless here; see Risks.

### 8. Scene

`weave/Main.tscn`. Gear and Panel nodes keep only type, script, and
the Panel's hidden flag. Panel type is PanelContainer. The Backdrop
no longer carries a colour; Main sets it from the token. All
placement moved to code so it has one source. Accept: both smokes
instantiate the scene.

### 9. Tests

`weave/loadout_smoke.gd` uses `field_edit` and greps the two theme
files and the section for vendor names too. Its scene checks moved
one frame later, because nodes added inside `SceneTree._init` have
not had `_ready` run yet; the old code passed only because open()
re-read the disk. `weave/theme_smoke.gd` is new. Run all three:

```
godot --headless --path . --import --quit
godot --headless --path . -s weave/first_screen_smoke.gd
godot --headless --path . -s weave/loadout_smoke.gd
godot --headless --path . -s weave/theme_smoke.gd
```

## Not this pass

- Any new field, capability, or vendor preset.
- Talking to a model. Still no chat.
- Deleting `ThreadCard.gd` or `TreeLoader.gd`. Both are outside the
  interface track. `ThreadCard.gd` is dead; `TreeLoader.gd` is used
  by `smoke.gd`. A separate decision.
- A font family. The type scale names sizes only.
- Blocking Save on a malformed endpoint. It warns.
- Encrypting the on-machine loadout or the export. Plaintext is the
  current, tested behaviour; the cycle-three plan accepted it.
- `capture.gd`. Its `flip_y` produced an upside-down image on the
  OpenGL renderer under Xvfb during this pass. Left alone; noted.
- Host, worker, export, or deploy changes.

## Risks

- **Web Import is untested.** The JavaScriptBridge path follows the
  documented pattern and is guarded to the web feature, but nothing
  headless can exercise it. The owner's tablet Check is the test. If
  it fails, the fallback is the previous behaviour: a status line
  saying the picker failed.
- **Three spacing values moved by two pixels.** Deliberate, so the
  scale has four steps. Visible only side by side.
- **Theme install point.** Any future Control added under
  `Interface` gets the Theme from Main's loop automatically. A
  Control added elsewhere on a CanvasLayer would need the same.

## Success bar

Passes when:

- All three smoke scripts exit zero on Godot 4.3.
- No interface file under `weave/` other than `theme/Tokens.gd`
  contains a `Color(` literal or a numeric font size. `ThreadCard.gd`,
  dead and off the track, still carries its own palette until the
  separate decision on it.
- The first screen is still black with the gear bottom-right.
- The panel opens, saves, and the save survives a hard refresh on
  `loom.dord.dev`, same as cycle three's bar.
- Import on the tablet opens a file picker.

A first screen that is not black, a vendor name anywhere in
`weave/`, or a smoke failure is a fail.

## After

The next pass can change a token and watch the whole interface
follow. Candidates: a font resource, a light palette, a fourth
capability. Each is a Plan of its own.
