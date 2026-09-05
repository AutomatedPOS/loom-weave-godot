# Walk packet — 2026-09-05

## What this walk was
Morning daydream on Loom's interface — the canvas, how pods appear on it, and the design of the bot tool. Output intended to distill into feature requests on the Loom repo.

## Decided
- **API keys are user-supplied.** No shipped keys. Pods come pre-wired to a service with a link to go acquire a key. Seventy percent staged, no liability.
- **Service slots, not vendors.** OpenRouter primary, Gemini and OpenAI as named alternatives. The slot is stable; the vendor plugs in.
- **Key status is earned, not asserted.** Green only after a live call returns clean. Validate-on-use. (Pre-existing canon, restated — not new.)
- **Pods, not settings.** Everything on the canvas is an object you open and configure. No settings tree, no privileged app chrome.
- **Everything on the canvas is a JSON file.** Close means delete the file; minimize means keep with a collapsed flag. "Critical" is a field in the JSON, not a special rule.
- **Canvas background is free-form pixel space.** Grid is not global — a pod brings its own cell rules if it needs them.
- **Hexagon is for planning and directionality only**, not for housing chrome. Six unambiguous neighbors, no diagonal cheat. Panels stay rectangular.
- **Hex sizing is by rings from center** — 1, 7, 19, 37. Not powers of two. Same ring vocabulary already locked for the Earshot voiceprint mark.
- **Kinds are visually distinct.** Personas are low-poly humanoid robot meshes. Tools are machined housings with an icon faceplate and a nameplate. Processes are drawn — lines and nodes, not a body.
- **Tool naming is verb-then-noun.** Icon carries the verb, nameplate carries the noun.
- **The tool is named `muster mob`.** Verb muster, noun mob. Mob also names the unslotted broadcast behavior.
- **Interaction: tap opens the panel, press-and-hold toggles power.** Destructive action is the deliberate one.
- **Three power states for a bot:** unpowered (no key), awake and broadcasting, knocked out (keyed but silenced). Tap to silence, double-tap to knock out, visible nudge as feedback, knocked-out bot lies on the floor.
- **Unslotted bots hear everything on open canvas** and get packaged waves of board context at intervals; they answer whether you want it or not. Slotting a bot gives it specific context and quiets it.
- **The bench holds exactly three seats.** Not a UI limit — a scope check. Needing a fourth means you've drifted off the thing you sat down to do. Roster behind the bench grows in multiples of three.
- **Fourth slot on the bench panel is the spend meter** — session total plus per-slot current spend. Not a bot seat, so the discipline of three survives.
- **A bot is three fields plus token pointers.** Identity (persona file), knowledge (AGENTS.md-shaped project context), behavior (a list of processes it can run). Three plain text fields, paste markdown in, saved to JSON.
- **Slot three is a list, not a file.** Multiple processes per bot, readable on the info panel, added by dragging a process onto the bot.
- **Bot file holds token references, never keys.** Keys live in the token store. That's what makes a bot file shareable.
- **No UUID.** The repo is the identity — path plus commit history carries the version. Bot file carries the name only.
- **MCP covers tool capabilities.** No bespoke capability system. The three slots are only what a server can't provide.
- **Jury mode:** multiple tokens per bot, one flagged primary. Supporting models answer the same prompt, primary compares blind — shuffled A/B/C, selection tracked after. Opt-in, one token by default, cost multiplier shown plainly.
- **Context budget is a fill bar on the bot, not a cap.** Shows persona + skill file against the window. Crossing it turns it red; you can still cross it.

## Parked
- How a process gets drawn/authored on canvas — "draw your own process" capability floated, not designed.
- Cold open as a shippable pod — named as interesting because it's a method rather than a tool. Not specced.
- Working-memory bench zone (loose scratch area, fewer rules, push back up to commit) — raised, then explicitly pulled back from. Not settled.
- Header/canvas split (top ~20% fixed structure incl. timeline, bottom is loose flow) — stated, not locked. Fixed-not-scrollable was proposed and not ruled on.
- Cell-selection-defines-container (tap cells, boundary draws itself, lumpy is honest; point / line / triangle as the primitive set) — Seth stopped it as going too deep.
- Panel viewing angle — Diablo-style isometric floated for the bench and possibly wider interface. Tinkering, not decided.
- Icon design for muster mob — verb is "recruiting," sketch is a slot with a figure rising out of it. Not drawn.

## Asides (unjudged tips)
- "watch the different AI models fight it out on screen" — the debate as the demo, most legible way to show a newcomer what the tool is.
- Coin-slot iconography for tokens; arcade slot reads as an action, empty slot is the no-key state without a label.
- Baby Billy / Righteous Gemstones "silencio" sting on rage-clicking a bot into silence — synthesize a soundalike, do not lift the clip.
- "you're breaking the box" — on overloading a bot past its context.
- "that juggling action is doing. It's not a free action. It costs."
- Object-oriented UI (HyperCard, Smalltalk) is the named prior art for the pods approach.

## Inject
Landed: `artifacts/pods-spec/`, `specs/pods/`, six open issues, `rosters/tools/muster-mob/`. Hexagon whenever directionality matters. Icon at cell size still unnamed.

## Next question for him
What does the muster mob icon look like at cell size?
