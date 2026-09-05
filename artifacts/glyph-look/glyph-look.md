# Glyph look

Reference icons for the three noun subclasses, drawn to the tier-one
bible: personas (human and robot), processes, tools. Look at
`glyph-modes.png` first, then `glyph-sheet-dark.png` and
`glyph-sheet-light.png`, 1440 by 900 each. The single tiles are in
`tiles/dark/` and `tiles/light/`: `persona-human`, `persona-robot`,
`process`, `tool`, hollow and `-solid`, plus `null-tile`, each one
64-unit square tile. `PACKET.md` is the handoff index; `tokens.json`
carries both palettes and the tile rules.

This is a picture for the owner's Check. The interface draws the
same geometry from `weave/Glyphs.gd`. Frames are borrowed; skins
swap. Round is human, boxy is machine.

## The grammar, applied

Bible 4.3: two frames per tile. The outer frame is borrowed and says
the type. The inner glyph is the skin and swaps. Fill carries state.
Round is human, boxy is machine.

| Tile | Outer frame, borrowed from | Skin, default |
| --- | --- | --- |
| persona · human | circle, the avatar convention | sphere on a closed capsule, front-on, neck is the gap |
| persona · robot | circle, the same frame; the skin is what changes | cube head, visor slot, stub antenna, cube torso |
| process | flowchart process, the rectangle | three stations on a rod; spine only reads in the gaps |
| tool | flowchart predefined process, the double-barred rectangle | an open-end spanner at forty-five degrees |
| null | a dashed square, dim | nothing; the hole is the content |

Why these frames:

- **Persona.** BPMN has no participant shape smaller than a pool, and
  a pool is unreadable at chip size. The circle is the avatar
  convention every chat surface uses, so it is borrowed, not
  invented. Human and robot share the frame; the type channel says
  persona, the silhouette channel says who. That keeps 4.3's two
  channels separate. Which persona wears which skin is the owner's
  call; the sheet puts Archivus in the human skin and Brains in the
  robot skin as placeholders only.
- **Process.** The flowchart process rectangle, square corners for
  settled. A still-forming process would take the cloud, per 4.3;
  not drawn here because nothing forming is on the rails.
- **Tool.** The flowchart predefined process, a rectangle with two
  side bars: a routine already built that you call. The canvas today
  uses a diamond for tools. In the borrowed vocabulary a diamond is a
  decision, so the diamond goes when this lands.
- **Process skin.** The spine with stations is Loom's own transit
  grammar from 4.8, so the process glyph is the plan in miniature.
  It does not carry state on its stations; the whole skin takes the
  fill.

## State and modifiers, on the sheet

Bible 4.5: hollow is not started, solid is done, motion is running,
subdued is abandoned, broken takes hazard. On the rails a chip is
hollow; once it is on the field it is solid. That matches what
`Canvas.gd` already does for a docked chip.

Bible 4.7 modifiers, ranked task, hazard, changed, two at a time:

- current task: the frame takes `TASK`, amber, and a thin ring
  outside it pulses.
- broken: the skin takes `HAZARD`, oxblood; no fill of its own.
- changed since: the frame takes `CHANGED`, steel blue.
- task and broken together: frame task, skin hazard. Changed drops.

The null tile, 4.6: a dashed dim square with nothing in it. Broken
null takes hazard on the dash.

Running cannot be shown in a still. Candidate from 4.5 is the outline
animating; that is a build question, not a drawing one.

## Two modes

Dark is the black field. Light is its inverse: a white field, the
greys mirrored so ink is dark and dim is mid. Geometry is identical.
Hazard keeps its value in both. Task and changed keep their hue and
pull down on white, since the dark amber sits at 2.4:1 on white and
the steel at 3.4:1; the light values sit at 4.4:1 and 5.1:1. The
palettes are spelled once, in `tokens.json` and at the foot of each
sheet.

## Sizes

Drawn at 64 with a 2-unit stroke. Reads at 32 and at 24, the second
row of the sheet. At 24 the stroke is 0.75 px, which is under a pixel;
if the chip glyph lands at 24 the stroke should snap to 1 px in the
draw code rather than scale. The skin never touches the frame: it
sits inside a 32-unit box centred in the tile, so a state fill, a
hazard skin, and a task ring never collide.

## Drag, drop, and the models to come

Bible 4.3's note that personas are physical objects, and the owner's
word that these become rigged 3D models very soon, set two rules for
the artwork:

- **The frame is the collider and the drop target.** The skin is
  what you see; the frame is what you grab and what a socket accepts.
  A skin swap never changes hit geometry.
- **Every skin is a front elevation of a few primitives**, so a
  modeller can build it without guessing:
  - human: a sphere on a capsule. One pivot at the neck. Head can
    turn to face the thing it is attached to.
  - robot: a box head on a box torso, the visor an emissive slot
    that can take the accent, a stub cylinder antenna on the head.
    One pivot at the neck, one at the antenna base.
  - process: three cubes on a rod. The cubes are the stations; an
    actual arriving slides along the rod and snaps in, per 4.15.
  - tool: the open-end spanner extruded. One pivot at the jaw, so a
    tool "operating" can be a small rotation.
  - null: a wireframe cube, dashed. Nothing inside.

The 2D tile stays the rail and chip representation. The model is
what sits on the field once dropped. Same silhouette from the front,
so the thing you dragged is the thing that lands.

## Not drawn

Sky, water, and middle bands. Imperatives and the tree's other node
types; 4.4 says they are the imperatives class plus modifiers, not
new nouns. Firmness (the cloud frame). A font. Motion. Tool names:
the tools rail is empty until the owner authors one, so the sheet
shows the tool chip unnamed.

## Open, for the owner

1. Persona frame: circle as the avatar convention, or a BPMN pool
   band. Circle is drawn.
2. Which persona is human and which is robot. Placeholders on the
   sheet.
3. Whether the process skin should be the three-station spine or a
   plain BPMN task marker. Spine is drawn because it is Loom's own.
4. Chip glyph size on the rail: keep 12, or go to 24 as the sheet
   shows.
