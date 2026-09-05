"""Assemble a locked glyph prompt from the bible brief."""

from pathlib import Path

ROOT = Path(__file__).resolve().parent

CLASSES = {
    "persona": (
        "noun subclass persona: round human silhouette, one bust, "
        "a hat is a role on that body, the body does not change"
    ),
    "process": (
        "noun subclass process: settled rectangle outer frame, "
        "drawn as lines and nodes, not a body"
    ),
    "tool": (
        "noun subclass tool: boxy machine housing, icon on a faceplate, "
        "no nameplate text"
    ),
    "imperative": (
        "glyph class imperative: an action, not a noun, one verb as a mark"
    ),
    "null": (
        "null tile: something should exist here and does not, "
        "empty slot, not blank nothingness, not a second glyph"
    ),
    "hazard": (
        "hazard modifier on a noun, accent colour #D55E00 only, "
        "not orange, not a second glyph"
    ),
    "task": (
        "current-task accent #56B4E9 as a look-here mark, not a command"
    ),
    "changed": (
        "changed-since accent #CC79A7, italics / moved, nicest of the three"
    ),
}


def _read(name: str) -> str:
    return (ROOT / name).read_text(encoding="utf-8").strip()


def lock_text(field: str = "white") -> str:
    if field == "sign":
        return _read("lock_sign.txt")
    if field != "white":
        raise ValueError("field must be white or sign")
    return _read("lock_white.txt")


def negative_text() -> str:
    text = _read("negative.txt")
    return text


def assemble(subject: str, kind: str = "", field: str = "white") -> tuple[str, str]:
    subject = " ".join(subject.split()).strip()
    if not subject:
        raise ValueError("subject is empty")
    parts = [lock_text(field)]
    if kind:
        key = kind.strip().lower()
        if key not in CLASSES:
            raise ValueError("unknown class: %s" % kind)
        parts.append(CLASSES[key])
    parts.append(subject)
    return ", ".join(parts), negative_text()
