# Pods spec

The 2026-09-05 interface walk, written down so later sittings can
pick work without re-walking. This is the Plan-grade record of what
was decided. It is not a picture and it is not a Do.

The painted rails-and-ports canvas stays paused. This packet does
not put it back. `weave/` is not touched from this file.

## What this is

The window is a surface of objects. A pod is an object on that
surface. You open it and configure it. There is no settings tree
and no privileged app chrome.

Named prior art: HyperCard, Smalltalk. Object-oriented UI.

The first named tool is `muster mob`. The tools roster was empty
because no tool had been named. That is no longer true.

## Relation to the 2026-09-04 canvas spec

Kept:

- Personas, processes, and tools are the three kinds.
- Attachment is still how a process lands on a bot: drag it on.
- The renderer still does not write the tree.
- Shape-not-data still holds for *views of the tree*. A pod file is
  the object's own config, not a snapshot of node bodies.
- Landscape reading, tokens, no secrets in the repo.

Revised, pending owner Check of this packet:

- The window is free-form pixel space, not three rails plus ports.
- Kinds appear as pods, not as edge chrome. OPEN 5 (rails visible
  or summoned) is answered that way: they are not chrome.
- Gear as the settings hole is superseded. Keys live in a token
  store. The store is a pod.
- Close and minimize are file operations on the pod JSON, not
  ports. Discard-as-a-port is not restated here. Spec OPEN 3 is
  not closed by this walk.

## Canvas

The background is free-form pixel space. There is no global grid.
A pod that needs cells brings its own cell rules.

Everything on the canvas is a JSON file.

- Close deletes the file.
- Minimize keeps the file with a collapsed flag.
- Critical is a field in the JSON, not a special case in the
  renderer.

## Hex

Hexagon is for planning and directionality. It does not house
chrome. Panels stay rectangular.

Six neighbors. No diagonal cheat.

Size is rings from center: 1, 7, 19, 37. Not powers of two. Same
ring vocabulary as the Earshot voiceprint mark.

Standing note: hexagon whenever directionality matters.

## Kinds

Three kinds, visually distinct. No fourth.

| Kind | Body |
|---|---|
| Persona | Low-poly humanoid robot mesh |
| Tool | Machined housing, icon faceplate, nameplate |
| Process | Drawn: lines and nodes, not a body |

Tool naming is verb, then noun. The icon carries the verb. The
nameplate carries the noun.

## muster mob

The first tool. Verb *muster*, noun *mob*.

Mob also names the unslotted broadcast: an unslotted bot hears
everything on the open canvas, receives packaged waves of board
context at intervals, and answers whether you asked or not.
Slotting it gives it specific context and quiets it.

Icon: not drawn. Sketch on the walk was a slot with a figure
rising out of it (recruiting). Cell-size mark is the live
question.

## Interaction and power

On a pod:

- Tap opens the panel.
- Press-and-hold toggles power. The destructive action is the
  deliberate one.

Three power states for a bot:

| State | Meaning |
|---|---|
| Unpowered | No key. Empty slot. |
| Awake | Keyed and broadcasting |
| Knocked out | Keyed, silenced, lies on the floor |

Tap to silence. Double-tap to knock out. Visible nudge as
feedback.

OPEN inside this ruling: tap-opens-the-panel and tap-to-silence
were both said. Do not invent the split. Owner rules whether they
are different targets, or silence is a first beat of knockout.

## The bench

Exactly three seats. Not a widget cap. A scope check. A fourth
bot means the sitting has drifted.

The roster behind the bench grows in multiples of three.

The fourth slot on the bench *panel* is the spend meter: session
total plus per-slot current spend. It is not a bot seat. Bible
5.2 (spend is always visible) lands here.

## Bot file

A bot is three plain-text fields plus token pointers, saved as
JSON. Paste markdown in.

| Slot | What | Shape |
|---|---|---|
| 1 Identity | Persona file | File / markdown |
| 2 Knowledge | AGENTS.md-shaped project context | File / markdown |
| 3 Behavior | Processes it can run | A list, not a file |

Processes are added by dragging a process onto the bot. The list
is readable on the info panel.

The bot file holds token *references*, never keys. Keys live in
the token store. That is what makes a bot file shareable.

No UUID on the bot file. The repo is the identity: path plus
commit history is the version. The file carries the name only.
Tree nodes in this repo still have guids; that rule is the
loom-warp node shape, not this file.

MCP covers tool capabilities. No bespoke capability system. The
three slots are only what a server cannot provide.

## Service slots and keys

API keys are user-supplied. No shipped keys. A pod comes
pre-wired to a service with a link to go acquire a key. Seventy
percent staged. No liability.

The stable thing in code is the *slot*, not the vendor. Named
plugs: OpenRouter primary, Gemini and OpenAI as alternatives.
`weave/` still does not print vendor names. The slot name is
what the engine sees; the vendor is data in the token store.

Key status is earned, not asserted. Green only after a live call
returns clean. Validate-on-use. Restated canon, not new.

## Jury

Opt-in. Default is one token.

Multiple tokens may sit on one bot. One is flagged primary.
Supporting models answer the same prompt. The primary compares
blind: shuffled A/B/C. Selection is tracked after.

The cost multiplier is shown plainly. Bible 5.1 already named
two top slots pointed at different models; this is that idea
with a referee.

The walk's unjudged tip for the demo: watch the models fight it
out on screen.

## Context budget

A fill bar on the bot, not a cap. Persona plus skill file against
the window. Crossing it turns the bar red. You can still cross.

The line on the walk: "you're breaking the box."

## Parked (do not build from)

- Draw-your-own process on canvas. Floated, not designed.
- Cold open as a shippable pod. Named, not specced.
- Working-memory bench zone. Raised, then pulled back.
- Header/canvas split (top ~20% fixed, including timeline).
  Stated, not locked. Fixed-not-scrollable was not ruled.
- Cell-selection-defines-container. Owner stopped it as too deep.
- Diablo-style isometric for the bench. Tinkering.
- muster mob icon at cell size.

## Asides (not requests)

Coin-slot iconography for tokens. Arcade slot reads as an action;
empty slot is the no-key state without a label.

Baby Billy / Righteous Gemstones "silencio" sting on rage-click
silence: synthesize a soundalike, do not lift the clip.

"That juggling action is doing. It's not a free action. It
costs."

## Tensions, not silently closed

Do not amend `DESIGN-BIBLE.md` from this sitting. A filed bible
restarts S1. Record the cracks:

- 4.3 round=human / square=machine versus personas as robot meshes.
- 4.8 branches at forty-five degrees versus hex with no diagonal.
- 5.4 Loom never initiates versus unslotted bots answering
  whether you asked.
- Gear as interface-track chrome versus no privileged app chrome.
- `weave/` vendor-name ban versus named plugs in the token store.

## What this does not change

The window is still a white sheet until a later loop puts a mark
there. This spec is not permission to paint. No `weave/` edit.
No deploy. No bible edit. PR #19 shape store stays parked.
