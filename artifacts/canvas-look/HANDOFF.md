# Claude tonight — retoken the canvas to the bible

Repo: `AutomatedPOS/loom-weave-godot`. Godot 4.3, GDScript. Live weave
is worker `dord-dev` at `https://loom.dord.dev/`. Owner Checks from a
tablet. Grok is on a Cursor Cloud seat, not the desk. Grok does not
touch `weave/` this sitting. You do.

One job. Then stop.

---

## Read these first, in this order

1. This file.
2. The tier-one bible (living, other repo):
   https://github.com/AutomatedPOS/loom/blob/master/DESIGN-BIBLE.md
   Fetch it. Do not work from memory. S1–S5 closed 2026-09-04. S6 is
   verify. Engine-specific look is tier two; this pass only takes the
   tokens the Godot surface is already breaking.
3. `artifacts/findings/2026-09-04-accent-charter.md` — the break.
4. `artifacts/canvas-look/canvas-look.md` — why the last look failed,
   and the standing interface rules.
5. `artifacts/canvas-spec/canvas-spec.md` — composition. Do not throw
   it out tonight.

The approved picture `artifacts/canvas-look/first-screen.svg` is the
last drawn screen. It still wears Portal orange and invented rail
chips. It is not the bible. Do not build back toward that costume.

---

## The job

`weave/theme/Tokens.gd` has one hardcoded orange accent:

```
const ACCENT := Color(0.93, 0.45, 0.13, 1)
```

The bible killed that. Charter field fifteen and sight 4.2:

- Black field. White and grayscale marks.
- Three accents, colour-blind-safe, swappable. Orange is out.
- Accent 1 **hazard** — something is wrong. Nothing else may use it.
- Accent 2 **current task** — look here and nowhere else. A position
  marker, not a command. Glowing / pulse is allowed; "act now" is not.
- Accent 3 **changed-since** — the nice-to-have. Italics are the
  mark; colour is extra.
- Precedence (4.7): current task, then hazard, then changed-since.
  Two accents visible at a time, not one. Top two show.

Tonight: retoken. Do not redraw the frame.

Replace `ACCENT` with three named tokens. Point every current
`ACCENT` use at **current task**. Today that is: the seat's top
edge, the arriving chip's ring and leader, the timeline cursor and
selected period. None of those are hazard. None of those are
changed-since.

Publish them on the `Loom` Theme type. Update `theme_smoke.gd` and
any smoke that names `accent`. Keep `grep -rn -E 'Color\(|font_size' weave`
returning only `weave/theme/`, the smokes, and `ThreadCard.gd`.

### Default colours, unless the owner overrode in the chat

Okabe–Ito, minus the orange. Marks, not body text. Ink stays gray.

| Token | Role | Hex | Godot |
|---|---|---|---|
| `HAZARD` | accent 1 | `#D55E00` | `Color(0.835, 0.369, 0.0, 1)` |
| `TASK` | accent 2 | `#56B4E9` | `Color(0.337, 0.706, 0.914, 1)` |
| `CHANGED` | accent 3 | `#CC79A7` | `Color(0.800, 0.475, 0.655, 1)` |

Do not paint hazard onto the timeline or the seat just to use the
token. If nothing on the first screen is broken, hazard is unused
and that is correct. Changed-since may stay unused until a real
diff exists; do not fake a "you looked away" state.

Black is absence (bible 4.1). Do not draw to fill space.

---

## Standing rules

- Never commit to `master`. Branch, PR to Seth, no auto-merge.
- Interface files only: `weave/` scripts and scene, `weave/theme/`,
  the smokes, dated beats under `artifacts/findings/`, and a
  1440×900 capture. No worker, export pipeline, deploy, DNS, or
  host-map. Do not run `wrangler pages deploy`. Do not deploy
  worker `dord` or `dord-dev`.
- No vendor names under `weave/`. `loadout_smoke.gd` greps for
  OpenAI and Anthropic.
- No secrets. Never log a credential. Never print a key into
  findings.
- Backdrop stays black. Gear stays bottom-right, subdued gray,
  opens the loadout. Cards stay off. `ThreadCard.gd` stays dead.
- Every colour, spacing step, font size, and control size lives in
  `weave/theme/Tokens.gd`. Never `add_theme_color_override`,
  `add_theme_font_size_override`, or `add_theme_stylebox_override`
  for style.
- Theme does not cross a CanvasLayer. `Main` keeps handing
  `LoomTheme.shared()` to each Control child of `Interface`.
- The renderer reads. It does not write. No timers. No polling.
- Owner reviews from a tablet. Touch targets, not mouse targets.
- Findings: one dated beat in
  `artifacts/findings/2026-09-05-bible-tokens.md`. Short.

---

## Not tonight

Leave these. They are real, and they are not this pass.

- Sky / middle / water bands (bible 4). The canvas spec still has
  inputs left, work middle, ports right, timeline along the bottom.
  That fight is a later sitting, with a new picture first.
- Glyph artwork. Bible out-of-scope item 3. Grammar only.
- Hearing (bible 5). Loadout already holds chat / speech / hear.
- Shape save on the browser. Persona bind-to-talk. Grok's half.
- Labelling the ports. Owner already said leave them unlabeled;
  `canvas_smoke.gd` fails if `save` / `export` / `discard` appear
  as labels.
- Inventing a tool, or Walk / Close / Capture / Tree / Checkers.
  Rails read the tree. Tools is empty. Brief is the only process.
- Pan, zoom, a font token, refresh hook, iteration counter.
- Deploy. Merge to `master`. Closing `canvas-plumbing`.

If you need a plumbing change to retoken, write it in findings and
leave it. Do not wait.

---

## Acceptance

- Picture first: a 1440×900 capture of the retokened first screen,
  before prose. `weave/capture.gd` under Xvfb + opengl3. Put it at
  `artifacts/canvas-look/after-bible-tokens.png`. If you are also
  on a cloud seat, that path still holds.
- Orange is gone from `Tokens.gd` and from the capture.
- Three named accent tokens exist. Current-task is the only one
  that must appear on the first screen.
- All five smokes print `SMOKE` and exit 0:

```
godot --headless --path . --import --quit
godot --headless --path . -s weave/first_screen_smoke.gd
godot --headless --path . -s weave/loadout_smoke.gd
godot --headless --path . -s weave/theme_smoke.gd
godot --headless --path . -s weave/monitor_smoke.gd
godot --headless --path . -s weave/canvas_smoke.gd
```

- Gear still opens the loadout. Paste and tablet IME untouched.
- PR open. Not merged by you.

Hand back: what you changed, the PNG path, which of the three
accents actually appear on the first screen. Stop. Seth turns it
to Grok. Grok deploys `dord-dev` only. Owner hard-refreshes
`loom.dord.dev`.
