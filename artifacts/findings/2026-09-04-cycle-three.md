# Findings — render cycle three

Date: 2026-09-04. Seat: Grok, cloud agent
`bc-b695c0af-ad0c-4862-80d4-8989c1c779fe`. Owner sitting outside.
No desktop. Check is tablet refresh on `loom.dord.dev`.

## Beats

### 2026-09-04 — Do started from the parked plan

Cycle two already wrote `artifacts/cycle-three-plan/` and said Do
waits. This sitting is that Do. WorkItem `loadout`. No vendor. No
chat shipped.

### 2026-09-04 — Gear opens the three

Chat, speech, hear. Each has endpoint, credential, model. Save
writes `user://loadout.json`. Export writes `loadout.json`. Import
reads it back. Bad JSON is rejected. Fresh load is still black plus
the gear.

### 2026-09-04 — Control did not take the tap

A `Control` with `_gui_input` drew the cog and did not open the
panel. Main, a full-screen Control, was also eating clicks.
Gear is now a flat `Button`. Main `mouse_filter` is ignore.

### 2026-09-04 — Buttons above the fold

Save, Export, Import sit under the title so a tablet reaches them
without a scroll.

### 2026-09-04 — Live weave uploaded

`./deploy-weave.sh` uploaded worker `dord-dev`. Version
`4d4b2cb2`. Apex left alone. Hard refresh on `loom.dord.dev` is
the Check.

### 2026-09-04 — Seat Check on the live weave

This seat opened `https://loom.dord.dev/`. Black field, gear
bottom-right, no cards, no bar, no chat. Gear opened the loadout.
Dummy chat endpoint and model saved. Hard refresh kept them. No
vendor on screen. Owner tablet Check still stands.

### 2026-09-04 — Act closed

Owner merged PR #7. Check fine. Not happy with the loadout look.
Parked. Next named: talk. Chat, speech, TTS, transcription. Keys
stay on the browser and in the user's export file. Never in the
worker. Never in a commit unless they put that file in the repo
themselves.

### 2026-09-04 — Keys do not leave the machine

Save is `user://loadout.json` (this origin's storage on web).
Export is a local download. Import is a local file read. Deploy
uploads `build/web` only. The pck never contains `user://`.
