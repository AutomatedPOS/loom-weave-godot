# Cycle three plan

PDCA. This file is the Plan step of the third Weaver turn in
`loom-weave-godot`. It is not a spec of its own.

## Target

Give the window a loadout. The first screen stays black. The gear
opens configuration. Nothing LLM-shaped is in the base deploy.

Three capabilities, all optional, all user-set after load:

1. **Chat.** An LLM the interface can talk to.
2. **Speech.** TTS. The window can speak.
3. **Hear.** Transcription. The window can take speech in.

The user points each one at whatever they have. This plan does not
pick a vendor, a model, or a host.

The workItem is `loadout`.

## Persistence

Two stores. Both are the user's.

**On the machine.** After they configure, Save writes the loadout
where this browser can read it again. Refresh keeps it. That is the
daily path.

**In a file.** Export writes the same loadout to a file they can
keep. Import reads that file back. Wipe the browser data and the
on-machine copy is gone; the file is how they bring it back.

The deploy never contains keys, endpoints, or model names. A fresh
load with no save and no import is a black screen and a gear. Same
as cycle two.

## Why this cycle

Cycle two ruled the first screen and left the gear as chrome.
Owner named what the gear is for: attach LLM, TTS, and
transcription as configurable capabilities, not as a base install.

## Not this cycle

- Talking to a model. This Plan does not ship a chat.
- Picking OpenAI, Anthropic, a local runtime, or any other name.
- Slot occupancy, colours, centre object, frame, grid.
- The tree cards. Still off the window.
- Apollo hook. Still parked.
- Host-map changes. `dord.dev` and `loom.dord.dev` stay as named.
- Promote into `loom-weave`.
- Schema edits in `loom-warp`.
- Baking a key into the worker, the repo, or the export.

## Locked from earlier turns

- First screen is black. Gear bottom-right, subdued gray, interface
  track.
- Do includes commit and push. Check waits until the commit is on
  the remote. Issue `do-includes-push`.
- No Pages deploy. Weave is worker `dord-dev` on `loom.dord.dev`.
- Godot web wasm is served gzip once. Do not put
  `Content-Encoding` on the asset and let Workers gzip it again.

## Interface

This repo's operation seat is the interface for cycle three.

- Writes and checks every `thread.json`.
- Files findings in `artifacts/findings/`.
- The Do, when it runs, commits and pushes before Check.
- Owner reviews from a tablet. Refresh on `loom.dord.dev` is the
  Check.

## Success bar

This sitting is Plan only. It passes when the plan is on the remote
and the Act of cycle two is closed.

The later Do passes when:

- A fresh deploy has no chat, no TTS, no transcription, no secrets.
- The gear opens a place to set those three, then Save.
- Save survives refresh on that browser.
- Export writes a loadout file. Import restores it after a wipe.
- Clearing browser data forgets the on-machine copy.

A baked-in key, a vendor hardcoded in the export, or a first screen
that is no longer black is a fail.

## After

Act closed 2026-09-04: owner merged PR #7 and called Check fine.
Cycle four Plan is talk. The loadout look is parked.
