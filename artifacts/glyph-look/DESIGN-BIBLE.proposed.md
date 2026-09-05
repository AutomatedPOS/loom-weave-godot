# Loom — design bible

Tier one. Filed at the loom root. Version one, 2026-09-04.
Not a company product.

S1–S5 closed 2026-09-04. S6 is verify. Signature is S6.

Sight-explore material (4.1, 4.4, 4.6, the manifest reading, field
fifteen resolution) was **not returned** in the confirmation pass. It
is carried into this lock **unverified**, at the owner's instruction.

`## Parked` at the foot is working-file scaffolding. It is not a
bible section. It comes off before S7 files.

---

## 1. Charter

- **title** — Loom. Governs the project as a whole. Filed at the root, not under loom-weave.
- **tagline** — Time is infinite. Yours isn't.
- **pitch** — Loom lets you operate outside your head. It renders what would otherwise sit in working memory as a visual structure you can look at, move through, and act from. It's built on a bet about where interfaces are going: as graphics headroom becomes universal and AI absorbs the presentation layer, the way people work with systems shifts from typing toward the verbal and the visual. Loom draws on processes and tools, and the work moves in iterative loops. Status reporting falls out of it as a byproduct, not as the goal.
- **pillars** — four, tie-breakers, not slogans:
  1. Hold nothing in your head that the screen can hold for you.
  2. Short loops. Laps are unlimited in theory and limited in a life, so the cost of a lap decides what can be built.
  3. Reaction beats specification. Get a rough one in front of the owner and let him say what is wrong with it.
  4. Crisp.

  Not pillars: recursion, branching, and iteration are the model, not tie-breakers. Reuse-once-proven is a standing render-loop rule and will land as a content rule with do and don't examples, not as a pillar.
- **surface_type** — a render surface family. One tree, many surfaces. Each surface gets its own tier-two bible beneath this one. Nothing engine-specific belongs in this document.
- **senses_engaged** — sight and hearing at tier one. Touch is tier two, per surface.
- **technical_ceiling** — runs in a browser; roughly two gigabytes of working memory; readable and reviewable on a tablet. This is the floor every surface must clear.
- **stylistic_ceiling** — the pictogram grammar:
  - one glyph per fixed square tile
  - state carried as a fill variant, not a second glyph
  - an explicit null tile for nothing-here
  - hazard as a modifier applied to a noun
  - two glyph classes: nouns and imperatives
  - composed left to right as a manifest
  - sequence position kept outside the glyph grid
- **out_of_scope** — three things:
  1. The writer tool. The renderer reads and never writes; whatever writes is a separate tool, not yet built, and wanted.
  2. Engine-specific look. That is tier two.
  3. Glyph artwork production. The grammar and references stay in; the drawing does not. The bible is the brief that gets handed off.
- **target_platforms** — any platform that can run a browser, Chromium as the reference. Apple surfaces explicitly not targeted. Native and other engines are tier two.
- **target_audience** — built for one, given away. Anyone running complex work who is losing track of it. Not enterprise, not teams. Deliberately not narrowed further.
- **competitor_differentiation** — there is barely any software to buy. The tree is text in your own repo, the renderer is a swappable viewer, the intelligence is whatever model you point at it. Nothing owns your work.
- **ownership** — sole owner. MIT. Given away free with attribution. Owner is the final gate on this document.
- **review_cadence** — annual. Changes will force it open sooner: any change to a filed bible restarts S1, non-negotiable.
- **starting_genre_profile** — black field, white and grayscale marks, three accents drawn from a colour-blind-safe set, and the accents are swappable — whoever runs it picks their three. Orange is out. It is too close to the game the pictogram grammar comes from. This reverses the one-accent rule from cycle two.

  Challenged 2026-09-04 as a placeholder. Sustained without amendment: derived from mood-board reference 1 (white glyphs on a dark sign face, accent spare; orange is the source palette). No restart. Carried unverified with the sight-explore packet.
- **compliance** — accessibility. Colour-blind-safe accents and readable contrast on black. No data-privacy exposure, since nothing personal goes in the tree.
- **document_tier** — tier one, filed at the loom root. Tier-two bibles cascade beneath it, one per surface.
- **version_history** — version one. First walk, 2026-09-04.
- **signature** —

---

## 2. Core loop

- **loop_description** — On arrival the field finds the one thing that is yours (beat one: *where am I*). Horizontal is time. Work forms in the water and commits upward into structure. An instance in the middle runs against a plan pulled down from the sky.
- **loop_emotional_arc** — ADSR. Attack is *where am I*. Down is where things form; up is where they are committed.

---

## 3. Mood boards

### References

1. **Portal chamber info icons.** Valve. Source: Portal Wiki, `Category:Chamber_info_icons`.

   What it supplies: the pictogram grammar already stated in charter field eight — one glyph per fixed square tile, nouns and imperatives as the two classes, hazard as a modifier applied to a noun, composed left to right as a manifest.

   This names in the document what field eight had only described. It also gives field fifteen its reason: orange is out because that is the palette of the source. Take the grammar, not the costume.

   Chamber signage as a **manifest of empty shells that get populated** — the sign states what the room contains and what you will need, as a slot list before it is a picture. A process step reads the same way. *(Manifest reading: sight-explore, unverified.)*

   - **source_note** — grammar studied, no assets used, third-party IP acknowledged.

2. **Commercial vector pack of the same marks.** Source: third-party Etsy listing reproducing Valve logos and pictograms.

   Logged as territory only. No assets from it are used. Distinct in kind from reference 1: studying a grammar is not the same as pulling artwork out of a commercial pack into an MIT project given away free. Out-of-scope item three already keeps glyph artwork production outside this bible.

   - **source_note** — grammar studied, no assets used, third-party IP acknowledged.

3. **Comic-interruption tone.** Source: a short-form video clip, *The Earliest Show*.

   What it supplies: the posture of the interface at arrival. Not sound design, not visual treatment. The register of cutting in to get context — impatient, comic, mildly rude, not reverent.

   Maps to the attack stage of the ADSR envelope and to beat one of the loop, *where am I*.

   - **source_note** — tone and posture studied. No assets copied.

**Superseded:** typing locked at first run and tuned as a joke. Same instinct, better mechanism: typing is band-gated (5.1). The joke version was never a real rule.

---

## 4. Sight

- name
- receptor
- stimulus
- modality
- designer_intent
- target_audience_response
- reconciliation_rule
- congruence_relationship — hearing's congruence is declared against sight; sight before hearing
- accessibility_floor

### Rules

Each rule carries: rule_text, do_examples, dont_examples, rationale, machine_value.

The field has **three bands**, not two.

- **Sky, top.** The fixed things: principles, guardrails, standards, processes. Definitions. Built out of the water, but once up there they are permanent and above the work. Timeless.
- **Middle.** Where operations live. An instance runs here against a plan pulled down from the sky. A plan can also be placed here purely to be inspected without being run. Sits at a moment.
- **Water, bottom.** Where things form. Unstructured, moving, no edges. Now.

Time is independent. The timeline is owned by no band. It spans all three.

**Weight carries importance**, not certainty. Bolder reads as matters-more, which is how weight already works everywhere else and therefore needs no learning. Importance is re-evaluated as the day moves. The owner accepts, deliberately, that the screen decides what matters and redraws it. Named as the help wanted: attention drifts onto tangents that are worthwhile in themselves, and something has to pull it back.

Channel budget, spent: outer shape (type and firmness); silhouette round/square (human vs machine); fill (state); weight (importance); field position (rigid vs soft); accent 1 hazard; accent 2 current task; accent 3 changed-since; grayscale value + internal detail (persona differentiation). Nothing left to hand out. No channel may carry two meanings.

Nothing in the rigid half exists that did not come from the soft half. Structure is downstream of thought. The two modes (structured vs dreaming) have two places on one screen. The owner moves his own eye. Loom never has to guess which mode he is in. Eye moves down for soft, up for structure, then right along the process flow.

#### 4.1 The field

⚠ Carried unverified (sight-explore packet not returned).

- **rule_text** — Black is not a background colour; it is the absence of content. Anything drawn is asserting something is there. Nothing is drawn to fill space, frame, or decorate. In light mode the field is white, and white is absence there exactly as black is in dark.
- **do_examples** — The residue of the owner's own voice in the water is evidence of what has been said, not decoration.
- **dont_examples** — Drawing to fill space, frame, or decorate.
- **rationale** — Pillar one: the screen only holds things for you if everything on it means something.
- **machine_value** — dark_field=#000000; light_field=#FFFFFF; field_is_absence=true

#### 4.2 Accents

Numbering is the palette register. Precedence is what wins on a tile. Those are different orders on purpose.

- **rule_text** — Three accents. Accent one: **hazard** — something is wrong, broken, warning. Accent two: **current task** — glowing, with a pulse or ripple. Meaning: look here and nowhere else. A position marker, not a command. Accent three: **changed since you last looked** — italicised. Explicitly the nice-to-have of the three; the other two are must-haves.
- **do_examples** — Hazard reserved; nothing else may use it. Current task reads look here and nowhere else.
- **dont_examples** — Rendering current task as *act now*. Spending a colour on blocked/waiting-on when `waitingOn` already reads it.
- **rationale** — Blocked is already readable from `waitingOn`. The diff serves the drift-and-return pattern the screen exists to help with.
- **machine_value** — accent_1=hazard #8B1E1E / #8B1E1E; accent_2=current_task #D99A1F / #A06E10; accent_3=changed_since #6B8FAE / #4F7291. Dark / light. Hazard keeps one value; task and changed pull down on white so they read; hue holds. Colour-blind-safe set, swappable. Orange is out. Contrast is against each mode's field.

#### 4.3 The glyph tile

Closed as drafted. It was never in trouble. The re-open was the set dresser's, not the owner's.

- **rule_text** — Two frames. Outer shape says where it fits: borrowed, never invented (BPMN and standard flowchart forms), carrying type and firmness — squared for settled, cloud for still forming. Inner glyph says what it is and is a swappable skin. Fill carries state. Silhouette separates human from machine, round versus boxy. As drawn: persona is the avatar circle with a human skin (sphere on a closed capsule, neck is the gap) or a robot skin (cube on cube, visor slot, stub antenna). Process is the flowchart rectangle with three stations on a rod; the spine reads only in the gaps. Tool is the flowchart predefined-process rectangle (double bars) with an open-end spanner. A diamond is a decision in that vocabulary and is not a tool.
- **do_examples** — A persona drawn as a man, a woman, a dragon, an animal — the slot in the grammar does not change. Human and robot share the circle; the silhouette channel says who.
- **dont_examples** — Inventing a new shape. A diamond for a tool.
- **rationale** — Internationally understood vocabulary. Structure fixed, skin the user's. Same pattern as swappable accents, applied to marks.
- **machine_value** — tile=64; stroke=2; skin_box=16,16 32x32; persona_frame=circle r 28; process_frame=rect 4,10 56x44; tool_frame=that rect plus bars at x 11 and x 53; skins=human,robot,process,tool; human=sphere+capsule; robot=cube+cube+visor+stub_antenna; process=three_stations_on_rod; tool=open_end_spanner; diamond=retired

Round is human, square is machine. Human voice renders as a wave (oscilloscope form, rounded, varying) in the water. Synthesised voice renders as a square wave (hard on, hard off) up top, where the process is. The machine speaks about the plan; it has no formation space. Standing principle for marks not yet designed, with no exceptions. Film *Up* character-design attribution is unverified; do not file it as sourced.

#### 4.4 Glyph classes

⚠ Carried unverified (sight-explore packet not returned).

- **rule_text** — Two classes hold: nouns and imperatives (field eight unrevised). Three noun subclasses: personas, processes, tools. Additive, not a reversal. How the tree's other node types render (issue, risk, workItem, scopeItem) is already answered by the imperatives class and the modifiers. No new subclass.
- **do_examples** — A process step's shell declares slots (a person, a tool, an input) and they fill as things arrive.
- **dont_examples** — Adding a fourth noun subclass for tree types already covered by imperatives and modifiers.
- **rationale** — Field eight unrevised. A false gap was raised on 4.13; do not raise it a third time.
- **machine_value** — five type identifiers (candidate).

#### 4.5 State on a glyph

Finding: there is no widely accepted open standard for run state on a node. BPMN's line weight and fill mean event position (start, intermediate, end), not progress. Standard flowchart notation defines shapes only. Diagram notations model structure and stop before execution. **4.5 is an owner decision, not an inheritance.**

- **rule_text** — Hollow — not started. Solid — done. Motion — running. Fill does not carry progress. A running thing moves; a finished thing is still. Candidate treatment: the outline animates. Subdued — abandoned. Eighty percent knocked back. Broken takes the hazard accent and needs no fill of its own.
- **do_examples** — Same subdued mechanic as disabled, as the completed shell that says not your problem, and as a subdued readout in 5.2.
- **dont_examples** — Reading progress from how full the fill is. Inheriting a BPMN "state" convention that does not exist.
- **rationale** — Motion-means-running sits with 4.15: motion carries firmness, and the snap is a real event.
- **machine_value** — hollow=not_started; solid=done; motion=running; subdued=abandoned opacity=0.2; broken=skin fill hazard.

#### 4.6 The null tile

⚠ Carried unverified (sight-explore packet not returned).

- **rule_text** — Black means *nothing exists*. In light mode white is that same absence. A null tile means *something should exist here and does not*. Absence that matters gets drawn. Two null conditions, carried as fill on one tile rather than as two glyphs: never filled, and was filled, now broken. Broken is hazard. Containers report their own state, so holes are not drawn wholesale. Three shell states: empty, part-filled, done. Individual null tiles appear only inside a part-filled container. A completed shell says *not your problem*.
- **do_examples** — A gap inside a part-filled container.
- **dont_examples** — Drawing holes wholesale across a completed shell. A numeric threshold for when holes appear.
- **rationale** — Pillar one. No threshold is needed.
- **machine_value** —

#### 4.7 Modifiers

- **rule_text** — Accents are not additive. They are ranked. **Two accents visible at a time, not one.** Precedence: current task, then hazard, then changed-since. Where you are beats what is wrong beats what moved. Top two show. A thing that is your current task, hazarded and changed shows current task and hazard; the italics drop. As drawn: current task takes the frame and a thin ring outside it (persona r 32, else rect 0,6 64x52) in task at 50 %, pulsing. Broken takes the skin in hazard; the frame stays ink unless a higher accent claims it. Changed-since takes the frame. Task and broken together: frame task, skin hazard; changed drops.
- **do_examples** — Current task plus hazard on the same tile; changed-since drops.
- **dont_examples** — One accent visible at a time, ever. Lighting the field up all over.
- **rationale** — Density is bounded by the precedence rule rather than by a separate cap.
- **machine_value** — max_visible_accents=2; precedence=current_task,hazard,changed_since; task_target=frame+ring; hazard_target=skin; changed_target=frame.

#### 4.8 Composition and reading order

- **rule_text** — A process longer than the screen scrolls. It does not wrap and it does not compress. Horizontal is time. A timeline runs across the top of the field. It marks present time and carries two bounds the owner sets for the window being viewed; the default range ends at now. Simultaneous things stack in the same column. Branches turn at forty-five degrees only. Three moves exist: straight, up forty-five, down forty-five. Geometry beats scale. Where a branch needs vertical room, the time axis stretches to accommodate the diagonal. The axis is ordered but not to scale.
- **do_examples** — Transit-diagram grammar (Vignelli's New York subway diagram named as the reference).
- **dont_examples** — Wrapping or compressing a long process. Reading duration from horizontal distance.
- **rationale** — Consistent with borrowed-never-invented. Duration is read from the labelled timeline. A to-scale renderer remains possible later as a different sense of the same tree; it is not this one.
- **machine_value** — branch_angle_deg=45.

#### 4.9 Sequence position

- **rule_text** — Position is read from the spine, which is already laid out in order. The tile does not carry its own number by default. A count appears only where the path is genuinely linear.
- **do_examples** — A linear path showing *step four of seven*.
- **dont_examples** — Numbering down a fork.
- **rationale** — Branches break numbering — *step four of seven* stops being true down a fork.
- **machine_value** —

#### 4.10 Where am I

- **rule_text** — On arrival the field leads with the one thing that is yours. Bottom line up front. It goes and finds it rather than waiting to be asked. Register is set by band: terse and bottom-line up top where things are structured; discursive and exploratory down in the water where things are forming. Prose belongs below; summary belongs above.
- **do_examples** — Loop beat one answered before it is asked.
- **dont_examples** — Briefing in structured register while the owner is working in the water.
- **rationale** — This is loop beat one. The same rule applied to language.
- **machine_value** —

#### 4.11 Depth

- **rule_text** — Depth stays at tier one. The slot model is signed integers with the viewer at zero, backdrop and interface as sentinel tracks outside the number line. That is not engine-specific.
- **do_examples** — Any surface honouring signed slots, including a web renderer or a document export.
- **dont_examples** — Pushing depth down to a Godot tier-two bible as if it were engine-specific.
- **rationale** — Any surface can honour it.
- **machine_value** — slot: signed integer; viewer=0.

#### 4.12 Planned versus actual

- **rule_text** — The plan is the spine and does not move. An unfilled slot in the manifest is a visible hole. The actual arrives and snaps in. No additional channel is spent. The middle band is where planned versus actual is visible: this instance is running against that plan, is at this step, and has been there this long.
- **do_examples** — Fluid actuals snapping into a rigid spine.
- **dont_examples** — Spending a fourth channel on planned versus actual.
- **rationale** — Covered by material already recorded.
- **machine_value** —

#### 4.13 Type

Confirmed as already covered. No new content. See 4.3 and 4.4. Do not raise tree node types as a missing subclass again.

- **rule_text** — Type is carried by outer shape (4.3) and the two glyph classes plus three noun subclasses (4.4).
- **do_examples** — Personas, processes, tools as distinct shapes. Imperatives and modifiers for the rest.
- **dont_examples** — A new subclass for issue, risk, workItem, or scopeItem.
- **rationale** — Already answered.
- **machine_value** —

#### 4.14 Density and rest

- **rule_text** — One element is allowed to dominate; everything else steps back. Rest is what falls out of that, not emptiness pursued for its own sake. What dominates changes. It is not a fixed slot.
- **do_examples** — Portal chamber signage (reference only, not a layout to copy): an enormous chamber number over a small manifest of what the room contains, over the finer detail beneath.
- **dont_examples** — Emptiness pursued for its own sake. A fixed dominance slot.
- **rationale** — Rest falls out of dominance.
- **machine_value** —

#### 4.15 Motion

- **rule_text** — Motion carries firmness, reinforcing what field position and shape already say. It does not carry its own separate meaning. Water: soft motion. Fluid, continuous. Sky: snappy motion. Crisp, settled. Middle: both, and this is informative. The rigid spine of the plan does not move. Actuals arrive as fluid things that **snap into** the spine. **The snap is the moment something became actual.** Motion therefore carries a real event, not polish.
- **do_examples** — A snap into the spine as the commit-to-actual event.
- **dont_examples** — Motion as decoration. A second meaning on the motion channel.
- **rationale** — No channel may carry two meanings. The snap is a real event.
- **machine_value** —

#### 4.16 What the renderer may not do

- **rule_text** — No invented shapes. No channel carries two meanings. Duration is not read from horizontal distance. The renderer reads and never writes. **No inferring, scoped to the structure:** in the middle band and above, if it is not in the tree the renderer does not guess it or fill it. Blank stays blank. In the water, invention is the point. **No persuading applies to the renderer, not to the persona.** The renderer draws state; it does not nudge, invent urgency, or dress a thing up to get action. A persona may push you through a process it is inside — that is what it is for. It does not operate outside that process.
- **do_examples** — Blank stays blank in the middle and above. A persona pushing through a process it is inside.
- **dont_examples** — Guessing a missing tree field. The renderer nudging. A persona operating outside its process.
- **rationale** — Band-scoped, exactly like typing in 5.1. The limit lands on the drawing.
- **machine_value** — renderer_writes=false.

### ⚠ Deliberate misfiling — owner instruction

Encapsulating an idea and moving it upward is the commit. The gesture is the ceremony. Below the line nothing is committed and building is free; crossing the line is the act. Matches unlimited planning laps below, gated single-pass execution above.

**The owner believes this belongs to the writer tool, not the bible, and has instructed that it be filed in the bible anyway so that he finds it later and argues with himself about it.** This note is the whole point. Do not quietly relocate it. Do not resolve it. It is parked in the wrong drawer on purpose.

Consequence: if moving a thing upward commits it, something writes. That something is the writer tool named in out-of-scope item one.

---

## 5. Hearing

- name
- receptor
- stimulus
- modality
- designer_intent
- target_audience_response
- reconciliation_rule
- congruence_relationship — declared against sight
- accessibility_floor

### Rules

Drafted against the S4-passed outline. No structural change. Five rules. Drafting inside an existing rule is ordinary S5 work.

Seventh-packet headings are void. Material that survived lives under these five.

#### 5.1 Voice in

- **rule_text** — Tap to talk, tap to send. 5.1 owns the input mechanic. Typing is band-gated: allowed in the middle band and above, where precision work happens — API keys, paste, exact strings. **Refused in the deep water.** Down there the interface is voice only. This supersedes typing-locked-at-first-run: same instinct, better mechanism.

  Each persona carries its own voice in its own definition file. The default comes from position. Vertical position sets a persona's disposition. In the water: supports flow. Does not interrupt, does not get in the way, does not flatter or cheerlead. Keeps up. In the structure: matter of fact, bottom line up front, sourced, checked before speaking — links verified exactly, checking upon checking. The strong version: the same expertise can be placed in two positions at once and yield two behaviours. Two slots up top that a persona can be snapped into, pointed at different models, to play off each other. One copy dreaming with the owner, another copy planning against him, same knowledge, different posture.

  Personas are physical objects. Drag-and-drop marks that walk along the band they were placed in. Five discrete bands, not a continuous slider. They can be snapped into a process or into a session in the water. Speech bubbles when they talk. Owner's stated reason for the walking bots, on the record: he wanted it. That is sufficient warrant.
- **do_examples** — Paste an API key in the middle band. Voice only in the deep water. Same persona snapped into two top slots, different models.
- **dont_examples** — A text box in the deep water. Flattering or cheerleading from a water persona.
- **rationale** — The joke version of first-run typing was never a real rule. Disposition is the gradient rule applied to personas.
- **machine_value** — deep_water_typing=false; middle_and_above_typing=true.

#### 5.2 Cost is audible

- **rule_text** — Accruals are on screen at all times. Four of them: time of day, spend, **time on task**, and **memory budget**. Time on task is elapsed, not a countdown. The memory budget is a design device, not a warning. A visible ceiling is what stops dashboard sprawl. Everything has a cost and the cost is in view. A chime is available at thresholds, opt-in, default off. On the hour, on a spend figure, on whatever the owner arms. One control, not two. Tap the readout: it subdues and goes silent together. Tap again: normal colour and audible again. Visible state and audible state are the same switch and can never disagree.
- **do_examples** — Elapsed time on task always visible. Opt-in chime, default off.
- **dont_examples** — A countdown. A chime Loom decided on. Visible mute and audible mute disagreeing.
- **rationale** — Time blindness: you should not have to ask how long you have been in there. A chime the owner armed in advance is not Loom initiating sound. 5.4 bans unsolicited sound. Opt-in and default-off keeps both rules true.
- **machine_value** — accruals=time_of_day,spend,time_on_task,memory_budget; chime_default=off; mute_is_one_control=true.

#### 5.3 Confirmation, not decoration

- **rule_text** — The snap has a sound. Actuals snapping into the spine is a real event, so it is the thing sound is spent on. It sounds like a snap. Sharp transient, immediate stop, no tail. Two hard things meeting. Nobody has to learn what it means. Position sets the treatment. Sky: a short hiss rising into the click. The hiss is anticipation — you hear it land a fraction before it lands. Water: the same event heard underwater. Low-pass — the top end is eaten, body without edge.
- **do_examples** — Sky snap with a short hiss into the click. Water snap low-passed.
- **dont_examples** — Ambience. A tail on the snap. Sound earned by anything other than the snap (and armed 5.2 chimes).
- **rationale** — This is the motion rule as sound: sky snappy, water soft. Not a new idea, the same rule in another sense.
- **machine_value** —

#### 5.4 Silence is the default

- **rule_text** — Working correctly, Loom makes no sound. Answer only. It never initiates. No notifications, no chimes it decided on, no check-ins, no prompting. **No exceptions, including hazard** — considered and ruled no, for now, so any future exception is added deliberately rather than left ajar. The floor is always the user's. Speech can be cut mid-sentence, without penalty. Tap is the floor; voice interrupt is the intent. Tap always works, so the rule never depends on something hard. Voice interrupt — you start talking, it stops — is wanted and marked as not guaranteed.
- **do_examples** — A tap that cuts the voice off mid-sentence and stops it. When the machine holds the floor its location is visible (square wave up top), so it is easy to cut off.
- **dont_examples** — A system that keeps talking with no way to stop it. A hazard chime Loom decided on.
- **rationale** — Silence is the default. Holding the floor would contradict it. Floor-holding is this rule seen from the user's side, not a sixth rule.
- **machine_value** — initiates_sound=false; hazard_exception=false; tap_cuts_speech=true.

#### 5.5 Nothing is sound-only

- **rule_text** — The words are always on screen. Speech bubbles are not conditional on mute. They appear whether or not you are listening. Audio is the optional layer. Sound is the thing that can be removed. The text never was. Mute therefore costs nothing. It removes audio and changes nothing else. Per-persona or global. Bubbles persist, then fade — the record does not. The transcript stays in the water. Recall on demand. Tapping a persona brings back its recent lines. You never go hunting for what was said.
- **do_examples** — Captions on while hearing perfectly well. Mute a persona; its bubbles still appear.
- **dont_examples** — Speech that exists only as audio. Mute that also hides the words.
- **rationale** — People watch with captions on while hearing perfectly well. Text alongside audio is the default presentation, not an accessibility fallback.
- **machine_value** — mute_hides_text=false.

Moved out of hearing (no home in section 5): no asserting what it does not have; sourcing shape (cite the primary, never a derivative of a derivative; blogs and forum posts are routes to a source and never the source, noting a repost is sometimes the only surviving copy). See `artifacts/truthfulness.md`. Persona configuration — memory, knowledge, skills, tool snapping — persona definition file. See `artifacts/persona-file.md`.

---

## Parked

Working-file scaffolding. Not a bible section. Comes off before S7.

Parking was explicitly refused this sitting for new parks.

Standing:

- Whether tier-two bibles name their own three accents.
- Tile variants beyond the fixed square.
- Voice-only stance versus a live loadout panel.
- The 2026-09-04 state packet's section eight list, as written.
- The five W's toward 4.10.
- Private project names.
- Whether a timer sits alongside weight-as-importance.
- Whether a thing that pulls you back and a thing you rest on are the same object.
- Authentication for commits performed on a persona's behalf (writer-tool, not bible). Owner leans toward API keys over per-persona git logins.
