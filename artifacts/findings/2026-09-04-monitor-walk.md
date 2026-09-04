# Findings — monitor walk, 2026-09-04

Date: 2026-09-04. Seat: Grok, cloud agent
`bc-cac43192-0a08-4952-8d2e-c06eadc396e9`. Source: walk packet
"loom renderer, the monitor." Nighttime daydream. Not a PDCA cycle.
Owner sitting outside. First screen stays black.

## Bound from the walk

- The renderer **reads**. It does not write. Branching from a node
  is parked.
- Interaction this pass is **changing visualizations** only.
- **No timers.** The one allowed timer shape is a 24-hour catchall
  that resets on every real event.
- Refresh is still unpicked: post-commit hook, or a Cloudflare
  Worker that takes a GitHub push and fans it to the open page.
  Both live. Neither chosen.
- Memory ceiling is the browser. Target **2 GB max**, about 1 GB
  for accessibility/interface. A build-time checker that fails
  loud, not a discipline to remember. Path unnamed.
- RAG in-process is parked a couple revisions down. MiniLM-class
  is the floor; base-size still fits the ceiling.
- Screen: path spine on the **top** border (galaxy → repo →
  operation → iteration). Middle is the repo's own tree. Planned
  path is a ghost line; actual forks off. The fork is the thing
  being looked for.
- Purpose: Seth goes deep and loses breadth. The monitor keeps
  the trunk on screen.

Seth names the landing paths. This sitting does not mint a
`monitor/` node, a spec folder, or a memory-checker home.

## Where this sitting is

No duration number is on the nodes. loom-warp left **where the
iteration counter is recorded** OPEN. Do not invent one. Operations
do not get `plannedEnd`. "Which duration" is a path down, not a
count.

Path the monitor would show, from the trees as they stand:

```
galaxy          (not a node. four-repo left cross-repo pointers OPEN)
  loom          project, active. justDid still turn one; next still
                "Cycle two of the render loop." Stale against this
                weave.
    loom-weave-godot   operation, active, actualStart 2026-09-03
      cycle 3          loadout Do is live. This seat's Check on
                       loom.dord.dev passed. Owner tablet Check
                       still stands. Act has not closed.
      gear-panel       refinement beside cycle 3. No cycle number.
                       Tablet Check still stands.
```

Window: black field, gear bottom-right, loadout behind the gear.
Self-render cards are off the window since cycle two. That is why
the process is not visible.

Open under this operation:

- `loadout` — workItem, cycle-three Do
- `gear-panel` — workItem, refinement Do
- `do-includes-push` — issue, still the tablet rule
- `specs` — scopeItem
  - `specs-act-one` — parked storyboard
  - `specs-transmission-loop`
  - `specs-demo-seed`

Done: `self-render`, `first-screen`, slot spec, the three plans.

## What already exists for a later monitor Do

- `weave/TreeLoader.gd` — walks `thread.json` folders, parent map,
  depth. Cycle two left it in the repo when the cards came off.
  This sitting added `path_of`.
- `weave/ThreadCard.gd` — orphaned. Gear-panel findings already
  asked: delete, or keep for a later view. Still waiting.
- `scripts/pack_loom_data.py` — copies a loom checkout into
  `res://data/loom`.
- `scripts/where.py` — prints the path spine and open nodes from
  any tree root. No Godot. No window. This is the read-only
  report until a landing path is named.
- `workers/serve.mjs` — static asset serve for `dord-dev`. Not a
  push channel. No WebSocket. Workers Duration billing is not
  in play until a long-lived socket exists.
- Close-out prose already on nodes: `justDid`, `next`, `waitingOn`.
- Planned vs actual, as data: `plannedStart` / `plannedEnd` and
  `actualStart` / `actualEnd`. Abandoned / superseded nodes are
  how Apollo already draws a ghost. No new field for "ghost line."

## Gaps. Do not fill them here.

- Iteration counter. OPEN in warp. The spine's last segment has
  nothing to read.
- Galaxy collection. Repos are separate checkouts. `four-repo`
  consequences: cross-repo pointers remain OPEN. "Click a repo"
  has no pointer to follow.
- Learned / succeeded / failed as structured fields. Close-out
  is prose. Findings markdown is beside the tree, not on it.
- Refresh. Hook vs Worker still unpicked. Full re-read is fine
  at this node count.
- Memory checker. Wants a build-time home. Unnamed.
- Writing from the renderer. Parked.

## Not this sitting

- Nothing on the first screen.
- No schema edit in loom-warp.
- No deploy. Apex left alone.
- No pick on refresh.
- No second chew inside cycle three. This is a bind, not a turn.
