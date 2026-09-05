class_name LoomGlyphs
extends RefCounted

## Four noun tiles from artifacts/glyph-look. Outer frame is borrowed
## and is the hit. Inner glyph is the skin and swaps. Fill is state.
## Geometry is the 64-unit tile in glyphs.py; we scale and snap stroke
## to 1 px when the scaled 2-unit stroke would go under a pixel.

const SKINS: Array[StringName] = [&"human", &"robot", &"process", &"tool"]
const KINDS: Array[StringName] = [&"persona", &"process", &"tool"]
const FRAME_OF := {
	&"human": &"persona",
	&"robot": &"persona",
	&"process": &"process",
	&"tool": &"tool",
	&"persona": &"persona",
}


static func skin_for(kind: StringName, name: String = "") -> StringName:
	if kind == &"persona":
		return &"robot" if name.to_lower() == "brains" else &"human"
	return kind


static func stroke_px(tile_px: float) -> float:
	var scaled := float(LoomTokens.GLYPH_STROKE) * tile_px / float(LoomTokens.GLYPH_NATIVE)
	return 1.0 if scaled < 1.0 else scaled


static func draw_tile(ci: CanvasItem, origin: Vector2, tile_px: float, skin: StringName, state: StringName = &"hollow", accents: Array = []) -> void:
	var s := tile_px / float(LoomTokens.GLYPH_NATIVE)
	var sw := stroke_px(tile_px)
	ci.draw_set_transform(origin, 0.0, Vector2(s, s))
	var fade := 0.2 if state == &"subdued" else 1.0
	var frame_kind: StringName = FRAME_OF.get(skin, &"null")
	var fstroke := _fade(LoomTokens.INK, fade)
	if &"changed" in accents:
		fstroke = _fade(LoomTokens.CHANGED, fade)
	if &"task" in accents:
		fstroke = _fade(LoomTokens.TASK, fade)
		_task_ring(ci, frame_kind, fade)
	if skin == &"none" or skin == &"null":
		var nstroke := LoomTokens.HAZARD if state == &"broken" else LoomTokens.DIM
		_frame_null(ci, _fade(nstroke, fade), sw)
	else:
		_frame(ci, frame_kind, fstroke, sw)
		var fill := LoomTokens.CLEAR
		if state == &"solid" or state == &"subdued":
			fill = LoomTokens.INK
		if state == &"broken":
			fill = LoomTokens.HAZARD
		_skin(ci, skin, _fade(fill, fade), _fade(LoomTokens.INK, fade), sw)
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


static func draw_frame_only(ci: CanvasItem, origin: Vector2, tile_px: float, kind: StringName, stroke: Color) -> void:
	var s := tile_px / float(LoomTokens.GLYPH_NATIVE)
	var sw := stroke_px(tile_px)
	ci.draw_set_transform(origin, 0.0, Vector2.ONE * s)
	_frame(ci, kind, stroke, sw)
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


static func frame_has_point(kind: StringName, origin: Vector2, tile_px: float, point: Vector2) -> bool:
	var s := tile_px / float(LoomTokens.GLYPH_NATIVE)
	var local := (point - origin) / s
	if kind == &"persona":
		return local.distance_to(Vector2(32, 32)) <= 28.0
	if kind == &"null":
		return Rect2(4, 4, 56, 56).has_point(local)
	return Rect2(4, 10, 56, 44).has_point(local)


static func _fade(c: Color, a: float) -> Color:
	var out := c
	out.a *= a
	return out


static func _task_ring(ci: CanvasItem, frame_kind: StringName, fade: float) -> void:
	var ring := _fade(LoomTokens.TASK, fade)
	ring.a *= 0.5
	if frame_kind == &"persona":
		ci.draw_arc(Vector2(32, 32), 32, 0.0, TAU, 48, ring, 1.0)
	else:
		ci.draw_rect(Rect2(0, 6, 64, 52), ring, false, 1.0)


static func _frame(ci: CanvasItem, kind: StringName, stroke: Color, sw: float) -> void:
	if kind == &"persona":
		ci.draw_arc(Vector2(32, 32), 28, 0.0, TAU, 48, stroke, sw)
		return
	ci.draw_rect(Rect2(4, 10, 56, 44), stroke, false, sw)
	if kind == &"tool":
		ci.draw_line(Vector2(11, 10), Vector2(11, 54), stroke, sw)
		ci.draw_line(Vector2(53, 10), Vector2(53, 54), stroke, sw)


static func _frame_null(ci: CanvasItem, stroke: Color, sw: float) -> void:
	var r := Rect2(4, 4, 56, 56)
	var dash := 4.0
	var pts := [r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]
	for i in 4:
		ci.draw_dashed_line(pts[i], pts[(i + 1) % 4], stroke, sw, dash)


static func _skin(ci: CanvasItem, skin: StringName, fill: Color, stroke: Color, sw: float) -> void:
	match skin:
		&"human":
			_human(ci, fill, stroke, sw)
		&"robot":
			_robot(ci, fill, stroke, sw)
		&"process":
			_process(ci, fill, stroke, sw)
		&"tool":
			_tool(ci, fill, stroke, sw)


static func _human(ci: CanvasItem, fill: Color, stroke: Color, sw: float) -> void:
	var head := Vector2(32, 24)
	var body := _human_body()
	if fill.a > 0:
		ci.draw_circle(head, 8, fill)
		ci.draw_colored_polygon(body, fill)
	ci.draw_arc(head, 8, 0.0, TAU, 32, stroke, sw)
	body.append(body[0])
	ci.draw_polyline(body, stroke, sw)


static func _human_body() -> PackedVector2Array:
	var pts := PackedVector2Array()
	pts.append(Vector2(17, 48))
	pts.append(Vector2(17, 44))
	for i in 7:
		var a := PI - i * (PI * 0.5 / 6.0)
		pts.append(Vector2(26, 44) + Vector2(cos(a), sin(a)) * 9.0)
	pts.append(Vector2(38, 35))
	for i in 7:
		var a := -PI * 0.5 + i * (PI * 0.5 / 6.0)
		pts.append(Vector2(38, 44) + Vector2(cos(a), sin(a)) * 9.0)
	pts.append(Vector2(47, 48))
	return pts


static func _robot(ci: CanvasItem, fill: Color, stroke: Color, sw: float) -> void:
	var head := Rect2(22, 14, 20, 18)
	var visor := Rect2(26, 20, 12, 4)
	var torso := Rect2(17, 36, 30, 12)
	if fill.a > 0:
		ci.draw_rect(head, fill)
		ci.draw_rect(torso, fill)
	ci.draw_rect(head, stroke, false, sw)
	if fill.a > 0:
		ci.draw_rect(visor, LoomTokens.BACKDROP)
	ci.draw_rect(visor, stroke, false, sw)
	ci.draw_line(Vector2(32, 14), Vector2(32, 9), stroke, sw)
	ci.draw_circle(Vector2(32, 7.5), 1.5, stroke)
	ci.draw_rect(torso, stroke, false, sw)


static func _process(ci: CanvasItem, fill: Color, stroke: Color, sw: float) -> void:
	ci.draw_line(Vector2(14, 32), Vector2(50, 32), stroke, sw)
	for cx in [18.0, 32.0, 46.0]:
		var box := Rect2(cx - 4.0, 28, 8, 8)
		if fill.a > 0:
			ci.draw_rect(box, fill)
		ci.draw_rect(box, stroke, false, sw)


static func _tool(ci: CanvasItem, fill: Color, stroke: Color, sw: float) -> void:
	var pts := _wrench_pts()
	if fill.a > 0:
		ci.draw_colored_polygon(pts, fill)
	pts.append(pts[0])
	ci.draw_polyline(pts, stroke, sw)


static func _wrench_pts() -> PackedVector2Array:
	var raw := PackedVector2Array()
	raw.append(Vector2(-3.5, 20))
	raw.append(Vector2(-3.5, -3.71))
	_append_arc(raw, Vector2(0, -12), 9.0, Vector2(-3.5, -3.71), Vector2(-3.0, -20.49), 8)
	raw.append(Vector2(-3.0, -12))
	raw.append(Vector2(3.0, -12))
	_append_arc(raw, Vector2(0, -12), 9.0, Vector2(3.0, -20.49), Vector2(3.5, -3.71), 8)
	raw.append(Vector2(3.5, 20))
	_append_arc(raw, Vector2(0, 20), 3.5, Vector2(3.5, 20), Vector2(-3.5, 20), 8)
	var out := PackedVector2Array()
	var rot := deg_to_rad(45)
	for p in raw:
		out.append(Vector2(32, 32) + p.rotated(rot) * 0.78)
	return out


static func _append_arc(pts: PackedVector2Array, c: Vector2, r: float, from: Vector2, to: Vector2, n: int) -> void:
	var a0 := (from - c).angle()
	var a1 := (to - c).angle()
	var delta := a1 - a0
	while delta > PI:
		delta -= TAU
	while delta < -PI:
		delta += TAU
	for i in range(1, n + 1):
		var a := a0 + delta * float(i) / float(n)
		pts.append(c + Vector2.from_angle(a) * r)
