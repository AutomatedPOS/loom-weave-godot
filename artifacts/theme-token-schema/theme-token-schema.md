# Theme Token Schema — v1

**Status:** settled
**Owner:** Seth
**Applies to:** the chat/console interface (base menu system + user themes)

## Purpose

A three-tier token file that fully describes the visual layer of the
interface. Structure lives in the menu tree; **all** appearance lives
here. A theme is a swappable file — nothing in the layout code changes
when a theme changes.

Designed so an LLM can generate a valid theme without being able to
break the layout.

---

## The three tiers

| Tier | Contains | Who writes it | Accepts literals? |
|---|---|---|---|
| `primitives` | Raw palette, type scale, spacing steps, radii, font families | LLM or user | **Yes — only tier that does** |
| `semantic` | Meaning-bearing names (`text.primary`, `surface.base`) | LLM, sparingly | No — references only |
| `components` | Per-component overrides (`menu.item.bg.hover`) | Rarely touched | No — references only |

A minimal valid theme is `meta` + `primitives`. Everything else defaults.

---

## Reference file

Shipped at `weave/themes/midnight-rink.json`.

```json
{
  "$schema": "fence.theme/v1",
  "meta": {
    "id": "midnight-rink",
    "name": "Midnight Rink",
    "author": "seth",
    "base": "dark"
  },

  "primitives": {
    "color": {
      "ink-000": "#000000",
      "ink-100": "#12141a",
      "ink-200": "#1c1f28",
      "ink-800": "#c7ccd8",
      "ink-900": "#ffffff",
      "brand-500": "#3ba7ff",
      "warn-500": "#ffb020",
      "danger-500": "#ff4d4d"
    },
    "space": [0, 4, 8, 12, 16, 24, 32, 48],
    "radius": [0, 2, 6, 12, 999],
    "font": {
      "display": "Barlow Condensed",
      "body": "Barlow",
      "mono": "IBM Plex Mono"
    },
    "size": [12, 14, 16, 20, 28, 40]
  },

  "semantic": {
    "surface.base":      "{color.ink-100}",
    "surface.raised":    "{color.ink-200}",
    "surface.overlay":   "{color.ink-000}",
    "text.primary":      "{color.ink-900}",
    "text.muted":        "{color.ink-800}",
    "text.inverse":      "{color.ink-100}",
    "accent.default":    "{color.brand-500}",
    "accent.text":       "{color.ink-000}",
    "focus.ring":        "{color.brand-500}",
    "state.danger":      "{color.danger-500}",
    "state.warning":     "{color.warn-500}",
    "border.subtle":     "{color.ink-200}",
    "radius.control":    "{radius.2}",
    "space.gutter":      "{space.4}",
    "font.heading":      "{font.display}",
    "font.body":         "{font.body}"
  },

  "components": {
    "menu.item.bg":            "{surface.base}",
    "menu.item.bg.hover":      "{surface.raised}",
    "menu.item.bg.selected":   "{accent.default}",
    "menu.item.text":          "{text.primary}",
    "menu.item.text.selected": "{accent.text}",
    "menu.panel.bg":           "{surface.raised}",
    "menu.panel.border":       "{border.subtle}",
    "menu.cursor.color":       "{accent.default}"
  }
}
```

---

## Rules that make it LLM-safe

1. **Keys are fixed.** Ship a manifest of every legal key. The model
   supplies *values only* and never invents names. Unrecognized keys
   are dropped at load, silently, with a log line.
2. **Only `primitives` accepts literals.** Every value in `semantic`
   and `components` must be a `{reference}`. This is what stops a
   model from hardcoding a hex in the wrong tier.
3. **`components` is optional and fully defaulted.** Generation
   targets `primitives` plus a handful of `semantic` overrides.
4. **Patches are partial and additive.** The model never emits a
   whole theme — only deltas. A bad response degrades to "nothing
   changed," never a white screen.

---

## Validation on ingest

Run in this order. Fail closed.

1. **Schema check** — `$schema` present and recognized; unknown
   top-level keys dropped.
2. **Key whitelist** — every key checked against the manifest;
   unknown keys dropped.
3. **Reference resolution** — resolve all `{...}` refs. Fail on
   dangling refs. Fail on cycles.
4. **Type check** — colors parse as color, `space`/`size`/`radius`
   entries are numbers.
5. **Contrast check** — minimum 4.5:1 for text pairs. Auto-nudge
   lightness if close, reject if not recoverable.

### Contrast pairs that must pass

- `text.primary` ↔ `surface.base`
- `text.muted` ↔ `surface.base`
- `text.primary` ↔ `surface.raised`
- `accent.text` ↔ `accent.default`
- `menu.item.text` ↔ `menu.item.bg`
- `menu.item.text.selected` ↔ `menu.item.bg.selected`

---

## Runtime application

Resolved values are written to CSS custom properties on the root
element. The interface repaints instantly because every rule already
reads from those variables. No re-render, no reload.

**Undo is refresh.** Themes are not persisted until explicitly saved,
so a hard reload restores the last good state. Acceptable for this pass.
