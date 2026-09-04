# Findings — gear panel pass

Date: 2026-09-04. Seat: Claude Code, cloud session. Branch
`claude/interface-files-organization-5hfvis`. Owner sitting outside.
Check is tablet refresh on `loom.dord.dev` after merge and deploy.

## Beats

### 2026-09-04 — Read pass

Inventoried the panel before touching it. Ten findings, ranked. The
top three: no central style seam, palette duplicated across gear and
panel, capability and field lists written out five times with index
math for lookup. Full list in `artifacts/gear-panel-plan/`.

### 2026-09-04 — Baseline

Godot 4.3 stable, headless. `first_screen_smoke` and
`loadout_smoke` both pass on the unmodified tree. Captured the open
panel under Xvfb with the OpenGL renderer for a before image.

### 2026-09-04 — capture.gd flips the wrong way here

The repo's `capture.gd` flips the image on the assumption the
viewport texture is upside down. Under Xvfb with OpenGL it is not,
and the flip produced an inverted PNG. Left `capture.gd` alone;
took the pass's captures without the flip.

### 2026-09-04 — Tokens and Theme

`weave/theme/Tokens.gd` holds every value. `weave/theme/LoomTheme.gd`
builds the Theme. Three spacing values moved to a 4-step scale: 10
to 12 twice, 14 to 16 once.

### 2026-09-04 — A CanvasLayer stops the Theme

First attempt installed the Theme on the Window. The gear could not
read a colour from it. Godot's theme owner lookup walks Control and
Window parents only, and `Interface` is a CanvasLayer. Main now hands
the shared Theme to each Control directly under `Interface`.

### 2026-09-04 — Smoke tests ran before _ready

Moving the disk read out of `open()` exposed that the loadout smoke
test adds the scene inside `SceneTree._init`, before the tree is
live, so `_ready` had never run when it looked at the fields. The
old code passed only because `open()` re-read the disk each time.
Scene checks in both tests now wait one frame.

### 2026-09-04 — Section component, panel container

`LoadoutSection` builds one capability block and finds fields by
name. The panel is a PanelContainer; the Theme draws its surface and
border, so five ColorRects are gone. `field_edit()` is the public
lookup; the smoke test uses it instead of the private one.

### 2026-09-04 — Behaviour changes, deliberate

Unsaved edits now survive a toggle. Save trims fields and names any
endpoint without a scheme in the status line, without blocking.
Import on web goes through a browser file picker instead of the
native dialog the web build does not have. That last path is not
runnable headless and waits on the tablet Check.

### 2026-09-04 — Short viewport

Captured before and after at 1024 by 600. Identical: the project's
canvas-items stretch scales the panel in at that aspect. The new
height clamp only shows on aspects shorter than the design size. It
stays as a guard.

### 2026-09-04 — All green

`first_screen_smoke`, `loadout_smoke`, `theme_smoke` exit zero.
After captures beside the plan. Pushed to the branch. PR to the
owner. No merge from this seat.
