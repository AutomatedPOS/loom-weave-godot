# Slot spec

Depth in the weave. This is the renderer contract for where a thing
sits front to back. It is complete; there is no OPEN list.

## Slots, not coordinates

Depth is a set of discrete planes. A thing occupies a slot. It does
not occupy a depth value.

Motion is between slots, never within one. There is no interpolation
along the depth axis and no fractional slot. A renderer that wants to
animate a move between two slots animates the transition; it does not
invent an intermediate slot to pass through.

## Signed integers, zero at the viewer

A slot is an integer.

Zero is the viewer's plane. Negative numbers go back, away from the
viewer. Positive numbers come forward, toward the viewer.

Sorting slots ascending sorts them back to front, which is draw order
for content.

## Unbounded

The band has no floor and no ceiling. A new backmost slot is a number
nobody has used yet. So is a new frontmost.

Nothing is reserved. Nothing is allocated in advance. There is no
declared range, no configured depth count, and no maximum. A slot
number is valid because something is in it.

## The renderer reads what exists

The renderer never needs to know the extent of the band. It collects
the slots that are occupied, sorts them, and draws.

This is the reason the band can be unbounded without bookkeeping.
There is no range to keep in sync with the content, so the range
cannot go stale, and adding a thing behind everything else is not a
migration.

Gaps are normal. Slots -40, -3, and 12 occupied with nothing between
them is a valid scene, not a sparse array to compact.

## Two sentinel tracks

Two tracks sit outside the number line. They are not slots and they
have no numbers.

**Backdrop** draws first, behind every slot.

**Interface** draws last, in front of every slot.

Content lives between them. Content can never reach the interface: no
slot number, however large, draws in front of the interface track, and
none, however small, draws behind the backdrop. The tracks are the
bookends, and they are why an unbounded band is safe to hand to
content that grows on its own.

## Draw order, whole

```
backdrop            first, always
slots ascending     -N ... -1, 0, 1, ... +N   occupied only
interface           last, always
```

## Not decided here

What lands on a slot first, colours, whether the centre object
migrates or stays put, and frame and grid authoring are all outside
this document and stay that way.
