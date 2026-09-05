class_name LoomHere
extends Control

## Where am I. Bible 4.10: on arrival the field leads with the one
## thing that is yours. Black is absence (4.1). The task accent marks
## it (4.2). Name, close-out, one accent. No fill, no frame.
## The paused composition stays off the window.
##
## Seat: the live node in Do, else the root. Navigation is a later
## loop. Every colour and size is a LoomTokens value.

var _loader := TreeLoader.new()
var _seat: Dictionary = {}
var _error := ""


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_load_tree()


func seat_name() -> String:
	return str(_seat.get("name", ""))


func just_did() -> String:
	return str(_seat.get("justDid", "")).strip_edges()


func next_text() -> String:
	return str(_seat.get("next", "")).strip_edges()


func waiting_on() -> String:
	return str(_seat.get("waitingOn", "")).strip_edges()


func _load_tree() -> void:
	if not _loader.load_tree("res://"):
		_error = _loader.error
		queue_redraw()
		return
	_seat = _start_node()
	queue_redraw()


## The thing that is yours: the node in Do, else the root. Do not
## wander into the deepest open issue. That is not this loop.
func _start_node() -> Dictionary:
	for node in _loader.nodes:
		if _phase(node) == "DO" and _is_live(node):
			return node
	return _loader.root


func _draw() -> void:
	var font := get_theme_default_font()
	if _error != "":
		draw_string(font, Vector2(LoomTokens.INSET, LoomTokens.FIELD_TOP), _error, HORIZONTAL_ALIGNMENT_LEFT, -1, LoomTokens.TEXT_MD, LoomTokens.DIM)
		return
	if _seat.is_empty():
		return
	var x := float(LoomTokens.INSET + LoomTokens.SPACE_5)
	var title_y := float(LoomTokens.FIELD_TOP + LoomTokens.TEXT_XL)
	var width := size.x - 2.0 * x
	var title := "%02d · %s" % [_loader.path_of(_seat).size(), str(_seat.get("name", "?")).to_upper()]
	draw_string(font, Vector2(x, title_y), title, HORIZONTAL_ALIGNMENT_LEFT, -1, LoomTokens.TEXT_XL, LoomTokens.INK)
	var title_w := font.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, LoomTokens.TEXT_XL).x
	var meta := _meta(_seat)
	if meta != "":
		draw_string(font, Vector2(x + title_w + LoomTokens.SPACE_5, title_y), meta, HORIZONTAL_ALIGNMENT_LEFT, -1, LoomTokens.TEXT_SM, LoomTokens.DIM)
	var line_y := title_y + LoomTokens.SPACE_3
	draw_line(Vector2(x, line_y), Vector2(x + title_w, line_y), LoomTokens.TASK, LoomTokens.LINE_W)
	var y := float(LoomTokens.FIELD_TOP + LoomTokens.SEAT_HEAD)
	var rows := [["just did", just_did()], ["next", next_text()], ["waiting on", waiting_on()]]
	for i in rows.size():
		var pair: Array = rows[i]
		var by := y + i * LoomTokens.CLOSEOUT_STEP
		_caps(font, Vector2(x, by), pair[0], LoomTokens.DIM)
		var val: String = pair[1]
		var ink: Color = LoomTokens.INK_HOVER if i == 1 else LoomTokens.INK
		if val == "":
			val = "—"
			ink = LoomTokens.DIM
		draw_multiline_string(font, Vector2(x, by + LoomTokens.SPACE_5 + LoomTokens.SPACE_2), val, HORIZONTAL_ALIGNMENT_LEFT, width, LoomTokens.TEXT_XL, 3, ink)


func _caps(font: Font, pos: Vector2, text: String, color: Color) -> void:
	draw_string(font, pos, text.to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, LoomTokens.TEXT_SM, color)


func _meta(node: Dictionary) -> String:
	var bits := PackedStringArray()
	for key in ["type", "state"]:
		var val := str(node.get(key, "")).to_upper()
		if val != "":
			bits.append(val)
	var phase := _phase(node)
	if phase != "":
		bits.append(phase)
	return " · ".join(bits)


func _phase(node: Dictionary) -> String:
	var props: Variant = node.get("props", [])
	if typeof(props) != TYPE_ARRAY:
		return ""
	for item in props:
		if typeof(item) == TYPE_DICTIONARY and str(item.get("name", "")) == "pdca":
			return str(item.get("value", "")).to_upper()
	return ""


func _is_live(node: Dictionary) -> bool:
	return str(node.get("state", "")) in ["open", "active"]
