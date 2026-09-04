class_name Monitor
extends Control

## Read-only monitor. Spine on the top border, PDCA line under it,
## this repo's tree in the middle, node detail on the right.
## Does not write. Gear and loadout stay on the interface track.

var _loader := TreeLoader.new()
var _focus: Dictionary = {}
var _crumbs: HBoxContainer
var _pdca: Label
var _rows: VBoxContainer
var _title: Label
var _meta: Label
var _closeout: Label


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build()
	_load_tree()


func focused_name() -> String:
	return str(_focus.get("name", ""))


func pdca_line() -> String:
	return _pdca.text if _pdca else ""


func detail_text() -> String:
	return _closeout.text if _closeout else ""


func focus_guid(guid: String) -> bool:
	if not _loader.by_guid.has(guid):
		return false
	_show(_loader.by_guid[guid])
	return true


func _build() -> void:
	var pad := MarginContainer.new()
	pad.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pad.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for side in [&"margin_left", &"margin_right", &"margin_top"]:
		pad.add_theme_constant_override(side, LoomTokens.INSET)
	pad.add_theme_constant_override(&"margin_bottom", LoomTokens.panel_bottom_inset())
	add_child(pad)

	var col := VBoxContainer.new()
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_theme_constant_override(&"separation", LoomTokens.SPACE_3)
	pad.add_child(col)

	var spine := PanelContainer.new()
	spine.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_child(spine)

	var spine_pad := MarginContainer.new()
	for side in [&"margin_left", &"margin_right", &"margin_top", &"margin_bottom"]:
		spine_pad.add_theme_constant_override(side, LoomTokens.SPACE_3)
	spine.add_child(spine_pad)

	var spine_col := VBoxContainer.new()
	spine_col.add_theme_constant_override(&"separation", LoomTokens.SPACE_2)
	spine_pad.add_child(spine_col)

	_crumbs = HBoxContainer.new()
	_crumbs.add_theme_constant_override(&"separation", LoomTokens.SPACE_1)
	spine_col.add_child(_crumbs)

	_pdca = _label("", LoomTokens.V_TITLE)
	spine_col.add_child(_pdca)

	var body := HBoxContainer.new()
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override(&"separation", LoomTokens.SPACE_4)
	col.add_child(body)

	var tree_scroll := ScrollContainer.new()
	tree_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tree_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tree_scroll.size_flags_stretch_ratio = 3.0
	tree_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(tree_scroll)

	_rows = VBoxContainer.new()
	_rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_rows.add_theme_constant_override(&"separation", LoomTokens.SPACE_1)
	tree_scroll.add_child(_rows)

	var detail_scroll := ScrollContainer.new()
	detail_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	detail_scroll.size_flags_stretch_ratio = 2.0
	detail_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(detail_scroll)

	var detail := VBoxContainer.new()
	detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail.add_theme_constant_override(&"separation", LoomTokens.SPACE_2)
	detail_scroll.add_child(detail)

	_title = _label("", LoomTokens.V_TITLE)
	detail.add_child(_title)
	_meta = _label("", LoomTokens.V_MUTED)
	detail.add_child(_meta)
	_closeout = _label("", "")
	_closeout.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail.add_child(_closeout)


func _load_tree() -> void:
	var path := "res://"
	if not _loader.load_tree(path):
		_pdca.text = _loader.error
		return
	var start: Dictionary = _loader.root
	for node in _loader.nodes:
		if _phase(node) == "DO":
			start = node
			break
	_show(start)


func _show(node: Dictionary) -> void:
	_focus = node
	_fill_spine()
	_fill_pdca()
	_fill_rows()
	_fill_detail()


func _fill_spine() -> void:
	for child in _crumbs.get_children():
		child.queue_free()
	var chain: Array = _loader.path_of(_focus)
	for i in chain.size():
		if i > 0:
			_crumbs.add_child(_label(" / ", LoomTokens.V_MUTED))
		var step: Dictionary = chain[i]
		var crumb := Button.new()
		crumb.text = str(step.get("name", "?"))
		crumb.theme_type_variation = (
			LoomTokens.V_ROW_DIM if i < chain.size() - 1 else LoomTokens.V_ROW
		)
		crumb.pressed.connect(_show.bind(step))
		_crumbs.add_child(crumb)


func _fill_pdca() -> void:
	var parts: PackedStringArray = PackedStringArray()
	var ordered: Array = _loader.nodes.duplicate()
	ordered.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return str(a.get("name", "")) < str(b.get("name", ""))
	)
	for node in ordered:
		var phase := _phase(node)
		if phase == "":
			continue
		if str(node.get("state", "")) not in ["open", "active"]:
			continue
		parts.append("%s  %s" % [node.get("name", "?"), phase])
	_pdca.text = "  ·  ".join(parts) if not parts.is_empty() else "no open PDCA"


func _fill_rows() -> void:
	for child in _rows.get_children():
		child.queue_free()
	var ordered: Array = _loader.nodes.duplicate()
	ordered.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return _path_key(a) < _path_key(b)
	)
	for node in ordered:
		_rows.add_child(_row(node))


func _row(node: Dictionary) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", LoomTokens.SPACE_2)
	var depth: int = _loader.depth_of(node)
	if depth > 0:
		var spacer := Control.new()
		spacer.custom_minimum_size = Vector2(depth * LoomTokens.SPACE_5, 0)
		spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(spacer)
	var b := Button.new()
	var mark := "·  " if str(node.get("guid", "")) == str(_focus.get("guid", "")) else ""
	var phase := _phase(node)
	var extra := "  " + phase if phase != "" else ""
	b.text = "%s%s  %s%s" % [mark, node.get("name", "?"), node.get("state", "—"), extra]
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var dim := str(node.get("state", "")) in ["done", "abandoned", "superseded"]
	b.theme_type_variation = LoomTokens.V_ROW_DIM if dim else LoomTokens.V_ROW
	b.pressed.connect(_show.bind(node))
	row.add_child(b)
	return row


func _fill_detail() -> void:
	_title.text = str(_focus.get("name", ""))
	var bits: PackedStringArray = PackedStringArray()
	for key in ["type", "state"]:
		var val := str(_focus.get(key, ""))
		if val != "":
			bits.append(val)
	var phase := _phase(_focus)
	if phase != "":
		bits.append(phase)
	_meta.text = " · ".join(bits)
	var lines: PackedStringArray = PackedStringArray()
	for pair in [
		["just did", "justDid"],
		["next", "next"],
		["waiting on", "waitingOn"],
		["body", "body"],
	]:
		var text := str(_focus.get(pair[1], "")).strip_edges()
		if text != "":
			lines.append("%s\n%s" % [pair[0], text])
	_closeout.text = "\n\n".join(lines) if not lines.is_empty() else "no close-out on this node"


func _path_key(node: Dictionary) -> String:
	var names := PackedStringArray()
	for step in _loader.path_of(node):
		names.append(str(step.get("name", "")))
	return "/".join(names)


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


func _label(text: String, variation: StringName) -> Label:
	var l := Label.new()
	l.text = text
	if variation != &"":
		l.theme_type_variation = variation
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l
