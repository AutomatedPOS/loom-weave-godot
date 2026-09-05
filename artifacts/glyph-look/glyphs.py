#!/usr/bin/env python3
"""Reference glyph tiles for the rails, drawn to the bible's grammar.
One 64-unit square tile. Outer frame borrowed, inner glyph a skin,
fill carries state. Colours are the Tokens.gd values, nothing else."""
import math, os, sys
OUT = sys.argv[1]
# Tokens.gd, as hex.
BLACK="#000000"; INK="#ADADB3"; DIM="#6B6B70"; EDGE="#383D3D"; WELL="#1A1A1C"; SURFACE="#0A0A0B"
GHOST="rgba(107,107,112,0.45)"
HAZARD="#D55E00"; TASK="#56B4E9"; CHANGED="#CC79A7"
SW=2      # stroke at 64
T=64

def frame(kind, stroke=INK, dash=None, sw=SW):
    d = f' stroke-dasharray="{dash}"' if dash else ""
    if kind == "persona":
        return f'<circle cx="32" cy="32" r="28" fill="none" stroke="{stroke}" stroke-width="{sw}"{d}/>'
    if kind == "process":
        return f'<rect x="4" y="10" width="56" height="44" fill="none" stroke="{stroke}" stroke-width="{sw}"{d}/>'
    if kind == "tool":
        return (f'<rect x="4" y="10" width="56" height="44" fill="none" stroke="{stroke}" stroke-width="{sw}"{d}/>'
                f'<line x1="11" y1="10" x2="11" y2="54" stroke="{stroke}" stroke-width="{sw}"{d}/>'
                f'<line x1="53" y1="10" x2="53" y2="54" stroke="{stroke}" stroke-width="{sw}"{d}/>')
    if kind == "null":
        return f'<rect x="4" y="4" width="56" height="56" fill="none" stroke="{stroke}" stroke-width="{sw}" stroke-dasharray="4 4"/>'
    raise ValueError(kind)

def wrench_path():
    # Local coords, head up, then rotated 45 deg so the jaw points up-right.
    w=3.5; r=9.0; cy=-12.0; n=3.0
    yb = cy + math.sqrt(r*r - w*w)   # handle meets head
    yt = cy - math.sqrt(r*r - n*n)   # notch meets head
    return (f"M {-w},20 L {-w},{yb:.2f} A {r} {r} 0 0 1 {-n},{yt:.2f} "
            f"L {-n},{cy} L {n},{cy} L {n},{yt:.2f} A {r} {r} 0 0 1 {w},{yb:.2f} "
            f"L {w},20 A {w} {w} 0 0 1 {-w},20 Z")

def glyph(kind, fill, stroke, sw=SW):
    """The skin. fill=None means hollow (stroke only)."""
    f = fill if fill else "none"
    s = f'fill="{f}" stroke="{stroke}" stroke-width="{sw}" stroke-linejoin="round"'
    if kind == "human":
        # Round head on rounded shoulders. Front-on, no limbs.
        return (f'<circle cx="32" cy="24" r="8" {s}/>'
                f'<path d="M 17,48 L 17,44 A 9 9 0 0 1 26,35 L 38,35 A 9 9 0 0 1 47,44 L 47,48 Z" {s}/>')
    if kind == "robot":
        # Boxy head, one visor slot, an antenna, square shoulders.
        visor = f'<rect x="26" y="20" width="12" height="4" fill="{BLACK if fill else "none"}" stroke="{stroke}" stroke-width="{sw}"/>'
        return (f'<rect x="22" y="14" width="20" height="18" {s}/>' + visor +
                f'<line x1="32" y1="14" x2="32" y2="9" stroke="{stroke}" stroke-width="{sw}"/>'
                f'<circle cx="32" cy="7.5" r="1.5" fill="{stroke}"/>'
                f'<rect x="17" y="36" width="30" height="12" {s}/>')
    if kind == "process":
        # A spine with three stations: the plan, left to right.
        out = f'<line x1="14" y1="32" x2="50" y2="32" stroke="{stroke}" stroke-width="{sw}"/>'
        for cx in (18, 32, 46):
            out += f'<rect x="{cx-4}" y="28" width="8" height="8" {s}/>'
        return out
    if kind == "tool":
        return f'<g transform="translate(32,32) rotate(45) scale(0.78)"><path d="{wrench_path()}" {s}/></g>'
    if kind == "none":
        return ""
    raise ValueError(kind)

FRAME_OF = {"human": "persona", "robot": "persona", "process": "process", "tool": "tool"}

def tile(kind, state="hollow", accents=(), x=0, y=0, scale=1.0, chip=False):
    """state: hollow | solid | subdued | broken. accents: subset of task, changed."""
    fk = FRAME_OF.get(kind, "null")
    stroke = INK; fill = None; opacity = 1.0
    if state == "solid": fill = INK
    if state == "subdued": fill = INK; opacity = 0.2
    if state == "broken": fill = HAZARD; stroke = HAZARD if kind == "none" else INK
    parts = []
    fstroke = INK
    if "changed" in accents: fstroke = CHANGED
    if "task" in accents:
        fstroke = TASK
        if fk == "persona":
            parts.append(f'<circle cx="32" cy="32" r="32" fill="none" stroke="{TASK}" stroke-width="1" opacity="0.5"/>')
        else:
            parts.append(f'<rect x="0" y="6" width="64" height="52" fill="none" stroke="{TASK}" stroke-width="1" opacity="0.5"/>')
    if kind == "none":
        parts.append(frame("null", stroke=(HAZARD if state == "broken" else DIM), dash=None))
    else:
        parts.append(frame(fk, stroke=fstroke))
        parts.append(glyph(kind, fill, stroke))
    inner = "".join(parts)
    return f'<g transform="translate({x},{y}) scale({scale})" opacity="{opacity}">{inner}</g>'

def svg(w, h, body, bg=BLACK):
    return (f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}">'
            f'<rect width="{w}" height="{h}" fill="{bg}"/>{body}</svg>')

# --- single tiles, 64 units, hollow (on the rail) ------------------------
for name, kind in [("persona-human","human"),("persona-robot","robot"),("process","process"),("tool","tool")]:
    open(os.path.join(OUT, f"{name}.svg"), "w").write(svg(64, 64, tile(kind, "hollow")))
open(os.path.join(OUT, "null-tile.svg"), "w").write(svg(64, 64, tile("none", "hollow")))

# --- the sheet, 1440 x 900 ------------------------------------------------
def caps(x, y, text, color=DIM, size=12, anchor="start", weight="normal"):
    return (f'<text x="{x}" y="{y}" fill="{color}" font-family="Noto Sans, DejaVu Sans, Arial, sans-serif" '
            f'font-size="{size}" letter-spacing="1" text-anchor="{anchor}" font-weight="{weight}">{text.upper()}</text>')
def rule(x1, y, x2, color=EDGE):
    return f'<line x1="{x1}" y1="{y}" x2="{x2}" y2="{y}" stroke="{color}" stroke-width="1"/>'

b = []
b.append(caps(64, 52, "glyphs · reference", INK, 18))
b.append(caps(1376, 52, "bible 4.3 · 4.4 · 4.5 · 4.6 · 4.7", DIM, 12, "end"))
b.append(rule(64, 64, 1376))

# Row 1: the four tiles, large. Outer frame named under each.
cols = [("human","persona · human","frame: circle, the avatar", "skin: round head, round shoulders"),
        ("robot","persona · robot","frame: circle, the avatar", "skin: boxy head, one visor, antenna"),
        ("process","process","frame: flowchart process", "skin: a spine, three stations"),
        ("tool","tool","frame: flowchart predefined process", "skin: a spanner")]
x0 = 64; step = 328; ty = 100; sc = 2.5
for i,(k,label,f,s) in enumerate(cols):
    x = x0 + i*step
    b.append(tile(k, "hollow", x=x, y=ty, scale=sc))
    b.append(caps(x, ty + 64*sc + 28, label, INK, 14))
    b.append(caps(x, ty + 64*sc + 48, f, DIM, 11))
    b.append(caps(x, ty + 64*sc + 64, s, DIM, 11))
b.append(caps(64, 92, "one glyph per square tile. outer frame is borrowed and says the type. inner glyph is the skin and swaps. round is human, boxy is machine.", DIM, 11))

# Row 2: at rail-chip size, 1:1, plus 32 and 24 px checks.
ry = 360
b.append(rule(64, ry, 1376))
b.append(caps(64, ry + 24, "on the rail, 1:1 · chip 144 × 48 with the tile at 24 px (today's glyph is 12) · then the tile at 32 px and 24 px", DIM, 11))
names = [("human","Archivus"),("robot","Brains"),("process","Brief"),("tool","")]
for i,(k,nm) in enumerate(names):
    x = x0 + i*step; y = ry + 44
    # a rail chip as Canvas.gd draws it: well fill, edge border, glyph, small caps name
    b.append(f'<rect x="{x}" y="{y}" width="144" height="48" fill="{WELL}" stroke="{EDGE}" stroke-width="1"/>')
    g = 24  # glyph box on the chip; today's glyph is 12 px, the tile scales to 24
    b.append(tile(k, "hollow", x=x+12, y=y+12, scale=g/64))
    b.append(caps(x+44, y+29, nm, INK, 13) if nm else caps(x+44, y+29, "no tool yet", DIM, 11))
    # 32 and 24 px
    b.append(tile(k, "hollow", x=x+172, y=y+8, scale=0.5))
    b.append(tile(k, "hollow", x=x+220, y=y+12, scale=24/64))
    b.append(tile(k, "solid", x=x+172, y=y+56, scale=0.5))
    b.append(tile(k, "solid", x=x+220, y=y+60, scale=24/64))
b.append(caps(64, ry + 150, "hollow on the rail, solid once it is on the field. the frame, not the skin, is the drop target.", DIM, 11))

# Row 3: state grammar, on the human persona. Fill carries state, accents modify.
sy = 540
b.append(rule(64, sy, 1376))
b.append(caps(64, sy + 24, "state is fill, 4.5. accents are modifiers, ranked task, hazard, changed, two at a time, 4.7. black is nothing; the null tile is a hole that matters, 4.6.", DIM, 11))
states = [("hollow", (), "not started", "hollow"),
          ("solid", (), "done", "solid"),
          ("subdued", (), "abandoned", "ink at 20 %"),
          ("broken", (), "broken", "skin takes hazard"),
          ("hollow", ("task",), "current task", "frame takes task"),
          ("broken", ("task",), "task + broken", "top two show"),
          ("hollow", ("changed",), "changed since", "frame takes changed"),
          ]
sc2 = 1.5; sx = 64; sstep = 164
for i,(st,acc,label,how) in enumerate(states):
    x = sx + i*sstep; y = sy + 44
    b.append(tile("human", st, acc, x=x, y=y, scale=sc2))
    b.append(caps(x, y + 64*sc2 + 22, label, INK, 12))
    b.append(caps(x, y + 64*sc2 + 40, how, DIM, 11))
# null tiles at the end
x = sx + 7*sstep; y = sy + 44
b.append(tile("none", "hollow", x=x, y=y, scale=sc2))
b.append(caps(x, y + 64*sc2 + 22, "null tile", INK, 12))
b.append(caps(x, y + 64*sc2 + 40, "a hole that matters", DIM, 11))
b.append(caps(64, 880, "running is motion, not a fill; a still cannot show it. the task ring pulses. colours are tokens.gd only. no font is chosen; the sheet uses the system sans.", DIM, 11))

open(os.path.join(OUT, "glyph-sheet.svg"), "w").write(svg(1440, 900, "".join(b)))
print("wrote", os.listdir(OUT))
