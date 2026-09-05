# Canvas plumbing

Everything under the surface that has to exist before a pixel
means anything. The canvas spec is the composition model. This
file is the contract the rails, the pipe, the shape, and the
timeline refill keep.

The renderer reads. Nothing here writes to the tree.

## Rosters

Three parents in the tree. Their children are the rails.

| Rail | Parent guid | Parent path |
|---|---|---|
| personas | `e02bd852-910d-4d39-9f62-c37c1440610f` | `rosters/personas/` |
| processes | `e498b6ff-9124-4888-926b-146b2367c676` | `rosters/processes/` |
| tools | `e0fcf2b0-4162-43ce-bbfd-c3b0ed1d5e17` | `rosters/tools/` |

A rail item is a child of its parent. Address is the child's
`guid`. Path is for humans. A shape stores the guid.

The parent carries `props` `roster` = `personas` | `processes` |
`tools`. Each child carries `props` `rail` with the same value.
That is how a walker finds a roster without hard-coding a folder
name.

A rail item is not consumed by being pulled. The roster node stays.
Pulling copies a reference, not the node.

### Personas

The ones that exist:

| Name | guid | path |
|---|---|---|
| Brains | `13bc00fd-1276-498d-9b35-c2980c5fd10f` | `rosters/personas/brains/` |
| Archivus | `5d035f1a-b5d3-41fb-a215-e4489eda77e5` | `rosters/personas/archivus/` |
| Fixer | `43be09cf-704d-40a8-9653-c7bb1e196b64` | `rosters/personas/fixer/` |

Brains is the owner's right hand. The other two are named only.
No voice sheet, no inbox URL. Those would be guesses.

Type is `scopeItem`. A persona is standing catalogue, not a piece
of work that starts and ends. `actualStart` is the day it entered
the tree.

### Processes

The owner named one verb: brief. That is the only process child.

| Name | guid | path | kind |
|---|---|---|---|
| brief | `4a5e6c6b-60bc-423f-8342-010fa057346d` | `rosters/processes/brief/` | actionable |

`kind` is a prop. Values from the primitives reading:
`instructional` | `actionable`. `brief` is actionable: it runs
against an object. Instruction arrives by attaching a persona.

No other process is invented. WALK, CLOSE, and any other rail
label a painter needs is a drawing, not a node.

### Tools

The parent exists. It has no children. The owner did not name a
tool. An empty roster is a valid source.

### How a roster is read at time T

Children of the parent whose interval has begun by T. Same rule
as any other refill. A persona added next month does not appear on
a shape opened at last week's date.

## Persona pipe

A rail item becomes a live thing when it is bound. Endpoints
already live in the loadout (`chat`, `speech`, `hear`). The
binding does not.

```
bind(persona_guid, loadout) -> Binding | Unbound
```

- Look up the guid on the personas roster. Missing guid is
  Unbound.
- `chat.endpoint` must be set. Empty endpoint is Unbound. The pipe
  does not pick a host.
- Binding holds `{ persona, cap: "chat" }`. It does not hold the
  endpoint URL, the model name, or the credential.
- Speech and hear are optional. They attach to the same Binding
  when those endpoints are set. They are still not copied into the
  Binding that a shape could see.
- The credential is read from the loadout at tap time, used, and
  not stored. It never enters a shape, a finding, a log, or the
  tree.
- Session is RAM. Discarding the window drops it. Restoring a
  shape re-binds from the guid and the current loadout. The talk
  is gone. That is shape-not-data, applied to talk. The canvas
  does not write a transcript into the tree; spec OPEN later if
  talk must persist.
- Inbox routing to the bot network is OPEN. The address format is
  not in this repo. Do not mint a URL. The local face of the pipe
  is the loadout. The remote inbox waits on a format with no
  secret in it.

Tap talks to a bound Binding. Drag attaches. That split is spec
OPEN 4; plumbing holds it as a reading.

No HTTP client. No vendor. Cycle three parked talking to a model.
This pipe is the missing bind, not the chat.

## Attachment

The only composition operator.

An attachment is a pair of references. It is not a copy of either
side.

```
{
  "from": { "kind": "roster", "guid": "<rail item>" },
  "onto": { "kind": "window", "id": "<shape-local id>" }
}
```

`from.kind` is `roster` or `window`. `onto.kind` is `window`.
Window onto window is how a composed thing is dropped onto
another. Roster onto window is persona, process, or tool onto
the thing in that window. The rail of the roster guid is the
type of the attachment; there is no second type field.

Window ids are shape-local (`field`, `w1`, …). They are not
tree guids. Roster guids are tree guids. Mixing them is a fail.

Forbidden in an attachment: body, children, transcript, session,
credential, node snapshot, endpoint.

The field is a window with id `field`. Every other window attaches
onto some window, eventually onto `field`. No depth limit.

A rail item referenced from two windows is two attachments of the
same guid. The roster is still not consumed.

## Shape store

A saved shape is a query. Version 1, allowlisted.

```
{
  "v": 1,
  "kind": "shape",
  "as_of": "now",
  "windows": [
    {
      "id": "field",
      "slot": 0,
      "ask": { "kind": "none" }
    },
    {
      "id": "w1",
      "slot": 0,
      "ask": { "kind": "node", "guid": "<tree guid>" }
    }
  ],
  "attachments": [
    {
      "from": { "kind": "roster", "guid": "<persona>" },
      "onto": { "kind": "window", "id": "w1" }
    }
  ]
}
```

Allowed keys, and only these:

- shape: `v`, `kind`, `as_of`, `windows`, `attachments`
- window: `id`, `slot`, `ask`
- ask: `kind`, and then `guid` or `rail` as the kind needs
- attachment: `from`, `onto`
- ref: `kind`, `guid` or `id`

`as_of` is a query parameter, not a snapshot. `"now"` means the
current timeline position at refill. A UTC date `YYYY-MM-DD` is
allowed. A datetime is allowed and is read as its UTC day.

Ask kinds:

| kind | extra | what refill reads |
|---|---|---|
| `none` | — | empty pane |
| `node` | `guid` | that node, if present at T |
| `kids` | `guid` | children of that guid, present at T |
| `path` | `guid` | ancestors of that guid, present at T |
| `roster` | `rail` | children of that roster parent, present at T |
| `pdca` | — | open workItems with a `pdca` prop, present at T |

Any other key on a shape is a fail. In particular: `body`,
`justDid`, `next`, `waitingOn`, `nodes`, `children`, `transcript`,
`messages`, `session`, `credential`, `endpoint`, `model`.

Persistence reuses cycle three's two stores, for shapes, not for
loadout:

- On the machine: `user://shapes/current.json` in the Godot app.
  `weave/Shape.gd` is the allowlist. The canvas keeps the query
  when the seat moves or a chip docks or leaves.
- In a file: export of that JSON waits on OPEN 3. No port is
  labelled. The dumps path already exists.

The tree is not a shape store. A shape is not a `thread.json`.

Refill output is RAM. It is what a pane shows. It is never
written back into the shape.

## Timeline

Not a new data structure. The dated fields already on every node
are the axis. The timeline is that axis, made grabbable. The clock
reads the current T, which is not always now.

T is a UTC day. Nodes carry `actualStart`, `actualEnd`,
`plannedStart`, `plannedEnd`, `decidedDate`, all `YYYY-MM-DD`.
Hours and minutes on the control do not change the read. A refill
at 14:00 on a day is the same refill as 09:00 on that day. Closing
that wants a time field. Do not invent one. Same class of hole as
the iteration counter, OPEN in loom-warp.

### What a refill at T actually reads

Let `day` be the UTC calendar day of T.

A node has **begun** by `day` when any of these is true:

- `actualStart` is set and `actualStart <= day`
- `actualStart` is missing, `actualEnd` is set, and
  `actualEnd <= day` (artifact: the snapshot existed that day)
- `decidedDate` is set and `decidedDate <= day`

A node that has not begun is absent at T, unless it is a ghost.

A node is **ghost** at T when it has not begun, and:

- it has no dates at all (the plan that keeps going), or
- `plannedStart` is set and `plannedStart <= day`, and
  `plannedEnd` is missing or `plannedEnd >= day`

Ghosts may be drawn. They are not lived. An ask of kind `node`
for a ghost guid still resolves; the refill marks `ghost: true`.
An ask that lists a roster or kids does not include a node that
has not begun and is not ghost.

`actualEnd` does not hide a node. Nothing is deleted. A done
workItem that ended before T is still in the tree and still in
the picture. Scrubbing to T shows what had begun by then,
including what had already finished.

Superseded and abandoned stay. There is no superseded-on date.
Do not invent one. State is read off the node as it is.

Decision in force at T: `decidedDate <= day`. A later decision
that `supersedes` it is in force instead when that later
`decidedDate <= day`.

Undated nodes cannot be placed in time. They are ghost at every
T. Do not use git history as a substitute date.

The monitor's trail (dated stations in date order) is the same
axis. The timeline grabs it. The refill uses it. One read.

## OPEN

From the canvas spec, still open, not guessed:

3. Port count and meaning. Candidates from what already exists:
   save (browser), export (file), discard (named in the spec).
4. Tap versus drag.
5. Rails always visible or summoned.

From this sitting, also open:

- Bot-network inbox address format for the three personas.
- Authored processes besides `brief`.
- Any tool at all.
- Time of day on the timeline.
- Whether talk must persist. Under the current rule it does not:
  the canvas does not write, and a shape does not carry a
  transcript.

## What this does not change

`weave/` look is Fable. Shape store plumbing in `weave/Shape.gd`
and `Canvas.gd` is Grok, and it does not restyle. Backdrop, gear,
tokens, loadout stay. No vendor names. No secrets. No deploy.
Ports stay unlabeled.
