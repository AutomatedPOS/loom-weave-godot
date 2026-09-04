# Walk packet — 2026-09-04 — loom renderer, the monitor

## What this walk was

Open-ended nighttime daydream. Pointed the loom renderer at loom itself: a read-only
monitor Seth can look at while working, so he can see where he is without losing the
breadth of what he's in. Started at "click a repo, see its operations" and ended on
the two-structure screen layout.

---

## Decided

### What the view has to do

- Click into the galaxy (the loom collection of repos), then into a repo, then see
  what operations are running in it.
- Per operation: which iteration it's on, what succeeded, what failed, what was
  learned.
- Then down again — where inside the current step of a subplan. Renderer iterations
  nest, so "where you are" is a path down, not a single number.
- Click a past node and get what happened there: what was done, what was decided,
  do you need more detail. The node's session hangs off it in the tree already —
  position is the link. No extra pointer needed.
- Purpose, stated plainly: Seth goes deep on one topic and loses the breadth of the
  process. The monitor is the thing that keeps him grounded.

### Read-only, for now

- The renderer **reads**. It does not write.
- The only interaction this pass is **changing visualizations**.
- Branching from a node while looking at it is **a bridge too far right now** —
  that turns a reporting tool into an interactive interface and opens a new problem
  set. The way still starts and finishes via LLMs.

### Refresh

- **No timers.** Timers stack, they're expensive and wasteful. The one allowed timer
  shape is a 24-hour catchall that resets on every real event.
- Two live options, both acceptable:
  1. **Post-commit hook** — Seth is the one committing, so the commit tells the app
     directly. No polling, no waiting.
  2. **Cloudflare Worker** — sits at a URL, GitHub posts to it on push, it pushes the
     change down to the open page. Not a runner; an always-on edge function.
- Cost: free tier is 100k requests/day (never touched). The long-lived socket counts
  as duration and needs the paid plan — $5/mo. Short posts stay free.
- GitHub side needs a **read-only token** for the state.

### Memory budget

- Ceiling is the browser, not the desktop. Godot in wasm caps around **2–4 GB total**.
- Target: **2 GB max**, roughly **1 GB for accessibility/interface**, rest user space.
- It's a **target to avoid**, not a budget to spend — a build-time checker that
  measures loaded footprint and fails loud when it crosses. Not a discipline to
  remember.
- Model and rag index are fixed measurable costs. Accessibility is the half that
  grows quietly — that's the one to guard.

### RAG in-process

- Index is small: thousands of chunks with embeddings is tens of MB. Transcripts plus
  repo docs land well under a gigabyte. Loads into Godot memory without noticing.
- Query-time embedding is the part that isn't free — the question has to become a
  vector before it can be compared.
- **MiniLM-class** (~22M params, ~90 MB, CPU, milliseconds) is the floor. Below that,
  retrieval starts matching on shared words instead of shared meaning.
- **Base-size** (~110M params, ~400 MB) is meaningfully better at meaning-over-wording
  and still cheap against the 2 GB ceiling.

### Screen layout

- **Top border: the path spine.** Galaxy → repo → operation → iteration. Grows as you
  go in, always visible, how you get back out. Top not bottom — it's a header, not a
  pile.
- **Middle: the repo's own tree.** Two different structures on one screen.
- Diagram style: the classic left-to-right chain, modernized. Each step blooms open
  into its own chain beneath it — the substations.
- **Deviation:** the planned path draws as a ghost line that keeps going; the actual
  path forks off and continues elsewhere. The fork point is the thing being looked for.

---

## Parked

- **Writing from the renderer** — branching from a node, any authoring. Explicitly a
  bridge too far this pass.
- **Which refresh mechanism** — post-commit hook vs. Cloudflare Worker. Both live,
  neither picked.
- **Pulling from a rag** in the interface — "a couple revisions down the line."
- **Diffing vs. full re-read** on refresh. Full re-read is fine at 33 nodes; only
  matters when the galaxy holds every repo.

---

## Asides (unjudged)

- "It happened today" — went deep, lost breadth, screwed himself. That's the origin
  of the whole monitor idea.
- Research on ADHD visualizations came back mostly kanban and mind maps. The one real
  match is the **Discovery Tree** — visible tree, every branch is work, collapse what
  you're not in, trunk stays on screen so breadth never disappears. None of them do
  the "click a past node, see what happened, branch from there" half; that's a version
  tree, not a task tree.

---

## Inject

Landed: `monitor/`, `plans/monitor/`, `artifacts/monitor-plan/`,
`weave/Monitor.gd`. Memory checker still unnamed. Refresh still
unpicked.

---

## Next question for him

Post-commit hook or Cloudflare Worker. Not this handoff.
