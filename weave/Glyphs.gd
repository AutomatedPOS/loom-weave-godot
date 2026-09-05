class_name LoomGlyphs
extends RefCounted

## The three noun marks. Bible 4.3 / 4.4: outer shape is the class,
## inner mark is the skin. Round is human, square is machine.
## Persona is one bust; a hat on that bust is the role. Process is a
## settled rectangle. Tool is a machine square with a wrench.
##
## Draw from any CanvasItem. Colours and sizes are tokens. Hollow
## (fill alpha 0) is not started; solid is done.

const HAT_NONE := &""
const HAT_ROLE := &"hat"
const KINDS: Array[StringName] = [&"persona", &"process", &"tool"]


static func draw_on(ci: CanvasItem, kind: StringName, c: Vector2, r: float, fill: Color, stroke: Color, hat: StringName = HAT_NONE) -> void:
	var w := maxf(1.0, r * 0.12)
	match kind:
		&"persona":
			_persona(ci, c, r, fill, stroke, w, hat)
		&"process":
			_process(ci, c, r, fill, stroke, w)
		_:
			_tool(ci, c, r, fill, stroke, w)


static func _persona(ci: CanvasItem, c: Vector2, r: float, fill: Color, stroke: Color, w: float, hat: StringName) -> void:
	var head_c := c + Vector2(0, -r * 0.22)
	var head_r := r * 0.32
	var neck := head_c.y + head_r * 0.55
	var hip := c.y + r * 0.82
	var body := PackedVector2Array([
		Vector2(c.x - head_r * 0.90, neck),
		Vector2(c.x - r * 0.80, hip),
		Vector2(c.x + r * 0.80, hip),
		Vector2(c.x + head_r * 0.90, neck),
	])
	if fill.a > 0:
		ci.draw_colored_polygon(body, fill)
		ci.draw_circle(head_c, head_r, fill)
	ci.draw_arc(head_c, head_r, 0.0, TAU, 32, stroke, w)
	body.append(body[0])
	ci.draw_polyline(body, stroke, w)
	if hat != HAT_NONE:
		_hat(ci, head_c, head_r, fill, stroke, w)


## A brim and a square crown. Same bust, different hat: that is a role.
static func _hat(ci: CanvasItem, head_c: Vector2, head_r: float, fill: Color, stroke: Color, w: float) -> void:
	var brim_y := head_c.y - head_r * 0.70
	var brim := Rect2(head_c.x - head_r * 1.35, brim_y - w, head_r * 2.7, w * 2.2)
	var crown := Rect2(head_c.x - head_r * 0.72, brim_y - head_r * 1.05, head_r * 1.44, head_r * 1.05)
	if fill.a > 0:
		ci.draw_rect(crown, fill)
		ci.draw_rect(brim, fill)
	ci.draw_rect(crown, stroke, false, w)
	ci.draw_rect(brim, stroke, false, w)


## Flowchart process: a settled rectangle. Three bars inside are the steps.
static func _process(ci: CanvasItem, c: Vector2, r: float, fill: Color, stroke: Color, w: float) -> void:
	var box := Rect2(c.x - r * 0.78, c.y - r * 0.52, r * 1.56, r * 1.04)
	if fill.a > 0:
		ci.draw_rect(box, fill)
	ci.draw_rect(box, stroke, false, w)
	var inner := stroke if fill.a < 0.5 else LoomTokens.BACKDROP
	var x0 := box.position.x + r * 0.22
	var x1 := box.end.x - r * 0.22
	for i in 3:
		var y := box.position.y + r * 0.28 + i * r * 0.24
		ci.draw_line(Vector2(x0, y), Vector2(x1 - (2 - i) * r * 0.12, y), inner, w)


## Machine square, wrench inside. The wrench is the skin; the square is the class.
static func _tool(ci: CanvasItem, c: Vector2, r: float, fill: Color, stroke: Color, w: float) -> void:
	var box := Rect2(c.x - r * 0.70, c.y - r * 0.70, r * 1.40, r * 1.40)
	if fill.a > 0:
		ci.draw_rect(box, fill)
	ci.draw_rect(box, stroke, false, w)
	var inner := stroke if fill.a < 0.5 else LoomTokens.BACKDROP
	var dir := Vector2(1, -1).normalized()
	var handle_a := c - dir * r * 0.46
	var handle_b := c + dir * r * 0.02
	ci.draw_line(handle_a, handle_b, inner, w * 1.8)
	var n := Vector2(-dir.y, dir.x)
	var jaw := handle_b + dir * r * 0.32
	var open := r * 0.22
	# Open C, mouth toward the handle: a wrench head, not a hammer.
	ci.draw_polyline(PackedVector2Array([
		handle_b + n * open,
		jaw + n * open,
		jaw - n * open,
		handle_b - n * open,
	]), inner, w)
