class_name Monitor
extends Control

## Read-only monitor: a transit map of this repo's tree on the black
## field. The path spine runs along the top border from this operation
## to the focused node. The middle is the tree, depth as rows, siblings
## in date order. Lived nodes are stations on a solid trail; nodes with
## no date yet are the ghost, dashed, the plan that keeps going. Where
## a node has both, it is a fork and wears an interchange ring. The
## focused node wears the task ring and speaks on a placard, bottom
## left. Click a station to focus it. Nothing here writes.
##
## Every colour and size is a LoomTokens value. Text draws with the
## Theme's default font at token sizes. The placard is a PanelContainer
## on the Theme's panel face, its labels on type variations.

var _loader := TreeLoader.new()
var _focus: Dictionary = {}
var _pdca_text := ""

# Layout, rebuilt by _layout() whenever focus or size changes.
var _rows: Array = []              # Array of Array[Dictionary], by depth
var _pos: Dictionary = {}          # guid -> Vector2
var _lived: Dictionary = {}        # guid -> bool
var _spine: Array = []             # path root..focus
var _spine_pos: Array = []         # Vector2 per spine step
var _trail: Array = []             # dated visible nodes in date order
var _forks: Dictionary = {}        # guid -> true

var _placard: PanelContainer
var _placard_title: Label
var _placard_meta: Label
var _placard_body: Label


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_placard()
	get_viewport().size_changed.connect(_relayout)
	_load_tree()


# --- public, read only ----------------------------------------------------

func focused_name() -> String:
	return str(_focus.get("name", ""))


## Every open node carrying a pdca prop, with its word. Drawn on the
## spine's right end.
func pdca_line() -> String:
	return _pdca_text


func detail_text() -> String:
	return _placard_body.text if _placard_body else ""


func focus_guid(guid: String) -> bool:
	if not _loader.by_guid.has(guid):
		return false
	_show(_loader.by_guid[guid])
	return true


## Names of the stations on screen, row by row. The trunk plus the
## children of every node on the focus path.
func visible_names() -> PackedStringArray:
	var out := PackedStringArray()
	for row in _rows:
		for node in row:
			out.append(str(node.get("name", "")))
	return out


## The station under a point, or an empty Dictionary.
func station_at(point: Vector2) -> Dictionary:
	var reach := float(LoomTokens.INTERCHANGE_R + LoomTokens.SPACE_2)
	for i in _spine.size():
		if _spine_pos[i].distance_to(point) <= reach:
			return _spine[i]
	for row in _rows:
		for node in row:
			if _pos[_guid(node)].distance_to(point) <= reach:
				return node
	return {}


# --- input ----------------------------------------------------------------

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var hit := station_at(event.position)
		if not hit.is_empty():
			_show(hit)
			accept_event()


# --- tree -----------------------------------------------------------------

func _load_tree() -> void:
	if not _loader.load_tree("res://"):
		_placard_title.text = _loader.error
		return
	_mark_lived(_loader.root)
	var start: Dictionary = _loader.root
	for node in _loader.nodes:
		if _phase(node) == "DO":
			start = node
			break
	_show(start)


## A node is lived when it or anything under it carries a date.
func _mark_lived(node: Dictionary) -> bool:
	var lived := _date(node) != ""
	for kid in _loader.kids(node):
		if _mark_lived(kid):
			lived = true
	_lived[_guid(node)] = lived
	return lived


func _show(node: Dictionary) -> void:
	_focus = node
	_fill_pdca()
	_fill_placard()
	_relayout()


func _relayout() -> void:
	_layout()
	_place_placard()
	queue_redraw()


# --- layout ----------------------------------------------------------------

func _layout() -> void:
	_rows.clear()
	_pos.clear()
	_spine = _loader.path_of(_focus)
	_spine_pos.clear()
	_trail.clear()
	_forks.clear()
	if _loader.root.is_empty():
		return

	var spine_y := float(LoomTokens.INSET + LoomTokens.STATION_R)
	for i in _spine.size():
		_spine_pos.append(Vector2(LoomTokens.INSET + LoomTokens.SPACE_5 + i * LoomTokens.SPINE_STEP, spine_y))

	# Visible: the root, then the children of every node on the path.
	var on_path := {}
	for step in _spine:
		on_path[_guid(step)] = true
	var row: Array = [_loader.root]
	while not row.is_empty():
		_rows.append(row)
		var next: Array = []
		for parent in row:
			if not on_path.has(_guid(parent)):
				continue
			var kids: Array = _loader.kids(parent).duplicate()
			kids.sort_custom(_by_date)
			next.append_array(kids)
		row = next

	# The root sits mid-field. Every other row is one parent's children
	# and centres under that parent, kept inside the field. A row tighter
	# than COL_W closes up, with two COL_W of room on the right for the
	# last angled sign.
	var vp := size
	var left := float(LoomTokens.INSET + LoomTokens.INTERCHANGE_R)
	var right := vp.x - LoomTokens.INSET - 2.0 * LoomTokens.COL_W
	for depth in _rows.size():
		var nodes: Array = _rows[depth]
		var n := nodes.size()
		var col := float(LoomTokens.COL_W)
		if n > 1:
			col = minf(col, (right - left) / (n - 1))
		var span := (n - 1) * col
		var centre := vp.x * 0.5
		var parent_guid := str(nodes[0].get("isPartOf", ""))
		if _pos.has(parent_guid):
			centre = _pos[parent_guid].x
		var x0 := clampf(centre - span * 0.5, left, maxf(left, right - span))
		var y := float(LoomTokens.SPINE_H + LoomTokens.ROW_H * 0.5 + depth * LoomTokens.ROW_H)
		for i in n:
			_pos[_guid(nodes[i])] = Vector2(x0 + i * col, y)

	for nodes in _rows:
		for node in nodes:
			if _date(node) != "":
				_trail.append(node)
	_trail.sort_custom(_by_date)

	for nodes in _rows:
		for node in nodes:
			var lived_kids := 0
			var ghost_kids := 0
			for kid in _loader.kids(node):
				if not _pos.has(_guid(kid)):
					continue
				if _lived.get(_guid(kid), false):
					lived_kids += 1
				else:
					ghost_kids += 1
			if lived_kids > 0 and ghost_kids > 0:
				_forks[_guid(node)] = true


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


# --- draw -----------------------------------------------------------------

func _draw() -> void:
	if _rows.is_empty():
		return
	var font := get_theme_default_font()
	_draw_edges()
	_draw_trail()
	_draw_spine(font)
	_draw_stations(font)
	_draw_pdca(font)


func _draw_spine(font: Font) -> void:
	var task: Color = LoomTokens.TASK
	var ghost: Color = LoomTokens.GHOST
	var last := _spine.size() - 1
	for i in range(1, _spine.size()):
		var a: Vector2 = _spine_pos[i - 1]
		var b: Vector2 = _spine_pos[i]
		if _lived.get(_guid(_spine[i]), false):
			draw_line(a, b, task, LoomTokens.LINE_W)
		else:
			draw_dashed_line(a, b, ghost, LoomTokens.GHOST_W, LoomTokens.DASH)
	for i in _spine.size():
		var p: Vector2 = _spine_pos[i]
		var step: Dictionary = _spine[i]
		_draw_mark(p, step, i == last, false)
		# Chamber sign, left edge on the station: the number, then the name.
		var num := "%02d" % (i + 1)
		var x := p.x - LoomTokens.STATION_R
		var y := p.y + LoomTokens.STATION_R + LoomTokens.SPACE_4
		draw_string(font, Vector2(x, y), num, HORIZONTAL_ALIGNMENT_LEFT, -1, LoomTokens.TEXT_SM, LoomTokens.DIM)
		var name_color: Color = LoomTokens.INK if i == last else LoomTokens.DIM
		draw_string(font, Vector2(x, y + LoomTokens.TEXT_SM + LoomTokens.SPACE_1), _sign(step), HORIZONTAL_ALIGNMENT_LEFT, -1, LoomTokens.TEXT_SM, name_color)


func _draw_pdca(font: Font) -> void:
	var x := size.x - LoomTokens.INSET
	var y := float(LoomTokens.INSET + LoomTokens.STATION_R * 2 + LoomTokens.SPACE_4 + LoomTokens.TEXT_SM + LoomTokens.SPACE_1)
	var entries := _pdca_entries()
	entries.reverse()
	for pair in entries:
		var word: String = pair[1]
		var label: String = pair[0].to_upper() + " · "
		var ww := font.get_string_size(word, HORIZONTAL_ALIGNMENT_LEFT, -1, LoomTokens.TEXT_SM).x
		var lw := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, LoomTokens.TEXT_SM).x
		x -= ww
		draw_string(font, Vector2(x, y), word, HORIZONTAL_ALIGNMENT_LEFT, -1, LoomTokens.TEXT_SM, LoomTokens.INK)
		x -= lw
		draw_string(font, Vector2(x, y), label, HORIZONTAL_ALIGNMENT_LEFT, -1, LoomTokens.TEXT_SM, LoomTokens.DIM)
		x -= LoomTokens.SPACE_5


func _draw_edges() -> void:
	var edge: Color = LoomTokens.EDGE
	var ghost: Color = LoomTokens.GHOST
	for depth in range(1, _rows.size()):
		var nodes: Array = _rows[depth]
		var by_parent := {}
		for node in nodes:
			var parent := str(node.get("isPartOf", ""))
			if not by_parent.has(parent):
				by_parent[parent] = []
			by_parent[parent].append(node)
		for parent_guid in by_parent:
			if not _pos.has(parent_guid):
				continue
			var pp: Vector2 = _pos[parent_guid]
			var kids: Array = by_parent[parent_guid]
			var bus_y: float = _pos[_guid(kids[0])].y - LoomTokens.BUS_UP
			var lived_min := pp.x
			var lived_max := pp.x
			var all_min := pp.x
			var all_max := pp.x
			for kid in kids:
				var kx: float = _pos[_guid(kid)].x
				all_min = minf(all_min, kx)
				all_max = maxf(all_max, kx)
				if _lived.get(_guid(kid), false):
					lived_min = minf(lived_min, kx)
					lived_max = maxf(lived_max, kx)
			var parent_lived: bool = _lived.get(parent_guid, false)
			if parent_lived:
				draw_line(Vector2(pp.x, pp.y + LoomTokens.STATION_R), Vector2(pp.x, bus_y), edge, LoomTokens.EDGE_W)
			else:
				draw_dashed_line(Vector2(pp.x, pp.y + LoomTokens.STATION_R), Vector2(pp.x, bus_y), ghost, LoomTokens.GHOST_W, LoomTokens.DASH)
			# Solid where the lived children reach. Dashed on to the ghosts.
			draw_line(Vector2(lived_min, bus_y), Vector2(lived_max, bus_y), edge, LoomTokens.EDGE_W)
			if all_min < lived_min:
				draw_dashed_line(Vector2(lived_min, bus_y), Vector2(all_min, bus_y), ghost, LoomTokens.GHOST_W, LoomTokens.DASH)
			if all_max > lived_max:
				draw_dashed_line(Vector2(lived_max, bus_y), Vector2(all_max, bus_y), ghost, LoomTokens.GHOST_W, LoomTokens.DASH)
			for kid in kids:
				var kp: Vector2 = _pos[_guid(kid)]
				var top := Vector2(kp.x, bus_y)
				var bottom := Vector2(kp.x, kp.y - LoomTokens.STATION_R)
				if _lived.get(_guid(kid), false):
					draw_line(top, bottom, edge, LoomTokens.EDGE_W)
				else:
					draw_dashed_line(top, bottom, ghost, LoomTokens.GHOST_W, LoomTokens.DASH)


## The actual path: every dated station in date order, one solid line.
func _draw_trail() -> void:
	var task: Color = LoomTokens.TASK
	for i in range(1, _trail.size()):
		var a: Vector2 = _pos[_guid(_trail[i - 1])]
		var b: Vector2 = _pos[_guid(_trail[i])]
		var points := PackedVector2Array()
		points.append(a)
		if absf(a.y - b.y) < 0.5:
			points.append(b)
		elif b.y > a.y:
			var bus_y := b.y - LoomTokens.BUS_UP
			points.append(Vector2(a.x, bus_y))
			points.append(Vector2(b.x, bus_y))
			points.append(b)
		else:
			var bus_y := a.y - LoomTokens.BUS_UP
			points.append(Vector2(a.x, bus_y))
			points.append(Vector2(b.x, bus_y))
			points.append(b)
		draw_polyline(points, task, LoomTokens.LINE_W)


func _draw_stations(font: Font) -> void:
	var focus_guid := _guid(_focus)
	for nodes in _rows:
		var angled: bool = nodes.size() > 1
		for node in nodes:
			var guid := _guid(node)
			var p: Vector2 = _pos[guid]
			_draw_mark(p, node, guid == focus_guid, _forks.has(guid))
			var color := _sign_color(node)
			var text := _sign(node)
			var phase := _phase(node)
			if phase != "" and _is_live(node):
				text += " · " + phase
			if angled:
				draw_set_transform(Vector2(p.x + LoomTokens.SPACE_2, p.y + LoomTokens.SPACE_3), deg_to_rad(float(LoomTokens.SIGN_ANGLE)))
				draw_string(font, Vector2.ZERO, text, HORIZONTAL_ALIGNMENT_LEFT, -1, LoomTokens.TEXT_SM, color)
				draw_set_transform(Vector2.ZERO)
			else:
				var x := p.x + LoomTokens.INTERCHANGE_R + LoomTokens.SPACE_2
				draw_string(font, Vector2(x, p.y + LoomTokens.SPACE_1), text, HORIZONTAL_ALIGNMENT_LEFT, -1, LoomTokens.TEXT_SM, color)


## One station: circle for most, square for a plan. Filled ink when
## live, dim when done, hollow dashed ghost when not yet lived. A fork
## wears an ink ring; the focus wears the task ring.
func _draw_mark(p: Vector2, node: Dictionary, focused: bool, fork: bool) -> void:
	var r := float(LoomTokens.STATION_R)
	var square := str(node.get("type", "")) == "plan"
	if not _lived.get(_guid(node), false):
		_draw_ghost_mark(p, r, square)
	else:
		var fill: Color = LoomTokens.INK if _is_live(node) else LoomTokens.DIM
		if square:
			draw_rect(Rect2(p - Vector2(r, r), Vector2(2 * r, 2 * r)), fill)
		else:
			draw_circle(p, r, fill)
	if fork:
		draw_arc(p, LoomTokens.INTERCHANGE_R, 0.0, TAU, 32, LoomTokens.INK, LoomTokens.LINE_W)
	if focused:
		var ring := float(LoomTokens.INTERCHANGE_R + (LoomTokens.SPACE_1 if fork else 0))
		draw_arc(p, ring, 0.0, TAU, 32, LoomTokens.TASK, LoomTokens.LINE_W)


func _draw_ghost_mark(p: Vector2, r: float, square: bool) -> void:
	var ghost: Color = LoomTokens.GHOST
	if square:
		var corners := [Vector2(-r, -r), Vector2(r, -r), Vector2(r, r), Vector2(-r, r)]
		for i in 4:
			draw_dashed_line(p + corners[i], p + corners[(i + 1) % 4], ghost, LoomTokens.GHOST_W, 3.0)
		return
	var pieces := 8
	for i in pieces:
		var from := i * TAU / pieces
		draw_arc(p, r, from, from + TAU / (pieces * 2), 4, ghost, LoomTokens.GHOST_W)


# --- placard ----------------------------------------------------------------

func _build_placard() -> void:
	_placard = PanelContainer.new()
	_placard.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_placard)
	var pad := MarginContainer.new()
	for side in [&"margin_left", &"margin_right", &"margin_top", &"margin_bottom"]:
		pad.add_theme_constant_override(side, LoomTokens.SPACE_4)
	_placard.add_child(pad)
	var col := VBoxContainer.new()
	col.add_theme_constant_override(&"separation", LoomTokens.SPACE_2)
	pad.add_child(col)
	_placard_title = _label("", LoomTokens.V_TITLE)
	col.add_child(_placard_title)
	_placard_meta = _label("", LoomTokens.V_MUTED)
	col.add_child(_placard_meta)
	_placard_body = _label("", &"")
	col.add_child(_placard_body)


func _fill_placard() -> void:
	var depth := _loader.path_of(_focus).size()
	_placard_title.text = "%02d · %s" % [depth, _sign(_focus)]
	var bits := PackedStringArray()
	for key in ["type", "state"]:
		var val := str(_focus.get(key, ""))
		if val != "":
			bits.append(val)
	var phase := _phase(_focus)
	if phase != "":
		bits.append(phase)
	_placard_meta.text = " · ".join(bits)
	var lines := PackedStringArray()
	for pair in [["just did", "justDid"], ["next", "next"], ["waiting on", "waitingOn"], ["body", "body"]]:
		var text := str(_focus.get(pair[1], "")).strip_edges()
		if text != "":
			lines.append("%s\n%s" % [pair[0], text])
	_placard_body.text = "\n\n".join(lines) if not lines.is_empty() else "no close-out on this node"


## Two passes. Wrapped labels only know their height once the panel has
## laid out at PLACARD_W, so a second pass one frame on sets the height
## and lifts the placard off the bottom edge.
func _place_placard() -> void:
	_size_placard()
	_size_placard.call_deferred()


func _size_placard() -> void:
	_placard.custom_minimum_size = Vector2(LoomTokens.PLACARD_W, 0)
	_placard.size = Vector2(LoomTokens.PLACARD_W, _placard.get_combined_minimum_size().y)
	_placard.position = Vector2(LoomTokens.INSET, size.y - LoomTokens.INSET - _placard.size.y)


func _label(text: String, variation: StringName) -> Label:
	var l := Label.new()
	l.text = text
	if variation != &"":
		l.theme_type_variation = variation
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l


# --- readings ---------------------------------------------------------------

func _fill_pdca() -> void:
	var parts := PackedStringArray()
	for pair in _pdca_entries():
		parts.append("%s  %s" % [pair[0], pair[1]])
	_pdca_text = "  ·  ".join(parts) if not parts.is_empty() else "no open PDCA"


## [name, WORD] for every open node with a pdca prop, by name.
func _pdca_entries() -> Array:
	var out: Array = []
	var ordered: Array = _loader.nodes.duplicate()
	ordered.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return str(a.get("name", "")) < str(b.get("name", ""))
	)
	for node in ordered:
		var phase := _phase(node)
		if phase == "" or not _is_live(node):
			continue
		out.append([str(node.get("name", "?")), phase])
	return out


func _phase(node: Dictionary) -> String:
	var props: Variant = node.get("props", [])
	if typeof(props) != TYPE_ARRAY:
		return ""
	for item in props:
		if typeof(item) != TYPE_DICTIONARY:
			continue
		if str(item.get("name", "")) == "pdca":
			return str(item.get("value", "")).to_upper()
	return ""


func _is_live(node: Dictionary) -> bool:
	return str(node.get("state", "")) in ["open", "active"]


func _date(node: Dictionary) -> String:
	var d := str(node.get("actualStart", ""))
	return d if d != "" else str(node.get("actualEnd", ""))


func _sign(node: Dictionary) -> String:
	return str(node.get("name", "?")).to_upper()


func _sign_color(node: Dictionary) -> Color:
	if not _lived.get(_guid(node), false):
		return LoomTokens.GHOST
	return LoomTokens.INK if _is_live(node) else LoomTokens.DIM


func _path_key(node: Dictionary) -> String:
	var names := PackedStringArray()
	for step in _loader.path_of(node):
		names.append(str(step.get("name", "")))
	return "/".join(names)


static func _guid(node: Dictionary) -> String:
	return str(node.get("guid", ""))
