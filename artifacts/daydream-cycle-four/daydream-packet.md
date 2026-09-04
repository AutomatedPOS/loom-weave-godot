# Daydream packet — Weaver PDCA cycle four

Talk only. Do not edit a repo. Do not pick a vendor. Do not bake a
key. Findings come back to the interface in `loom-weave-godot`,
filed at `artifacts/findings/`.

2026-09-04. Cycle four Plan exists: `talk`. This sitting is a long
lap on that Plan, not the Do. Owner is taking it to Claude for a
deeper run. The interface revises the Plan from what comes back,
then the Do runs.

Read with:

- `artifacts/cycle-four-plan/cycle-four-plan.md`
- `artifacts/cycle-three-plan/cycle-three-plan.md`
- `artifacts/slot-spec/slot-spec.md`
- `artifacts/findings/2026-09-04-cycle-three.md`
- `weave/Loadout.gd`
- `loom/PROCESS.md` if that repo is open

## The overlap

Once this packet comes back and the Do of `talk` starts, the owner
is not idle. Cycle five is generated in
`artifacts/daydream-cycle-five/daydream-packet.md` while four
executes. Do not start five's Do inside four. One cycle at a time
on the machine. The owner can write the next packet on the side.

```
seat codes four     owner reads four / writes five
four Act closes     five packet is already the thing to plan from
```

## Locked — do not reopen

- Render loop is PDCA. A spec is the plan step of a turn.
- First screen is black. Gear bottom-right, subdued gray, interface
  track.
- Loadout is how you point: chat, speech, hear. Each has endpoint,
  credential, model. Save on that browser. Export and import a file.
- Keys stay with the user. Save is `user://loadout.json` (this
  origin's storage on the web). Export is a local download. Import
  is a local file read. Deploy uploads `build/web` only. `user://`
  is never in the pck. A later request sends the credential from
  the browser to the endpoint the user typed. That is their host.
  Not `loom.dord.dev`. Not a commit.
- No vendor in the base. No key in the worker, the repo, or the
  export.
- Loadout look is parked. Owner is not happy with it. Do not spend
  the sitting redesigning chrome unless the owner rules a change.
- Weave is worker `dord-dev` on `loom.dord.dev`. Apex is DORD.
  No Pages.
- Do includes commit and push. Check is tablet refresh.
- Godot web wasm is served gzip once. Threads are off.
- Slot spec is done. Backdrop and interface are bookends. Content
  lives on slots.
- Apollo, tree cards, host-map, promote to `loom-weave`, schema
  edits in `loom-warp`: parked or waiting on a block.
- Three thumbs before a structural execution pass. Pain-32.

## Cycle four target

After the loadout is pointed, the window can chat, speak a reply,
and take speech in. A fresh deploy still has no secrets.

The workItem is `talk`.

## What already exists

- Live weave: `https://loom.dord.dev/`
- Gear opens the loadout. Three blocks. Save / Export / Import.
- Empty loadout: black screen and a gear. Same as cycle two.
- No HTTP to a model yet. No mic. No TTS. Cycle three stored
  pointers only.

## Owner still holds

The look of talk on the window. Where a conversation sits (interface
track, a slot, both). What a tablet Check must see or hear. How
generic a request can be without naming a vendor.

## Talk through

This is a long sitting. Stay on these. Write facts down. Do not
build.

1. **Where talk lives.** Chrome on the interface track, content on
   a slot, or both. The first screen is ruled black plus gear. A
   transcript is new. The slot spec says content cannot reach the
   interface. Say which track a conversation occupies, and why.

2. **What "a reply" is.** Last line, a scroll of turns, spoken
   only, spoken and shown. The tablet Check has to confirm it.
   Empty loadout must stay inert: black and a gear.

3. **The request without a vendor.** The loadout has endpoint,
   credential, model. Talk has to send something. What is the
   thinnest body that still works when the user points at
   whatever they have? Do not name a host. If the machine seats
   cannot settle the shape, write the question and stop.

4. **Speech and hear.** Loadout pointers versus whatever the
   browser already can do. Mic permission. TTS on Safari / iOS
   (this weave already hung a tablet on wasm once). Can hear
   work on the tablet Check at all.

5. **CORS and the browser.** Godot web calling the user's
   endpoint. What fails in the wild. Do not invent a proxy on
   `dord-dev` that holds keys. The key leaves the browser only
   toward the endpoint they typed.

6. **What else is local.** Chat history, audio blobs, error
   text. Same rule as the loadout: this browser or a file they
   keep. Not the worker. Not git.

7. **Failure.** No pointers. Bad endpoint. Offline. Timeout.
   What the window does, and what it must not do (no toast that
   leaks a key, no retry that sprays the credential).

8. **Check bar for a long Do.** One tablet refresh on
   `loom.dord.dev`. What must be visible or audible. What is
   enough to close Act. Do includes push; unpushed work is
   invisible.

9. **Cycle five, on the side only.** Once four's Do is running,
   fill `artifacts/daydream-cycle-five/daydream-packet.md`. Do
   not execute five. Do not open a second chew on the machine.

10. **Anything the slot spec or warp will not survive** once a
    live window is talking. Write it down. Do not patch warp
    from the talk.

## How findings come back

A short list. Fact, then what it hits: host, Godot, schema, or
process.

Bring it back to this repo. The interface files it under
`artifacts/findings/`. A hardened fact becomes an issue node. A
warp block is marked as a block, not a patch.

Then this seat revises `artifacts/cycle-four-plan/` from that
list and runs the Do. Meet in the middle: the packet is not the
execution.

## Do not

Build. Commit. Pick a vendor. Bake a key. Redesign the loadout
unless the owner rules it. Start the Do of `talk`. Start cycle
five. Describe talk as if it were already on screen.
