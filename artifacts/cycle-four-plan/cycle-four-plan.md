# Cycle four plan

PDCA. This file is the Plan step of the fourth Weaver turn in
`loom-weave-godot`. It is not a spec of its own.

## Target

Make the loadout work. Cycle three stored pointers. This cycle
uses them.

After the user has pointed chat, speech, and hear, the window can:

1. **Chat.** Send text to the chat endpoint and show a reply.
2. **Speech.** Speak. TTS from the speech pointer.
3. **Hear.** Take speech in. Transcription from the hear pointer.

The workItem is `talk`.

The first screen stays black plus the gear. The loadout stays the
place you point. This cycle does not redesign that panel.

## Persistence — locked

Keys, endpoints, and models stay with the user.

- Save writes `user://loadout.json` on that browser. On the web
  export that is this origin's storage, not the worker, not git.
- Export writes a file on their machine. Import reads that file
  on their machine.
- Deploy uploads `build/web` only. `user://` is never in the pck.
- A later request will send the credential from the browser to
  the endpoint the user typed. That is their host. Not
  `loom.dord.dev`. Not a commit.

A key in the repo, the worker, or the export is a fail.

## Why this cycle

Owner closed cycle three Act. Named next: get chat and speech
working, TTS, transcription. Asked first whether keys stay local.
They do. This plan keeps that.

## Not this cycle

- Picking a vendor.
- Baking a key into the worker, the repo, or the export.
- Redesigning the loadout panel. Owner is not happy with the
  look. Parked. Do not spend the turn on chrome.
- Slot occupancy, tree cards, Apollo, host-map changes.
- Promote into `loom-weave`. Schema edits in `loom-warp`.

## Locked from earlier turns

- First screen is black. Gear bottom-right, subdued gray.
- Loadout fields: endpoint, credential, model. Chat, speech, hear.
- Do includes commit and push. Check waits until the commit is
  on the remote. Issue `do-includes-push`.
- No Pages deploy. Weave is worker `dord-dev` on `loom.dord.dev`.
- Godot web wasm is served gzip once.

## Interface

This repo's operation seat is the interface for cycle four.

- Writes and checks every `thread.json`.
- Files findings in `artifacts/findings/`.
- The Do, when it runs, commits and pushes before Check.
- Owner reviews from a tablet. Refresh on `loom.dord.dev` is the
  Check.

## Success bar

This sitting is Plan only. It passes when the plan is on the remote
and the Act of cycle three is closed.

The later Do passes when a user who has pointed the loadout can
chat, hear a reply spoken, and speak a line in, and a fresh deploy
still has no secrets.

## After

Daydream packet is `artifacts/daydream-cycle-four/`. Owner talks
it with Claude. Findings come back here. This Plan is revised,
then Do of `talk` runs. Cycle five is generated on the side in
`artifacts/daydream-cycle-five/` once that Do starts.
