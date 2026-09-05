class_name LoomCanvas
extends Control

## The canvas: the surface the owner composes on, read from the tree.
## Inputs on the left, three rails: personas, processes, tools. Work in
## the middle, the field: the seat at slot 0, its ancestors as frames one
## slot back each, its siblings as closed tiles behind it. Outputs on the
## right: ports, unlabelled. The timeline runs along the bottom and the
## clock sits upper right, transparent.
##
## Draw order follows the slot spec: frames back to front, tiles, the
## seat, then the interface track. Tap looks, drag moves. Nothing here
## writes to the tree. Docked chips live in memory; a saved shape is a
## query in scripts/canvas_model.py.
##
## Rails read the three roster parents in the tree. A rail item is a
## child with props.rail matching the kind, shown by its folder name.
## An empty rail is a valid source.
##
## Every colour and size is a LoomTokens value. Text draws with the
## Theme's default font at token sizes.

signal persona_tapped(name: String)

const KINDS: Array[StringName] = [&"persona", &"process", &"tool"]
const ROSTER_OF := {
	&"persona": "personas",
	&"process": "processes",
	&"tool": "tools",
}
const RAIL_TITLES := {&"persona": "personas", &"process": "processes", &"tool": "tools"}
const PORTS := 3
const MONTHS := ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
const DAY := 86400
const NOW := -1.0

var _loader := TreeLoader.new()
var _error := ""
var _seat: Dictionary = {}
var _path: Array = []              # root .. seat
var _tiles: Array = []             # the seat's siblings, date order
var _docked: Dictionary = {}       # seat guid -> {kind: name}
var _last_unix := 0                # the last dated day in the tree
var _scrub := NOW                  # days from the scale's start, or NOW
var _bench_tex: Array[Texture2D] = []
var _bench_fill := 1               # part-filled: one bot in, two holes
var _bench_open := false

# Geometry, rebuilt by _layout().
var _field := Rect2()
var _frames: Array[Rect2] = []     # one per ancestor, outermost first
var _seat_rect := Rect2()
var _tile_rects: Array[Rect2] = []
var _more_rect := Rect2()
var _chip_rects: Dictionary = {}   # "kind/name" -> Rect2, on the rails
var _port_rects: Array[Rect2] = []
var _sockets: Dictionary = {}      # kind -> Vector2, on the seat's left edge
var _timeline := Rect2()
var _bench_rect := Rect2()
var _work_rect := Rect2()

# Pointer.
var _press := Vector2.INF
var _held: Dictionary = {}         # {kind, name, from: "rail"|"dock"}
var _drag_pos := Vector2.ZERO
var _dragging := false
var _scrubbing := false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	resized.connect(_relayout)
	_load_tree()
	_load_bench_skins()


# --- public, read only ------------------------------------------------------

func seat_name() -> String:
	return str(_seat.get("name", ""))


func seat_guid() -> String:
	return _guid(_seat)


func path_names() -> PackedStringArray:
	var out := PackedStringArray()
	for step in _path:
		out.append(str(step.get("name", "")))
	return out


func tile_names() -> PackedStringArray:
	var out := PackedStringArray()
	for node in _tiles:
		out.append(str(node.get("name", "")))
	return out


func rail_names(kind: StringName) -> PackedStringArray:
	var out := PackedStringArray()
	var parent := _roster_parent(str(ROSTER_OF.get(kind, "")))
	if parent.is_empty():
		return out
	var day := position_date()
	var kids: Array = _loader.kids(parent)
	kids.sort_custom(_by_date)
	for child in kids:
		if _present(child, day):
			out.append(_rail_label(child))
	return out


func port_count() -> int:
	return _port_rects.size()


func port_rect(i: int) -> Rect2:
	return _port_rects[i]


func chip_rect(kind: StringName, name: String) -> Rect2:
	return _chip_rects.get("%s/%s" % [kind, name], Rect2())


func socket_pos(kind: StringName) -> Vector2:
	return _sockets.get(kind, Vector2.INF)


func tile_rect(name: String) -> Rect2:
	for i in _tiles.size():
		if str(_tiles[i].get("name", "")) == name and i < _tile_rects.size():
			return _tile_rects[i]
	return Rect2()


func frame_rect(i: int) -> Rect2:
	return _frames[i]


func seat_rect() -> Rect2:
	return _seat_rect


func timeline_rect() -> Rect2:
	return _timeline


func bench_rect() -> Rect2:
	return _bench_rect


func work_rect() -> Rect2:
	return _work_rect if _bench_open else Rect2()


func bench_open() -> bool:
	return _bench_open


## What is docked on the seat: kind -> name.
func docked() -> Dictionary:
	return _docked.get(seat_guid(), {}).duplicate()


func focus_guid(guid: String) -> bool:
	if not _loader.by_guid.has(guid):
		return false
	_show(_loader.by_guid[guid])
	return true


## The date the timeline is at. The clock reads this.
func position_date() -> String:
	return Time.get_date_string_from_unix_time(_position_unix())


func at_now() -> bool:
	return _scrub == NOW


## A tap at a point. Looks, never moves.
func tap(point: Vector2) -> void:
	if _bench_rect.has_point(point):
		_bench_open = not _bench_open
		queue_redraw()
		return
	if _bench_open and _work_rect.has_point(point):
		return
	var tile := _tile_at(point)
	if not tile.is_empty():
		_show(tile)
		return
	var frame := _frame_at(point)
	if frame >= 0:
		_show(_path[frame])
		return
	var dock := _dock_at(point)
	if not dock.is_empty():
		if dock.kind == &"persona":
			persona_tapped.emit(dock.name)
		return
	if _on_timeline(point):
		_scrub_to(point.x)


## A drag from one point to another. Moves between slots.
func drag(from: Vector2, to: Vector2) -> void:
	_held = _grab_at(from)
	if _held.is_empty():
		return
	_drop(to)
	_held = {}
	_dragging = false
	queue_redraw()


# --- input --------------------------------------------------------------------

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_press = event.position
			_held = _grab_at(_press)
			_scrubbing = _held.is_empty() and _on_timeline(_press)
			if _scrubbing:
				_scrub_to(_press.x)
			accept_event()
		else:
			if _dragging:
				_drop(event.position)
			elif not _scrubbing and _press != Vector2.INF:
				tap(event.position)
			_press = Vector2.INF
			_held = {}
			_dragging = false
			_scrubbing = false
			queue_redraw()
			accept_event()
	elif event is InputEventMouseMotion and _press != Vector2.INF:
		if _scrubbing:
			_scrub_to(event.position.x)
		elif not _held.is_empty():
			_drag_pos = event.position
			if _dragging or _press.distance_to(event.position) > LoomTokens.SPACE_2:
				_dragging = true
				queue_redraw()
		accept_event()


## The thing under a point that a drag can carry: a rail chip, or a chip
## docked on the seat.
func _grab_at(point: Vector2) -> Dictionary:
	for key in _chip_rects:
		if (_chip_rects[key] as Rect2).has_point(point):
			var parts: PackedStringArray = key.split("/")
			return {"kind": StringName(parts[0]), "name": parts[1], "from": "rail"}
	return _dock_at(point)


func _dock_at(point: Vector2) -> Dictionary:
	var here: Dictionary = _docked.get(seat_guid(), {})
	for kind in here:
		if _dock_rect(kind).has_point(point):
			return {"kind": kind, "name": here[kind], "from": "dock"}
	return {}


func _tile_at(point: Vector2) -> Dictionary:
	for i in _tile_rects.size():
		if _tile_rects[i].has_point(point):
			return _tiles[i]
	return {}


## A frame answers to a tap on its label band, the strip under its top edge.
func _frame_at(point: Vector2) -> int:
	for i in range(_frames.size() - 1, -1, -1):
		var band := Rect2(_frames[i].position, Vector2(_frames[i].size.x, LoomTokens.SPACE_5 + LoomTokens.SPACE_4))
		if band.has_point(point):
			return i
	return -1


## A drop lands on the nearest socket within reach. It docks only when
## the socket is of the thing's kind; a persona socket takes a persona.
func _drop(point: Vector2) -> void:
	var kind: StringName = _held.kind
	var nearest := _socket_at(point)
	if nearest != &"":
		if nearest == kind:
			_dock(kind, _held.name)
		return
	if _held.from == "dock":
		for port in _port_rects:
			if port.has_point(point):
				_undock(kind)
				return


func _socket_at(point: Vector2) -> StringName:
	var best := &""
	var best_d := float(LoomTokens.TOUCH_H)
	for kind in _sockets:
		var d: float = (_sockets[kind] as Vector2).distance_to(point)
		if d <= best_d:
			best_d = d
			best = kind
	return best


func _dock(kind: StringName, name: String) -> void:
	var guid := seat_guid()
	if not _docked.has(guid):
		_docked[guid] = {}
	_docked[guid][kind] = name
	queue_redraw()


func _undock(kind: StringName) -> void:
	var guid := seat_guid()
	if _docked.has(guid):
		_docked[guid].erase(kind)
	queue_redraw()


func _on_timeline(point: Vector2) -> bool:
	return _timeline.grow(LoomTokens.SPACE_2).has_point(point)


## The last handle's width at the right end is now.
func _scrub_to(x: float) -> void:
	if x >= _timeline.end.x - LoomTokens.HANDLE_W:
		_scrub = NOW
	else:
		var frac := clampf((x - _timeline.position.x) / _timeline.size.x, 0.0, 1.0)
		_scrub = frac * LoomTokens.TIMELINE_DAYS
	_relayout()


# --- tree ---------------------------------------------------------------------

func _load_tree() -> void:
	if not _loader.load_tree("res://"):
		_error = _loader.error
		_relayout()
		return
	_collect_dates()
	_show(_start_node())


## Where the seat is: the node in Do, else the latest live node, deepest
## on a tie, else the root.
func _start_node() -> Dictionary:
	for node in _loader.nodes:
		if _phase(node) == "DO" and _is_live(node):
			return node
	var best: Dictionary = _loader.root
	for node in _loader.nodes:
		if not _is_live(node):
			continue
		var later := _date(node) > _date(best)
		var deeper := _date(node) == _date(best) and _loader.depth_of(node) > _loader.depth_of(best)
		if later or deeper:
			best = node
	return best


func _show(node: Dictionary) -> void:
	_seat = node
	_path = _loader.path_of(node)
	_tiles.clear()
	var parent: Dictionary = _path[_path.size() - 2] if _path.size() > 1 else _seat
	for kid in _loader.kids(parent):
		if _guid(kid) != seat_guid():
			_tiles.append(kid)
	_tiles.sort_custom(_by_date)
	_relayout()


func _collect_dates() -> void:
	_last_unix = 0
	for node in _loader.nodes:
		var d := _date(node)
		if d != "":
			_last_unix = maxi(_last_unix, _unix(d))
	if _last_unix == 0:
		_last_unix = _unix(Time.get_date_string_from_system())


func _relayout() -> void:
	_layout()
	queue_redraw()


# --- layout -------------------------------------------------------------------

func _layout() -> void:
	var inset := float(LoomTokens.INSET)
	var rail_w := float(LoomTokens.RAIL_W)
	var tl_top := size.y - inset - LoomTokens.GEAR_SIZE - LoomTokens.SPACE_3 - LoomTokens.TIMELINE_H
	_timeline = Rect2(inset + rail_w + LoomTokens.SPACE_4, tl_top, size.x - 2.0 * (inset + rail_w + LoomTokens.SPACE_4), LoomTokens.TIMELINE_H)
	_field = Rect2(_timeline.position.x, LoomTokens.FIELD_TOP, _timeline.size.x, tl_top - LoomTokens.SPACE_4 - LoomTokens.FIELD_TOP)
	_layout_rails()
	_layout_ports()
	_layout_field()
	_layout_bench()


func _layout_rails() -> void:
	_chip_rects.clear()
	var band := _field.size.y / KINDS.size()
	for i in KINDS.size():
		var kind: StringName = KINDS[i]
		var y0 := _field.position.y + i * band
		var names := rail_names(kind)
		for j in names.size():
			var cy := y0 + LoomTokens.SPACE_5 + LoomTokens.SPACE_2 + j * (LoomTokens.TOUCH_H + LoomTokens.SPACE_2)
			_chip_rects["%s/%s" % [kind, names[j]]] = Rect2(LoomTokens.INSET, cy, LoomTokens.RAIL_W, LoomTokens.TOUCH_H)


func _layout_ports() -> void:
	_port_rects.clear()
	var px := size.x - LoomTokens.INSET - LoomTokens.RAIL_W
	var stack := PORTS * LoomTokens.TOUCH_H + (PORTS - 1) * LoomTokens.SPACE_2
	var y0 := _field.get_center().y - stack * 0.5
	for j in PORTS:
		_port_rects.append(Rect2(px, y0 + j * (LoomTokens.TOUCH_H + LoomTokens.SPACE_2), LoomTokens.RAIL_W, LoomTokens.TOUCH_H))


func _layout_field() -> void:
	_frames.clear()
	_tile_rects.clear()
	_sockets.clear()
	_more_rect = Rect2()
	var inner := _field.grow(-LoomTokens.SPACE_5)
	for i in range(_path.size() - 1):
		_frames.append(inner)
		inner = inner.grow(-LoomTokens.FRAME_STEP)
	var seat_w := minf(LoomTokens.SEAT_W, inner.size.x - 2.0 * LoomTokens.SPACE_5)
	var seat_x := _field.get_center().x - seat_w * 0.5
	var seat_y := inner.position.y + 2.0 * LoomTokens.SPACE_5 + LoomTokens.SPACE_4
	_seat_rect = Rect2(seat_x, seat_y, seat_w, LoomTokens.SEAT_H)
	for k in KINDS.size():
		_sockets[KINDS[k]] = Vector2(seat_x, seat_y + LoomTokens.SEAT_HEAD - LoomTokens.SPACE_4 + k * LoomTokens.SOCKET_STEP)
	# Closed windows behind the seat, along the innermost frame's foot.
	var ty := inner.end.y - LoomTokens.SPACE_5 - LoomTokens.TILE_H
	var tx := inner.position.x + LoomTokens.SPACE_4
	var room := inner.end.x - LoomTokens.SPACE_4 - tx
	var step := LoomTokens.TILE_W + LoomTokens.SPACE_2
	var fit := int(room / step)
	if fit < _tiles.size():
		fit = int((room - LoomTokens.TILE_MORE_W - LoomTokens.SPACE_2) / step)
	fit = clampi(fit, 0, _tiles.size())
	for i in fit:
		_tile_rects.append(Rect2(tx + i * step, ty, LoomTokens.TILE_W, LoomTokens.TILE_H))
	if fit < _tiles.size():
		_more_rect = Rect2(tx + fit * step, ty, LoomTokens.TILE_MORE_W, LoomTokens.TILE_H)


func _layout_bench() -> void:
	# Upper-left of the field, left of the seat. Expands down into a
	# small flowchart rect: the opened shell, not a second window.
	var g := float(LoomTokens.GLYPH_TILE)
	_bench_rect = Rect2(_field.position.x + LoomTokens.SPACE_2, _field.position.y + LoomTokens.SPACE_2, g, g)
	_work_rect = Rect2(
		_bench_rect.position.x,
		_bench_rect.end.y + LoomTokens.SPACE_2,
		LoomTokens.WORK_BOX_W,
		LoomTokens.WORK_BOX_H
	)


func _load_bench_skins() -> void:
	_bench_tex.clear()
	for i in 4:
		var path := "res://weave/assets/glyphs/bench_%d.png" % i
		var bytes := FileAccess.get_file_as_bytes(path)
		if bytes.is_empty():
			_bench_tex.append(null)
			continue
		var img := Image.new()
		if img.load_png_from_buffer(bytes) != OK:
			_bench_tex.append(null)
			continue
		_bench_tex.append(ImageTexture.create_from_image(img))


func _dock_rect(kind: StringName) -> Rect2:
	var s: Vector2 = _sockets.get(kind, Vector2.INF)
	return Rect2(s.x - LoomTokens.CHIP_W * 0.5, s.y - LoomTokens.CHIP_H * 0.5, LoomTokens.CHIP_W, LoomTokens.CHIP_H)


# --- draw ---------------------------------------------------------------------

func _draw() -> void:
	var font := get_theme_default_font()
	if _error != "":
		draw_string(font, Vector2(LoomTokens.INSET, LoomTokens.INSET + LoomTokens.TEXT_MD), _error, HORIZONTAL_ALIGNMENT_LEFT, -1, LoomTokens.TEXT_MD, LoomTokens.DIM)
		return
	_draw_frames(font)
	_draw_tiles(font)
	_draw_seat(font)
	_draw_docks(font)
	_draw_rails(font)
	_draw_ports()
	_draw_clock(font)
	_draw_timeline(font)
	_draw_bench()
	_draw_carry(font)


## Ancestors, outermost first. Only the innermost is one slot back and
## draws solid; everything further is ghost.
func _draw_frames(font: Font) -> void:
	for i in _frames.size():
		var r := _frames[i]
		var slot := i - _frames.size()
		var last := i == _frames.size() - 1
		if last:
			_stroke(r, LoomTokens.DIM, LoomTokens.BORDER)
		else:
			_stroke_dashed(r, LoomTokens.GHOST, LoomTokens.GHOST_W)
		var color: Color = LoomTokens.DIM if last else LoomTokens.GHOST
		var y := r.position.y + LoomTokens.SPACE_5
		var x := r.position.x + LoomTokens.SPACE_4
		var step: Dictionary = _path[i]
		var w := _caps(font, Vector2(x, y), "%02d · %s" % [i + 1, _sign(step)], color)
		if last:
			_caps(font, Vector2(x + w + LoomTokens.SPACE_5, y), _meta(step), LoomTokens.GHOST)
		_caps(font, Vector2(r.end.x - LoomTokens.SPACE_4, y), "slot %d" % slot, LoomTokens.GHOST, HORIZONTAL_ALIGNMENT_RIGHT)


func _draw_tiles(font: Font) -> void:
	if _tiles.is_empty():
		return
	var head := _tile_rects[0] if not _tile_rects.is_empty() else _more_rect
	_caps(font, Vector2(head.position.x, head.position.y - LoomTokens.SPACE_3), "behind · %d" % _tiles.size(), LoomTokens.GHOST)
	var pos_unix := _position_unix()
	for i in _tile_rects.size():
		var r := _tile_rects[i]
		var node: Dictionary = _tiles[i]
		var yet := _date(node) == "" or _unix(_date(node)) <= pos_unix
		if not yet:
			_stroke_dashed(r, LoomTokens.GHOST, LoomTokens.BORDER)
			continue
		_stroke(r, LoomTokens.EDGE, LoomTokens.BORDER)
		var mark: Color = LoomTokens.INK if _is_live(node) else LoomTokens.DIM
		var c := Vector2(r.position.x + LoomTokens.SPACE_4, r.get_center().y)
		draw_circle(c, LoomTokens.SPACE_1, mark)
		var x := c.x + LoomTokens.SPACE_3
		_caps(font, Vector2(x, r.get_center().y + LoomTokens.SPACE_1), _fit(font, _sign(node), LoomTokens.TEXT_SM, r.end.x - LoomTokens.SPACE_2 - x), mark)
	if _more_rect.size.x > 0:
		_stroke_dashed(_more_rect, LoomTokens.EDGE, LoomTokens.BORDER)
		_caps(font, Vector2(_more_rect.get_center().x, _more_rect.get_center().y + LoomTokens.SPACE_1), "+%d" % (_tiles.size() - _tile_rects.size()), LoomTokens.DIM, HORIZONTAL_ALIGNMENT_CENTER)


## Slot 0. Surface fill, ink border, the accent along its top edge. The
## close-out is the largest type on screen.
func _draw_seat(font: Font) -> void:
	var r := _seat_rect
	draw_rect(r, LoomTokens.SURFACE)
	_stroke(r, LoomTokens.INK, LoomTokens.BORDER)
	draw_line(r.position, Vector2(r.end.x, r.position.y), LoomTokens.ACCENT, LoomTokens.LINE_W)
	var x := r.position.x + LoomTokens.SEAT_GUTTER
	var right := r.end.x - LoomTokens.SEAT_GUTTER
	var title_y := r.position.y + LoomTokens.SPACE_5 + LoomTokens.SPACE_4 + LoomTokens.SPACE_2
	draw_string(font, Vector2(x, title_y), "%02d · %s" % [_path.size(), _sign(_seat)], HORIZONTAL_ALIGNMENT_LEFT, -1, LoomTokens.TEXT_XL, LoomTokens.INK)
	_caps(font, Vector2(right, title_y - LoomTokens.SPACE_1), _meta(_seat), LoomTokens.DIM, HORIZONTAL_ALIGNMENT_RIGHT)
	_caps(font, Vector2(right, title_y + LoomTokens.SPACE_3), "slot 0", LoomTokens.GHOST, HORIZONTAL_ALIGNMENT_RIGHT)
	var y := r.position.y + LoomTokens.SEAT_HEAD
	var lines := [["just did", "justDid"], ["next", "next"], ["waiting on", "waitingOn"]]
	for k in lines.size():
		var pair: Array = lines[k]
		var by := y + k * LoomTokens.CLOSEOUT_STEP
		_caps(font, Vector2(x, by), pair[0], LoomTokens.DIM)
		var val := str(_seat.get(pair[1], "")).strip_edges()
		var ink: Color = LoomTokens.INK_HOVER if k == 1 else LoomTokens.INK
		if val == "":
			val = "—"
			ink = LoomTokens.DIM
		draw_multiline_string(font, Vector2(x, by + LoomTokens.SPACE_5 + LoomTokens.SPACE_2), val, HORIZONTAL_ALIGNMENT_LEFT, right - x, LoomTokens.TEXT_XL, 2, ink)
	# The seat carries the field's slots: sockets on its left edge, ports on its right.
	var here: Dictionary = _docked.get(seat_guid(), {})
	for kind in KINDS:
		if here.has(kind):
			continue
		_glyph(kind, _sockets[kind], LoomTokens.BACKDROP, LoomTokens.DIM)
	for k in KINDS.size():
		var py: float = _sockets[KINDS[k]].y - LoomTokens.SPACE_2
		_port_mouth(Rect2(r.end.x - LoomTokens.SPACE_2, py, 2 * LoomTokens.SPACE_2, LoomTokens.SPACE_4), LoomTokens.BACKDROP, LoomTokens.DIM, LoomTokens.DIM)


## What is docked on the seat, each with its leader back to the rail it
## came from. The leader is what makes it arrived rather than appeared.
func _draw_docks(font: Font) -> void:
	var here: Dictionary = _docked.get(seat_guid(), {})
	for kind in here:
		var name: String = here[kind]
		var chip := _dock_rect(kind)
		var origin := chip_rect(kind, name)
		if origin.size.x > 0:
			_leader(Vector2(origin.end.x, origin.get_center().y), Vector2(chip.position.x, chip.get_center().y))
		_chip(font, chip, kind, name, LoomTokens.INK, true)


func _draw_rails(font: Font) -> void:
	var band := _field.size.y / KINDS.size()
	for i in KINDS.size():
		var kind: StringName = KINDS[i]
		var y0 := _field.position.y + i * band
		_caps(font, Vector2(LoomTokens.INSET, y0 + LoomTokens.TEXT_SM), RAIL_TITLES[kind], LoomTokens.DIM)
		var rule_y := y0 + LoomTokens.SPACE_4 + LoomTokens.SPACE_1
		draw_line(Vector2(LoomTokens.INSET, rule_y), Vector2(LoomTokens.INSET + LoomTokens.RAIL_W, rule_y), LoomTokens.EDGE, LoomTokens.BORDER)
		for name in rail_names(kind):
			_chip(font, chip_rect(kind, name), kind, name, LoomTokens.EDGE, false)


## Three ports, the same drawing, open toward the field. No labels: which
## is which is still open, and the names that were tried fought the rules.
func _draw_ports() -> void:
	for r in _port_rects:
		_port_mouth(r, LoomTokens.WELL, LoomTokens.EDGE, LoomTokens.INK)


func _draw_clock(font: Font) -> void:
	var right := size.x - LoomTokens.INSET
	var y := float(LoomTokens.INSET + LoomTokens.TEXT_XL + LoomTokens.SPACE_1)
	var date := position_date()
	var dw := font.get_string_size(date, HORIZONTAL_ALIGNMENT_LEFT, -1, LoomTokens.TEXT_XL).x
	draw_string(font, Vector2(right - dw, y), date, HORIZONTAL_ALIGNMENT_LEFT, -1, LoomTokens.TEXT_XL, LoomTokens.INK)
	var under := y + LoomTokens.SPACE_4 + LoomTokens.SPACE_1
	var word := "now"
	if not at_now():
		var back := int((_last_unix - _position_unix()) / DAY) + 1
		word = "−%d d" % back
	var w := _caps(font, Vector2(right, under), word, LoomTokens.DIM, HORIZONTAL_ALIGNMENT_RIGHT)
	draw_rect(Rect2(right - w - LoomTokens.SPACE_4, under - LoomTokens.SPACE_2, LoomTokens.SPACE_2, LoomTokens.SPACE_2), LoomTokens.ACCENT)


## The scale: TIMELINE_DAYS days ending on the last dated day. Dated nodes
## are stations, spread through their day in path order. The selected
## period is the day the cursor is in.
func _draw_timeline(font: Font) -> void:
	var tl := _timeline
	var base := tl.get_center().y
	var days := LoomTokens.TIMELINE_DAYS
	var day_w := tl.size.x / days
	_caps(font, Vector2(tl.position.x, tl.position.y - LoomTokens.SPACE_2), "timeline · %d d" % days, LoomTokens.DIM)
	draw_line(Vector2(tl.position.x, base), Vector2(tl.end.x, base), LoomTokens.DIM, LoomTokens.BORDER)
	var sel := _selected_day()
	for i in days:
		var x := tl.position.x + i * day_w
		draw_line(Vector2(x, base - LoomTokens.SPACE_3), Vector2(x, base + LoomTokens.SPACE_3), LoomTokens.DIM, LoomTokens.BORDER)
		for h in range(1, 4):
			var hx := x + h * day_w / 4
			draw_line(Vector2(hx, base - LoomTokens.SPACE_1), Vector2(hx, base + LoomTokens.SPACE_1), LoomTokens.DIM, LoomTokens.BORDER)
		var color: Color = LoomTokens.INK if i == sel else LoomTokens.DIM
		_caps(font, Vector2(x + LoomTokens.SPACE_2, base + LoomTokens.SPACE_5 + LoomTokens.SPACE_1), _day_label(i), color)
	draw_line(Vector2(tl.end.x, base - LoomTokens.SPACE_3), Vector2(tl.end.x, base + LoomTokens.SPACE_3), LoomTokens.DIM, LoomTokens.BORDER)
	# Stations.
	var pos_unix := _position_unix()
	for i in days:
		var stations := _nodes_on_day(i)
		for k in stations.size():
			var x := tl.position.x + i * day_w + (k + 1) * day_w / (stations.size() + 1)
			var color: Color = LoomTokens.INK if i == sel else LoomTokens.DIM
			if _unix(_date(stations[k])) > pos_unix:
				color = LoomTokens.GHOST
			draw_circle(Vector2(x, base), LoomTokens.SPACE_1, color)
	# The selected period, with its handles.
	var sx0 := tl.position.x + sel * day_w
	var sel_rect := Rect2(sx0, base - LoomTokens.SPACE_4 - LoomTokens.SPACE_1, day_w, 2 * (LoomTokens.SPACE_4 + LoomTokens.SPACE_1))
	_stroke(sel_rect, LoomTokens.ACCENT, LoomTokens.BORDER)
	for hx in [sx0, sx0 + day_w]:
		draw_rect(Rect2(hx - LoomTokens.HANDLE_W * 0.5, base - LoomTokens.SPACE_5, LoomTokens.HANDLE_W, 2 * LoomTokens.SPACE_5), LoomTokens.ACCENT)
	# The cursor.
	var cx := tl.end.x if at_now() else tl.position.x + _scrub * day_w
	draw_line(Vector2(cx, tl.position.y - LoomTokens.SPACE_2), Vector2(cx, tl.end.y + LoomTokens.SPACE_2), LoomTokens.ACCENT, LoomTokens.LINE_W)
	draw_rect(Rect2(cx - LoomTokens.SPACE_2, tl.position.y - 2 * LoomTokens.SPACE_2, 2 * LoomTokens.SPACE_2, LoomTokens.SPACE_2), LoomTokens.ACCENT)


## Locked inner skin (bible 4.3). Tap opens the process shell: a
## flowchart rectangle, hairline only. Two verticals are the three
## bays. No fill — black is absence; that absence is the work space.
func _draw_bench() -> void:
	if _bench_fill >= 0 and _bench_fill < _bench_tex.size() and _bench_tex[_bench_fill] != null:
		draw_texture_rect(_bench_tex[_bench_fill], _bench_rect, false)
	else:
		_stroke(_bench_rect, LoomTokens.INK, LoomTokens.BORDER)
	if not _bench_open:
		return
	_stroke(_work_rect, LoomTokens.INK, LoomTokens.BORDER)
	var bay := _work_rect.size.x / 3.0
	for i in range(1, 3):
		var x := _work_rect.position.x + i * bay
		draw_line(Vector2(x, _work_rect.position.y), Vector2(x, _work_rect.end.y), LoomTokens.INK, LoomTokens.BORDER)


## The chip in hand during a drag, and its leader back to where it came from.
func _draw_carry(font: Font) -> void:
	if not _dragging or _held.is_empty():
		return
	var chip := Rect2(_drag_pos - Vector2(LoomTokens.CHIP_W, LoomTokens.CHIP_H) * 0.5, Vector2(LoomTokens.CHIP_W, LoomTokens.CHIP_H))
	var origin: Rect2 = chip_rect(_held.kind, _held.name) if _held.from == "rail" else _dock_rect(_held.kind)
	_leader(Vector2(origin.end.x, origin.get_center().y), Vector2(chip.position.x, chip.get_center().y))
	_chip(font, chip, _held.kind, _held.name, LoomTokens.INK, true)


# --- marks --------------------------------------------------------------------

## A rail chip or a docked chip: well fill, a glyph, a name in small caps.
func _chip(font: Font, r: Rect2, kind: StringName, name: String, border: Color, ringed: bool) -> void:
	draw_rect(r, LoomTokens.WELL)
	_stroke(r, border, LoomTokens.BORDER)
	var c := Vector2(r.position.x + LoomTokens.SPACE_4 + LoomTokens.SPACE_1, r.get_center().y)
	if ringed:
		_glyph(kind, c, LoomTokens.INK, LoomTokens.INK)
		draw_arc(c, LoomTokens.INTERCHANGE_R, 0.0, TAU, 32, LoomTokens.ACCENT, LoomTokens.GHOST_W)
	else:
		_glyph(kind, c, Color.TRANSPARENT, LoomTokens.INK)
	var x := c.x + LoomTokens.SPACE_4 + LoomTokens.SPACE_1
	_caps(font, Vector2(x, c.y + LoomTokens.SPACE_1 + 1), _fit(font, name, LoomTokens.TEXT_MD, r.end.x - LoomTokens.SPACE_2 - x), LoomTokens.INK, HORIZONTAL_ALIGNMENT_LEFT, LoomTokens.TEXT_MD)


## Persona is a circle, process a square, tool a diamond.
func _glyph(kind: StringName, c: Vector2, fill: Color, stroke: Color) -> void:
	var r := float(LoomTokens.STATION_R)
	var w := float(LoomTokens.GHOST_W)
	match kind:
		&"persona":
			if fill.a > 0:
				draw_circle(c, r, fill)
			draw_arc(c, r, 0.0, TAU, 32, stroke, w)
		&"process":
			var box := Rect2(c - Vector2(r, r), Vector2(2 * r, 2 * r))
			if fill.a > 0:
				draw_rect(box, fill)
			_stroke(box, stroke, w)
		_:
			var d := r + 1
			var pts := PackedVector2Array([c + Vector2(0, -d), c + Vector2(d, 0), c + Vector2(0, d), c + Vector2(-d, 0)])
			if fill.a > 0:
				draw_colored_polygon(pts, fill)
			pts.append(pts[0])
			draw_polyline(pts, stroke, w)


## A port: three sides drawn, the left open toward the field, two ticks at the mouth.
func _port_mouth(r: Rect2, fill: Color, edge: Color, tick: Color) -> void:
	draw_rect(r, fill)
	draw_polyline(PackedVector2Array([r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]), edge, LoomTokens.BORDER)
	draw_line(r.position, r.position + Vector2(LoomTokens.SPACE_2, 0), tick, LoomTokens.GHOST_W)
	draw_line(Vector2(r.position.x, r.end.y), Vector2(r.position.x + LoomTokens.SPACE_2, r.end.y), tick, LoomTokens.GHOST_W)


## Transit bends: out, across, in. Dashed accent, because it is motion
## between slots and not a thing in one.
func _leader(from: Vector2, to: Vector2) -> void:
	var mid_x := from.x + LoomTokens.SPACE_5
	var pts := [from, Vector2(mid_x, from.y), Vector2(mid_x, to.y), to]
	for i in range(1, pts.size()):
		draw_dashed_line(pts[i - 1], pts[i], LoomTokens.ACCENT, LoomTokens.GHOST_W, LoomTokens.DASH)


func _stroke(r: Rect2, color: Color, w: float) -> void:
	draw_rect(r, color, false, w)


func _stroke_dashed(r: Rect2, color: Color, w: float) -> void:
	var c := [r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]
	for i in 4:
		draw_dashed_line(c[i], c[(i + 1) % 4], color, w, LoomTokens.DASH)


## Small caps: upper case at the small size. Returns the width drawn.
func _caps(font: Font, pos: Vector2, text: String, color: Color, align := HORIZONTAL_ALIGNMENT_LEFT, size_px := LoomTokens.TEXT_SM) -> float:
	var s := text.to_upper()
	var w := font.get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px).x
	var x := pos.x
	if align == HORIZONTAL_ALIGNMENT_RIGHT:
		x -= w
	elif align == HORIZONTAL_ALIGNMENT_CENTER:
		x -= w * 0.5
	draw_string(font, Vector2(x, pos.y), s, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px, color)
	return w


## Trim a string to a width, with an ellipsis.
func _fit(font: Font, text: String, size_px: int, width: float) -> String:
	var s := text.to_upper()
	if font.get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px).x <= width:
		return s
	while s.length() > 1:
		s = s.left(s.length() - 1)
		if font.get_string_size(s + "…", HORIZONTAL_ALIGNMENT_LEFT, -1, size_px).x <= width:
			return s + "…"
	return s


# --- readings -----------------------------------------------------------------

func _position_unix() -> int:
	if at_now():
		return _last_unix + DAY - 1
	return _day_start(0) + int(_scrub * DAY)


func _selected_day() -> int:
	if at_now():
		return LoomTokens.TIMELINE_DAYS - 1
	return clampi(int(_scrub), 0, LoomTokens.TIMELINE_DAYS - 1)


func _day_start(i: int) -> int:
	return _last_unix - (LoomTokens.TIMELINE_DAYS - 1 - i) * DAY


func _day_label(i: int) -> String:
	var d := Time.get_datetime_dict_from_unix_time(_day_start(i))
	return "%s %02d" % [MONTHS[int(d.month) - 1], int(d.day)]


func _nodes_on_day(i: int) -> Array:
	var day := Time.get_date_string_from_unix_time(_day_start(i))
	var out: Array = []
	for node in _loader.nodes:
		if _date(node) == day:
			out.append(node)
	out.sort_custom(_by_date)
	return out


## Date order, undated last, ties in path order.
func _by_date(a: Dictionary, b: Dictionary) -> bool:
	var da := _date(a)
	var db := _date(b)
	if da == "" and db != "":
		return false
	if db == "" and da != "":
		return true
	if da != db:
		return da < db
	return _path_key(a) < _path_key(b)


func _meta(node: Dictionary) -> String:
	var bits := PackedStringArray()
	for key in ["type", "state"]:
		var val := str(node.get(key, ""))
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


func _date(node: Dictionary) -> String:
	var d := str(node.get("actualStart", ""))
	return d if d != "" else str(node.get("actualEnd", ""))


func _day_field(node: Dictionary, key: String) -> String:
	var d := str(node.get(key, ""))
	return d if d.length() == 10 else ""


## A node has begun by day if any lived date is on or before it.
func _begun(node: Dictionary, day: String) -> bool:
	var start := _day_field(node, "actualStart")
	if start != "":
		return start <= day
	var ended := _day_field(node, "actualEnd")
	if ended != "":
		return ended <= day
	var decided := _day_field(node, "decidedDate")
	if decided != "":
		return decided <= day
	return false


func _is_ghost(node: Dictionary, day: String) -> bool:
	if _begun(node, day):
		return false
	var start := _day_field(node, "actualStart")
	var ended := _day_field(node, "actualEnd")
	var decided := _day_field(node, "decidedDate")
	var planned := _day_field(node, "plannedStart")
	var planned_end := _day_field(node, "plannedEnd")
	if start == "" and ended == "" and decided == "" and planned == "" and planned_end == "":
		return true
	if planned != "" and planned <= day:
		return planned_end == "" or planned_end >= day
	return false


func _present(node: Dictionary, day: String) -> bool:
	return _begun(node, day) or _is_ghost(node, day)


func _prop(node: Dictionary, name: String) -> String:
	var props: Variant = node.get("props", [])
	if typeof(props) != TYPE_ARRAY:
		return ""
	for item in props:
		if typeof(item) == TYPE_DICTIONARY and str(item.get("name", "")) == name:
			return str(item.get("value", ""))
	return ""


func _roster_parent(rail: String) -> Dictionary:
	if rail == "":
		return {}
	for node in _loader.nodes:
		if _prop(node, "roster") == rail:
			return node
	return {}


## Folder name, titled. rosters/personas/brains → Brains.
func _rail_label(node: Dictionary) -> String:
	var path := str(node.get("_path", ""))
	var folder := path.get_base_dir().get_file()
	if folder != "":
		return folder.capitalize()
	var name := str(node.get("name", "?"))
	var bits := name.split("-")
	return str(bits[bits.size() - 1]).capitalize()


func _unix(date: String) -> int:
	return int(Time.get_unix_time_from_datetime_string(date))


func _sign(node: Dictionary) -> String:
	return str(node.get("name", "?")).to_upper()


func _path_key(node: Dictionary) -> String:
	var names := PackedStringArray()
	for step in _loader.path_of(node):
		names.append(str(step.get("name", "")))
	return "/".join(names)


static func _guid(node: Dictionary) -> String:
	return str(node.get("guid", ""))
