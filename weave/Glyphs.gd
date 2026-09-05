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
	var head := Vector2(32, 22.5)
	if fill.a > 0:
		ci.draw_circle(head, 6.5, fill)
	ci.draw_arc(head, 6.5, 0.0, TAU, 32, stroke, sw)
	_round_rect(ci, Rect2(19.5, 32, 25, 13), 6.5, fill, stroke, sw)


static func _round_rect(ci: CanvasItem, r: Rect2, rad: float, fill: Color, stroke: Color, sw: float) -> void:
	rad = minf(rad, minf(r.size.x, r.size.y) * 0.5)
	var x0 := r.position.x
	var y0 := r.position.y
	var x1 := r.end.x
	var y1 := r.end.y
	if fill.a > 0:
		ci.draw_rect(Rect2(x0 + rad, y0, r.size.x - 2.0 * rad, r.size.y), fill)
		ci.draw_rect(Rect2(x0, y0 + rad, r.size.x, r.size.y - 2.0 * rad), fill)
		ci.draw_circle(Vector2(x0 + rad, y0 + rad), rad, fill)
		ci.draw_circle(Vector2(x1 - rad, y0 + rad), rad, fill)
		ci.draw_circle(Vector2(x1 - rad, y1 - rad), rad, fill)
		ci.draw_circle(Vector2(x0 + rad, y1 - rad), rad, fill)
	ci.draw_line(Vector2(x0 + rad, y0), Vector2(x1 - rad, y0), stroke, sw)
	ci.draw_line(Vector2(x1, y0 + rad), Vector2(x1, y1 - rad), stroke, sw)
	ci.draw_line(Vector2(x1 - rad, y1), Vector2(x0 + rad, y1), stroke, sw)
	ci.draw_line(Vector2(x0, y1 - rad), Vector2(x0, y0 + rad), stroke, sw)
	ci.draw_arc(Vector2(x0 + rad, y0 + rad), rad, PI, PI * 1.5, 12, stroke, sw)
	ci.draw_arc(Vector2(x1 - rad, y0 + rad), rad, -PI * 0.5, 0.0, 12, stroke, sw)
	ci.draw_arc(Vector2(x1 - rad, y1 - rad), rad, 0.0, PI * 0.5, 12, stroke, sw)
	ci.draw_arc(Vector2(x0 + rad, y1 - rad), rad, PI * 0.5, PI, 12, stroke, sw)


static func _robot(ci: CanvasItem, fill: Color, stroke: Color, sw: float) -> void:
	var head := Rect2(23, 20.5, 18, 15.5)
	var visor := Rect2(26.5, 25.5, 11, 4)
	var torso := Rect2(21, 38, 22, 11.5)
	ci.draw_circle(Vector2(32, 16.5), 1.6, stroke)
	ci.draw_line(Vector2(32, 18), Vector2(32, 20.5), stroke, sw)
	if fill.a > 0:
		ci.draw_rect(head, fill)
		ci.draw_rect(torso, fill)
	ci.draw_rect(head, stroke, false, sw)
	if fill.a > 0:
		ci.draw_rect(visor, LoomTokens.BACKDROP)
	ci.draw_rect(visor, stroke, false, sw)
	ci.draw_rect(torso, stroke, false, sw)


static func _process(ci: CanvasItem, fill: Color, stroke: Color, sw: float) -> void:
	ci.draw_line(Vector2(13, 32), Vector2(51, 32), stroke, sw)
	for cx in [18.0, 32.0, 46.0]:
		var box := Rect2(cx - 5.0, 27, 10, 10)
		ci.draw_rect(box, LoomTokens.BACKDROP)
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
	var R := 11.0
	var ri := 5.6
	var w := 4.4
	var j := Vector2(0, -7.2)
	var ah := deg_to_rad(40.0)
	var a0 := -PI * 0.5 - ah
	var a1 := -PI * 0.5 + ah
	var y_join := j.y + sqrt(R * R - w * w)
	var hy := 16.8
	var ol := j + Vector2.from_angle(a0) * R
	var orr := j + Vector2.from_angle(a1) * R
	var il := j + Vector2.from_angle(a0) * ri
	var ir := j + Vector2.from_angle(a1) * ri
	var raw := PackedVector2Array()
	raw.append(Vector2(-w, hy))
	raw.append(Vector2(-w, y_join))
	_append_arc(raw, j, R, Vector2(-w, y_join), ol, 12)
	raw.append(il)
	_append_arc(raw, j, ri, il, ir, 18, true)
	raw.append(orr)
	_append_arc(raw, j, R, orr, Vector2(w, y_join), 12)
	raw.append(Vector2(w, hy))
	_append_arc(raw, Vector2(0, hy), w, Vector2(w, hy), Vector2(-w, hy), 8)
	if raw.size() > 1 and raw[raw.size() - 1].distance_to(raw[0]) < 0.05:
		raw.remove_at(raw.size() - 1)
	var out := PackedVector2Array()
	var rot := deg_to_rad(45)
	for p in raw:
		out.append(Vector2(32, 32) + p.rotated(rot) * 0.86)
	return out


static func _append_arc(pts: PackedVector2Array, c: Vector2, r: float, from: Vector2, to: Vector2, n: int, long_way: bool = false) -> void:
	var a0 := (from - c).angle()
	var a1 := (to - c).angle()
	var delta := a1 - a0
	while delta > PI:
		delta -= TAU
	while delta < -PI:
		delta += TAU
	if long_way:
		if delta > 0.0:
			delta -= TAU
		elif delta < 0.0:
			delta += TAU
	for i in range(1, n + 1):
		var a := a0 + delta * float(i) / float(n)
		pts.append(c + Vector2.from_angle(a) * r)
