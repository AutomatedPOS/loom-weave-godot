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

### 2026-09-04 — Paste does not work

Owner cannot paste an API key into the loadout on the live
weave. That was the intent of this cycle. No JS clipboard
path. Issue `credential-paste`. Fix is in the Cloud Code
handoff, not this seat.

### 2026-09-04 — Paste works on the local web build

Seat: Claude, cloud session, on the interface handoff branch. Godot
cancels the browser's paste on keydown, so Ctrl/Cmd+V never raised a
paste event and the web LineEdit pasted a stale copy. Now a keydown
listener in the page reads the clipboard inside that gesture, a
pointerup listener reads it inside a tap on the new Paste button,
and the built-in paste action is dropped on web. Text lands in the
focused field, else the first empty credential. Secret fields take
it. Status says `pasted. Save to keep it on this browser.` and never
the text. Verified in Chromium 1194 on a local COOP/COEP serve of
`build/web`: Ctrl+V into chat credential, a second Ctrl+V with no
double paste, Paste into a focused field at the caret, Paste with
no focus, Save then hard reload with the key shared to speech and
hear, and a touch tap on Paste with no keyboard. Safari is not on
this seat; the read happens inside the browser's own gesture, which
is the shape Safari asks for, and a refusal shows as
`paste blocked by the browser`. Owner tablet Check still stands.

### 2026-09-04 — Tablet IME overlay

Do of `tablet-credential-keyboard`. Canvas LineEdit selects
and does not open Chrome's keyboard. A page `<input>` is
placed on the field in the same tap, 16px type, password
when the field is secret. Text syncs back. Nothing logs
the key. Desktop native unchanged. Check is a tablet tap.
