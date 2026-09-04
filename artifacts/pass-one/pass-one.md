# Pass 1 — Acceptance Criteria

**Status:** open
**Owner:** Seth
**Implementer:** Grok
**Definition:** this pass is done when both tests below pass,
unassisted, twice in a row.

## Scope of this pass

The whole interface, end to end, at its thinnest possible width:

1. User lands on a black screen with a gear icon, bottom of screen.
2. Gear opens the settings panel. User imports a key file (or enters
   keys manually).
3. Panel validates each capability and reports status visually.
4. Panel minimizes. If all capabilities are green, the chat window
   appears.
5. Chat window: minimize / maximize, mic button, push-to-talk **or**
   always-on toggle, mute-output toggle.
6. While transmitting: live waveform indicator, and a speech bubble
   populating with transcribed text as the user speaks.
7. Transcript goes to the LLM. Response comes back as text in the
   window **and** as speech over the speakers (unless muted).

## Test A — Round trip

Speak a question. Within **30 seconds**, the system responds by voice
with an on-topic answer to that question, and the displayed transcript
of what was said is materially accurate.

Pass/fail. No partial credit.

## Test B — Live theme change

Speak a request to change the background color. The running interface
repaints to the requested color without a page reload, and the
resulting theme passes contrast validation.

Pass/fail.

## Key validation — behavior

Validate **each capability separately**. One key may cover all three,
or they may be different providers.

| Capability | Validation method |
|---|---|
| Chat / completion | Fire a real 1-token completion. Time it. |
| Speech-to-text | Submit a short fixed audio sample. |
| Text-to-speech | Synthesize a short fixed string. |

**Do not** validate by pinging the provider or checking key format.
A key can be well-formed, authenticated, and still out of credit.
Only a real billed call proves the capability works.

Each capability reports one of: **green** (working), **red** (failed,
with reason), **grey** (not yet tested).

## System messages

Application errors surface in the chat window as **system messages**
— visually distinct from AI messages. Different color, no avatar,
italic. The user must never confuse "the app failed" with "the AI
said something odd."

Cases to cover:

- Out of credit / quota exceeded
- Invalid or revoked key
- Network unreachable / offline
- Provider timeout
- Mid-conversation failure (key dies or connection drops after a
  working session)

Every one of these needs a visible terminal state in the chat window.
Never an indefinite spinner.

## Explicitly out of scope for this pass

- Per-session spend caps and kill switch — **not needed.** Audience
  is one trusted person, keys are in an external file shared
  directly, not in game files.
- MCP layer — see backlog. This pass uses one hardcoded tool call
  plus current theme in the system prompt.
- Chat history persistence — chat is **ephemeral**. Refresh clears
  it. If the user wants a transcript, that's on them.
- Git integration — see backlog.
