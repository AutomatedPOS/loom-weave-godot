# Break to fix — accent token vs tier-one charter

Date: 2026-09-04. Source: create-design-bible. Not fixed.
Do not treat the live weave as matching the bible.

Tier-one bible (first pass):
https://github.com/AutomatedPOS/loom/blob/master/DESIGN-BIBLE.md

Charter field fifteen: black field, white and grayscale marks, three
accents from a colour-blind-safe set, swappable. Orange is out.
Mood-board reference 1 (Portal chamber info icons) is the reason:
that is the palette of the source. Take the grammar, not the costume.

The bible names the three: hazard, current task, changed-since.
`weave/theme/Tokens.gd` still has one hardcoded orange accent:

```
const ACCENT := Color(0.93, 0.45, 0.13, 1)
```

Comment on that line still calls it the one colour that is not gray.

Engine-specific look is tier two. A render cycle may retoken; this
file exists so the delta is not lost.

