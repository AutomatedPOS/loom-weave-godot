#!/usr/bin/env python3
"""Reference glyph tiles for the rails, drawn to the bible's grammar.
One 64-unit square tile. Outer frame borrowed, inner glyph a skin,
fill carries state. Two modes, dark and light; same geometry, the
palette swaps. Every colour here is a token; nothing else is spelled."""
import math, os, sys
OUT = sys.argv[1]

MODES = {
    "dark": dict(
        field="#000000", ink="#ADADB3", ink_hover="#C7C7CC", dim="#6B6B70",
        surface="#0A0A0B", well="#1A1A1C", edge="#38383D",
        hazard="#8B1E1E", task="#D99A1F", changed="#6B8FAE"),
    "light": dict(
        field="#FFFFFF", ink="#4A4A50", ink_hover="#303036", dim="#8E8E94",
        surface="#F7F7F8", well="#EDEDEF", edge="#D2D2D6",
        hazard="#8B1E1E", task="#A06E10", changed="#4F7291"),
}
SW = 2   # stroke at 64
T = 64

class Pal:
    def __init__(self, d): self.__dict__.update(d)

def frame(P, kind, stroke, sw=SW, dash=None):
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
    """Open-end spanner. C-jaw, handle, pivot at the jaw. Local +Y down."""
    R, ri, w = 11.0, 5.6, 4.4
    jx, jy = 0.0, -7.2
    ah = math.radians(40)
    a0 = -math.pi / 2 - ah
    a1 = -math.pi / 2 + ah
    def pt(a, rad):
        return (jx + rad * math.cos(a), jy + rad * math.sin(a))
    ol, orr = pt(a0, R), pt(a1, R)
    il, ir = pt(a0, ri), pt(a1, ri)
    y_join = jy + math.sqrt(R * R - w * w)
    hy = 16.8
    return (
        f"M {-w},{hy:.2f} L {-w},{y_join:.2f} "
        f"A {R} {R} 0 0 1 {ol[0]:.2f},{ol[1]:.2f} "
        f"L {il[0]:.2f},{il[1]:.2f} "
        f"A {ri} {ri} 0 1 0 {ir[0]:.2f},{ir[1]:.2f} "
        f"L {orr[0]:.2f},{orr[1]:.2f} "
        f"A {R} {R} 0 0 1 {w},{y_join:.2f} "
        f"L {w},{hy:.2f} "
        f"A {w} {w} 0 0 1 {-w},{hy:.2f} Z"
    )

def glyph(P, kind, fill, stroke, sw=SW):
    f = fill if fill else "none"
    s = f'fill="{f}" stroke="{stroke}" stroke-width="{sw}" stroke-linejoin="round" stroke-linecap="round"'
    if kind == "human":
        # Sphere on a wide closed capsule. Neck is the gap. Body does not dump off the tile.
        return (f'<circle cx="32" cy="22.5" r="6.5" {s}/>'
                f'<rect x="19.5" y="32" width="25" height="13" rx="6.5" ry="6.5" {s}/>')
    if kind == "robot":
        # Antenna sits on the head, inside the skin box. Head is a cube. Visor is the face.
        visor = f'<rect x="26.5" y="25.5" width="11" height="4" fill="{P.field if fill else "none"}" stroke="{stroke}" stroke-width="{sw}"/>'
        return (
            f'<circle cx="32" cy="16.5" r="1.6" fill="{stroke}"/>'
            f'<line x1="32" y1="18" x2="32" y2="20.5" stroke="{stroke}" stroke-width="{sw}" stroke-linecap="round"/>'
            f'<rect x="23" y="20.5" width="18" height="15.5" {s}/>' + visor +
            f'<rect x="21" y="38" width="22" height="11.5" {s}/>'
        )
    if kind == "process":
        # Bigger stations. Spine punched out of them so hollow still reads as three cubes on a rod.
        out = f'<line x1="13" y1="32" x2="51" y2="32" stroke="{stroke}" stroke-width="{sw}"/>'
        for cx in (18, 32, 46):
            out += f'<rect x="{cx-5}" y="27" width="10" height="10" fill="{P.field}" stroke="none"/>'
            out += f'<rect x="{cx-5}" y="27" width="10" height="10" {s}/>'
        return out
    if kind == "tool":
        return f'<g transform="translate(32,32) rotate(45) scale(0.86)"><path d="{wrench_path()}" {s}/></g>'
    if kind == "none":
        return ""
    raise ValueError(kind)

FRAME_OF = {"human": "persona", "robot": "persona", "process": "process", "tool": "tool"}

def tile(P, kind, state="hollow", accents=(), x=0, y=0, scale=1.0):
    fk = FRAME_OF.get(kind, "null")
    stroke = P.ink; fill = None; opacity = 1.0
    if state == "solid": fill = P.ink
    if state == "subdued": fill = P.ink; opacity = 0.2
    if state == "broken": fill = P.hazard
    parts = []
    fstroke = P.ink
    if "changed" in accents: fstroke = P.changed
    if "task" in accents:
        fstroke = P.task
        if fk == "persona":
            parts.append(f'<circle cx="32" cy="32" r="32" fill="none" stroke="{P.task}" stroke-width="1" opacity="0.5"/>')
        else:
            parts.append(f'<rect x="0" y="6" width="64" height="52" fill="none" stroke="{P.task}" stroke-width="1" opacity="0.5"/>')
    if kind == "none":
        parts.append(frame(P, "null", stroke=(P.hazard if state == "broken" else P.dim)))
    else:
        parts.append(frame(P, fk, stroke=fstroke))
        parts.append(glyph(P, kind, fill, stroke))
    return f'<g transform="translate({x},{y}) scale({scale})" opacity="{opacity}">{"".join(parts)}</g>'

def svg(w, h, body, bg):
    return (f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}">'
            f'<rect width="{w}" height="{h}" fill="{bg}"/>{body}</svg>')

def caps(x, y, text, color, size=12, anchor="start"):
    return (f'<text x="{x}" y="{y}" fill="{color}" font-family="Noto Sans, DejaVu Sans, Arial, sans-serif" '
            f'font-size="{size}" letter-spacing="1" text-anchor="{anchor}">{text.upper()}</text>')

def rule(P, x1, y, x2):
    return f'<line x1="{x1}" y1="{y}" x2="{x2}" y2="{y}" stroke="{P.edge}" stroke-width="1"/>'

COLS = [("human","persona · human","frame: circle, the avatar", "skin: sphere on a closed capsule"),
        ("robot","persona · robot","frame: circle, the avatar", "skin: cube on cube, visor, stub antenna"),
        ("process","process","frame: flowchart process", "skin: three stations on a rod"),
        ("tool","tool","frame: flowchart predefined process", "skin: open-end spanner")]
STATES = [("hollow", (), "not started", "hollow"),
          ("solid", (), "done", "solid"),
          ("subdued", (), "abandoned", "ink at 20 %"),
          ("broken", (), "broken", "skin takes hazard"),
          ("hollow", ("task",), "current task", "frame takes task"),
          ("broken", ("task",), "task + broken", "top two show"),
          ("hollow", ("changed",), "changed since", "frame takes changed")]

def sheet(mode):
    P = Pal(MODES[mode]); b = []
    b.append(caps(64, 52, f"glyphs · reference · {mode}", P.ink, 18))
    b.append(caps(1376, 52, "bible 4.3 · 4.4 · 4.5 · 4.6 · 4.7", P.dim, 12, "end"))
    b.append(rule(P, 64, 64, 1376))
    b.append(caps(64, 92, "one glyph per square tile. outer frame is borrowed and says the type. inner glyph is the skin and swaps. round is human, boxy is machine.", P.dim, 11))
    x0 = 64; step = 328; ty = 100; sc = 2.5
    for i,(k,label,f,s) in enumerate(COLS):
        x = x0 + i*step
        b.append(tile(P, k, "hollow", x=x, y=ty, scale=sc))
        b.append(caps(x, ty + 64*sc + 28, label, P.ink, 14))
        b.append(caps(x, ty + 64*sc + 48, f, P.dim, 11))
        b.append(caps(x, ty + 64*sc + 64, s, P.dim, 11))
    ry = 360
    b.append(rule(P, 64, ry, 1376))
    b.append(caps(64, ry + 24, "on the rail, 1:1 · chip 144 × 48 with the tile at 24 px (today's glyph is 12) · then the tile at 32 px and 24 px", P.dim, 11))
    names = [("human","Archivus"),("robot","Brains"),("process","Brief"),("tool","")]
    for i,(k,nm) in enumerate(names):
        x = x0 + i*step; y = ry + 44
        b.append(f'<rect x="{x}" y="{y}" width="144" height="48" fill="{P.well}" stroke="{P.edge}" stroke-width="1"/>')
        b.append(tile(P, k, "hollow", x=x+12, y=y+12, scale=24/64))
        b.append(caps(x+44, y+29, nm, P.ink, 13) if nm else caps(x+44, y+29, "no tool yet", P.dim, 11))
        b.append(tile(P, k, "hollow", x=x+172, y=y+8, scale=0.5))
        b.append(tile(P, k, "hollow", x=x+220, y=y+12, scale=24/64))
        b.append(tile(P, k, "solid", x=x+172, y=y+56, scale=0.5))
        b.append(tile(P, k, "solid", x=x+220, y=y+60, scale=24/64))
    b.append(caps(64, ry + 150, "hollow on the rail, solid once it is on the field. the frame, not the skin, is the drop target.", P.dim, 11))
    sy = 540
    b.append(rule(P, 64, sy, 1376))
    b.append(caps(64, sy + 24, "state is fill, 4.5. accents are modifiers, ranked task, hazard, changed, two at a time, 4.7. the field is nothing; the null tile is a hole that matters, 4.6.", P.dim, 11))
    sc2 = 1.5; sx = 64; sstep = 164
    for i,(st,acc,label,how) in enumerate(STATES):
        x = sx + i*sstep; y = sy + 44
        b.append(tile(P, "human", st, acc, x=x, y=y, scale=sc2))
        b.append(caps(x, y + 64*sc2 + 22, label, P.ink, 12))
        b.append(caps(x, y + 64*sc2 + 40, how, P.dim, 11))
    x = sx + 7*sstep; y = sy + 44
    b.append(tile(P, "none", "hollow", x=x, y=y, scale=sc2))
    b.append(caps(x, y + 64*sc2 + 22, "null tile", P.ink, 12))
    b.append(caps(x, y + 64*sc2 + 40, "a hole that matters", P.dim, 11))
    # the palette, spelled once, bottom
    py = 790
    b.append(rule(P, 64, py, 1376))
    swatches = [("field", P.field), ("ink", P.ink), ("dim", P.dim), ("edge", P.edge), ("well", P.well),
                ("hazard", P.hazard), ("task", P.task), ("changed", P.changed)]
    for i,(nm,c) in enumerate(swatches):
        x = 64 + i*164
        b.append(f'<rect x="{x}" y="{py+18}" width="40" height="24" fill="{c}" stroke="{P.edge}" stroke-width="1"/>')
        b.append(caps(x+48, py+30, nm, P.ink, 11))
        b.append(caps(x+48, py+44, c, P.dim, 10))
    b.append(caps(64, 880, "running is motion, not a fill; a still cannot show it. the task ring pulses. no font is chosen; the sheet uses the system sans.", P.dim, 11))
    return svg(1440, 900, "".join(b), P.field)

def modes_strip():
    """Both modes on one picture: the four tiles and the seven states, dark over light."""
    b = []
    for row, mode in enumerate(["dark", "light"]):
        P = Pal(MODES[mode]); oy = row * 450
        b.append(f'<rect x="0" y="{oy}" width="1440" height="450" fill="{P.field}"/>')
        b.append(caps(64, oy + 44, mode, P.ink, 16))
        for i,(k,label,_,_) in enumerate(COLS):
            x = 64 + i*150; y = oy + 70
            b.append(tile(P, k, "hollow", x=x, y=y, scale=1.75))
            b.append(caps(x, y + 64*1.75 + 22, label, P.dim, 11))
        short = ["not started", "done", "abandoned", "broken", "task", "task+broken", "changed"]
        for i,(st,acc,label,how) in enumerate(STATES):
            x = 660 + i*96; y = oy + 84
            b.append(tile(P, "human", st, acc, x=x, y=y, scale=1.25))
            b.append(caps(x, y + 64*1.25 + 22, short[i], P.dim, 10))
        x = 660 + 7*96; y = oy + 84
        b.append(tile(P, "none", "hollow", x=x, y=y, scale=1.25))
        b.append(caps(x, y + 64*1.25 + 22, "null", P.dim, 10))
        # rail chips, 1:1
        names = [("human","Archivus"),("robot","Brains"),("process","Brief"),("tool","")]
        for i,(k,nm) in enumerate(names):
            x = 64 + i*160; y = oy + 300
            b.append(f'<rect x="{x}" y="{y}" width="144" height="48" fill="{P.well}" stroke="{P.edge}" stroke-width="1"/>')
            b.append(tile(P, k, "hollow", x=x+12, y=y+12, scale=24/64))
            b.append(caps(x+44, y+29, nm, P.ink, 13) if nm else caps(x+44, y+29, "no tool yet", P.dim, 11))
        sw = [("hazard", P.hazard), ("task", P.task), ("changed", P.changed)]
        for i,(nm,c) in enumerate(sw):
            x = 720 + i*200; y = oy + 300
            b.append(f'<rect x="{x}" y="{y}" width="48" height="48" fill="{c}"/>')
            b.append(caps(x+60, y+22, nm, P.ink, 12)); b.append(caps(x+60, y+40, c, P.dim, 11))
        b.append(caps(64, oy + 400, "same geometry, same three roles. hazard keeps its value; task and changed pull down on white so they read.", P.dim, 11))
    return svg(1440, 900, "".join(b), MODES["dark"]["field"])

for mode in MODES:
    P = Pal(MODES[mode])
    d = os.path.join(OUT, "tiles", mode); os.makedirs(d, exist_ok=True)
    for name, kind in [("persona-human","human"),("persona-robot","robot"),("process","process"),("tool","tool")]:
        open(os.path.join(d, f"{name}.svg"), "w").write(svg(64, 64, tile(P, kind, "hollow"), P.field))
        open(os.path.join(d, f"{name}-solid.svg"), "w").write(svg(64, 64, tile(P, kind, "solid"), P.field))
    open(os.path.join(d, "null-tile.svg"), "w").write(svg(64, 64, tile(P, "none", "hollow"), P.field))
    open(os.path.join(OUT, f"glyph-sheet-{mode}.svg"), "w").write(sheet(mode))
open(os.path.join(OUT, "glyph-modes.svg"), "w").write(modes_strip())
print("ok")
