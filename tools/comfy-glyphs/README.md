# Comfy glyph machine

Describe a tile. Queue. If it is wrong, queue again. When one is
right, pull it. The weave stays a white sheet. This does not paint
Godot.

Grammar: `BRIEF.md`. Bible: `loom/DESIGN-BIBLE.md`. Artwork is out
of scope for the bible; this is the handoff.

Orange is out. Do not name Valve or Portal in the prompt. Take the
grammar, not the costume.

## In Comfy

1. Load `workflow.json`.
2. Point Load Checkpoint at an SDXL model you already have.
3. Edit the last line of SUBJECT (`SUBJECT: …`).
4. Queue. Four squares. Seed randomizes.
5. Wrong: Queue. Right: `loom-glyph_*.png` in Comfy's output folder.

White field is the default so a tile can sit on the white window.
Charter sign-face (white marks on black) is `--field sign` on the CLI.

## CLI, same loop

ComfyUI running at `http://127.0.0.1:8188`.

```
python3 tools/comfy-glyphs/queue.py "a hat on a round bust, meaning role" --class persona
python3 tools/comfy-glyphs/queue.py --refresh
python3 tools/comfy-glyphs/queue.py --pull
```

`--class` is one of: `persona` `process` `tool` `imperative` `null`
`hazard` `task` `changed`.

`--pull` copies the last batch to `artifacts/glyphs/picked/`.

## Examples

```
python3 tools/comfy-glyphs/queue.py "muster mob: a slot with a figure rising out of it" --class tool
python3 tools/comfy-glyphs/queue.py "settled rectangle, three bars for the steps" --class process
python3 tools/comfy-glyphs/queue.py "empty seat on a three-seat bench" --class null
python3 tools/comfy-glyphs/queue.py "the same bust, brim and crown, a role is a hat" --class persona
```
