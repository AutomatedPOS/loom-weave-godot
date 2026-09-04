class_name LoadoutPanel
extends Control

## Interface-track loadout. Opens from the gear. No vendor. No chat.
signal caps_changed(all_green: bool)
signal minimized

const INK := Color(0.68, 0.68, 0.70, 1)
const DIM := Color(0.42, 0.42, 0.44, 1)
const PANEL := Color(0.04, 0.04, 0.045, 0.96)
const WELL := Color(0.10, 0.10, 0.11, 1)
const EDGE := Color(0.22, 0.22, 0.24, 1)

var loadout := Loadout.new()
var engine: ThemeEngine
var talk: TalkClient
var cap_state: Dictionary = {
	"chat": {"state": "grey", "reason": "", "ms": 0},
	"speech": {"state": "grey", "reason": "", "ms": 0},
	"hear": {"state": "grey", "reason": "", "ms": 0},
}
var _line_edits: Array[LineEdit] = []
var _status: Label
var _pick_cb: Callable
var _bg: ColorRect
var _frame: Array[ColorRect] = []
var _ink_labels: Array[Label] = []
var _dim_labels: Array[Label] = []
var _btns: Array[Button] = []
var _cap_labels: Dictionary = {}
var _validating := false


func bind(p_engine: ThemeEngine, p_talk: TalkClient) -> void:
	engine = p_engine
	talk = p_talk
	if engine and not engine.applied.is_connected(_skin):
		engine.applied.connect(_skin)
	if is_inside_tree():
		_skin()


func all_green() -> bool:
	for cap in ["chat", "speech", "hear"]:
		if str(cap_state[cap]["state"]) != "green":
			return false
	return true


func reset_caps() -> void:
	for cap in ["chat", "speech", "hear"]:
		cap_state[cap] = {"state": "grey", "reason": "", "ms": 0}
		_paint_cap(cap)
	caps_changed.emit(false)


func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build()
	_reload_from_store()
	_skin()


func toggle() -> void:
	if visible:
		close()
	else:
		open()


func open() -> void:
	if _line_edits.is_empty():
		_build()
	_reload_from_store()
	visible = true


func close() -> void:
	visible = false
	if _status:
		_status.text = ""
	minimized.emit()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()


func _reload_from_store() -> void:
	loadout.load_local()
	_write_fields(loadout.data)


func _build() -> void:
	if not _line_edits.is_empty():
		return
	_bg = ColorRect.new()
	_bg.color = PANEL
	_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_bg.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_bg)

	_draw_frame()

	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.offset_left = 16
	scroll.offset_top = 14
	scroll.offset_right = -16
	scroll.offset_bottom = -14
	add_child(scroll)

	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", 10)
	scroll.add_child(col)

	col.add_child(_label("loadout", 18, INK))
	col.add_child(_label("point each after deploy. nothing is in the base.", 12, DIM))

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	col.add_child(row)
	row.add_child(_button("Save", _on_save))
	row.add_child(_button("Export", _on_export))
	row.add_child(_button("Import", _on_import))
	row.add_child(_button("Validate", _on_validate))
	row.add_child(_button("Min", close))

	_status = _label("", 12, DIM)
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(_status)

	_line_edits.clear()
	col.add_child(_section("chat"))
	col.add_child(_section("speech"))
	col.add_child(_section("hear"))


func _draw_frame() -> void:
	_frame.clear()
	for preset in [
		Control.PRESET_TOP_WIDE,
		Control.PRESET_BOTTOM_WIDE,
		Control.PRESET_LEFT_WIDE,
		Control.PRESET_RIGHT_WIDE,
	]:
		var edge := ColorRect.new()
		edge.color = EDGE
		edge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		edge.set_anchors_preset(preset)
		match preset:
			Control.PRESET_TOP_WIDE:
				edge.offset_bottom = 1
			Control.PRESET_BOTTOM_WIDE:
				edge.offset_top = -1
			Control.PRESET_LEFT_WIDE:
				edge.offset_right = 1
			Control.PRESET_RIGHT_WIDE:
				edge.offset_left = -1
		add_child(edge)
		_frame.append(edge)


func _section(cap: String) -> VBoxContainer:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	box.add_child(_label(cap, 14, INK))
	var st := _label("grey · not yet tested", 12, DIM)
	_cap_labels[cap] = st
	box.add_child(st)
	for field in ["endpoint", "credential", "model"]:
		var edit := LineEdit.new()
		edit.name = "%s_%s" % [cap, field]
		edit.placeholder_text = field
		edit.secret = field == "credential"
		edit.custom_minimum_size = Vector2(0, 36)
		edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_style_edit(edit)
		box.add_child(edit)
		_line_edits.append(edit)
	return box


func _style_edit(edit: LineEdit) -> void:
	var well := engine.get_color("surface.base") if engine else WELL
	var edge := engine.get_color("border.subtle") if engine else EDGE
	var ink := engine.get_color("text.primary") if engine else INK
	var dim := engine.get_color("text.muted") if engine else DIM
	var focus_c := engine.get_color("focus.ring") if engine else ink
	var r := int(engine.get_number("radius.control")) if engine else 0
	var normal := StyleBoxFlat.new()
	normal.bg_color = well
	normal.border_color = edge
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(r)
	normal.content_margin_left = 8
	normal.content_margin_right = 8
	var focus := normal.duplicate()
	focus.border_color = focus_c
	edit.add_theme_stylebox_override("normal", normal)
	edit.add_theme_stylebox_override("focus", focus)
	edit.add_theme_color_override("font_color", ink)
	edit.add_theme_color_override("font_placeholder_color", dim)
	edit.add_theme_color_override("caret_color", ink)
	edit.add_theme_font_size_override("font_size", 14)


func _label(text: String, size: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if color == DIM:
		_dim_labels.append(l)
	else:
		_ink_labels.append(l)
	return l


func _button(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(88, 36)
	b.pressed.connect(cb)
	_btns.append(b)
	_style_button(b)
	return b


func _style_button(b: Button) -> void:
	var well := engine.get_color("surface.base") if engine else WELL
	var edge := engine.get_color("border.subtle") if engine else EDGE
	var ink := engine.get_color("text.primary") if engine else INK
	var hover_c := engine.get_color("accent.default") if engine else ink
	var r := int(engine.get_number("radius.control")) if engine else 0
	var normal := StyleBoxFlat.new()
	normal.bg_color = well
	normal.border_color = edge
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(r)
	normal.content_margin_left = 10
	normal.content_margin_right = 10
	var hover := normal.duplicate()
	hover.border_color = hover_c
	b.add_theme_stylebox_override("normal", normal)
	b.add_theme_stylebox_override("hover", hover)
	b.add_theme_stylebox_override("pressed", hover)
	b.add_theme_color_override("font_color", ink)
	b.add_theme_font_size_override("font_size", 14)


func _skin() -> void:
	if _bg == null:
		return
	if engine:
		_bg.color = engine.get_color("menu.panel.bg")
		for edge in _frame:
			edge.color = engine.get_color("menu.panel.border")
		for l in _ink_labels:
			l.add_theme_color_override("font_color", engine.get_color("text.primary"))
		for l in _dim_labels:
			l.add_theme_color_override("font_color", engine.get_color("text.muted"))
	for edit in _line_edits:
		_style_edit(edit)
	for b in _btns:
		_style_button(b)
	for cap in _cap_labels.keys():
		_paint_cap(str(cap))


func _paint_cap(cap: String) -> void:
	var lab: Label = _cap_labels.get(cap, null)
	if lab == null:
		return
	var block: Dictionary = cap_state[cap]
	var st := str(block.get("state", "grey"))
	var reason := str(block.get("reason", ""))
	var ms := int(block.get("ms", 0))
	var line := "%s · not yet tested" % st
	if st == "green":
		line = "green · %dms" % ms
	elif st == "red":
		line = "red · %s" % reason
	lab.text = line
	if engine == null:
		return
	match st:
		"green":
			lab.add_theme_color_override("font_color", engine.get_color("accent.default"))
		"red":
			lab.add_theme_color_override("font_color", engine.get_color("state.danger"))
		_:
			lab.add_theme_color_override("font_color", engine.get_color("text.muted"))


func _edit(cap: String, field: String) -> LineEdit:
	var caps := ["chat", "speech", "hear"]
	var fields := ["endpoint", "credential", "model"]
	var i := caps.find(cap)
	var j := fields.find(field)
	if i < 0 or j < 0:
		return null
	var idx := i * 3 + j
	if idx < 0 or idx >= _line_edits.size():
		return null
	return _line_edits[idx]


func _block(src: Dictionary, cap: String) -> Dictionary:
	var raw: Variant = src.get(cap, {})
	if typeof(raw) != TYPE_DICTIONARY:
		return Loadout.empty_cap()
	return raw


func _read_fields() -> Dictionary:
	var out := Loadout.empty_data()
	for cap in ["chat", "speech", "hear"]:
		var block := _block(out, cap)
		for field in ["endpoint", "credential", "model"]:
			var edit := _edit(cap, field)
			if edit:
				block[field] = edit.text
	return out


func _write_fields(src: Dictionary) -> void:
	for cap in ["chat", "speech", "hear"]:
		var block := _block(src, cap)
		for field in ["endpoint", "credential", "model"]:
			var edit := _edit(cap, field)
			if edit == null:
				push_error("missing field %s_%s edits=%d" % [cap, field, _line_edits.size()])
				continue
			edit.text = str(block.get(field, ""))


func _on_save() -> void:
	loadout.data = _read_fields()
	var err := loadout.save()
	if err != OK:
		_note("save failed")
		return
	_note("saved on this browser")
	await _on_validate()


func _on_validate() -> void:
	if talk == null or _validating:
		return
	_validating = true
	_note("validating")
	loadout.data = _read_fields()
	loadout.save()
	await _check_cap("chat")
	await _check_cap("speech")
	await _check_cap("hear")
	_validating = false
	if all_green():
		_note("all green")
	else:
		_note("validation finished")
	caps_changed.emit(all_green())


func _check_cap(cap: String) -> void:
	cap_state[cap] = {"state": "grey", "reason": "testing", "ms": 0}
	_paint_cap(cap)
	var res: Dictionary = {}
	match cap:
		"chat":
			res = await talk.validate_chat()
		"speech":
			res = await talk.validate_speech()
		"hear":
			res = await talk.validate_hear()
	if res.get("ok", false):
		cap_state[cap] = {"state": "green", "reason": "", "ms": int(res.get("ms", 0))}
	else:
		cap_state[cap] = {
			"state": "red",
			"reason": str(res.get("error", "failed")),
			"ms": int(res.get("ms", 0)),
		}
	_paint_cap(cap)


func _on_export() -> void:
	loadout.data = _read_fields()
	var text := loadout.to_text()
	if OS.has_feature("web") and Engine.has_singleton("JavaScriptBridge"):
		JavaScriptBridge.download_buffer(text.to_utf8_buffer(), "loadout.json", "application/json")
		_note("export wrote loadout.json")
		return
	_pick_cb = _export_picked
	var err := DisplayServer.file_dialog_show(
		"Export loadout",
		OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS),
		"loadout.json",
		false,
		DisplayServer.FILE_DIALOG_MODE_SAVE_FILE,
		PackedStringArray(["*.json ; Loadout"]),
		Callable(self, "_on_dialog")
	)
	if err != OK:
		var fallback := OS.get_user_data_dir().path_join("loadout.json")
		var fa := FileAccess.open(fallback, FileAccess.WRITE)
		if fa == null:
			_note("export failed")
			return
		fa.store_string(text)
		_note("export wrote %s" % fallback)


func _on_import() -> void:
	_pick_cb = _import_picked
	var err := DisplayServer.file_dialog_show(
		"Import loadout",
		"",
		"",
		false,
		DisplayServer.FILE_DIALOG_MODE_OPEN_FILE,
		PackedStringArray(["*.json ; Loadout"]),
		Callable(self, "_on_dialog")
	)
	if err != OK:
		_note("import picker failed")


func _on_dialog(status: bool, selected_paths: PackedStringArray, _filter: int) -> void:
	if not status or selected_paths.is_empty():
		return
	if _pick_cb.is_valid():
		_pick_cb.call(selected_paths[0])


func _export_picked(path: String) -> void:
	loadout.data = _read_fields()
	var fa := FileAccess.open(path, FileAccess.WRITE)
	if fa == null:
		_note("export failed")
		return
	fa.store_string(loadout.to_text())
	_note("export wrote loadout.json")


func _import_picked(path: String) -> void:
	var fa := FileAccess.open(path, FileAccess.READ)
	if fa == null:
		_note("import failed")
		return
	if not loadout.from_text(fa.get_as_text()):
		_note("import rejected")
		return
	_write_fields(loadout.data)
	_note("imported. validating.")
	await _on_validate()


func _note(msg: String) -> void:
	if _status:
		_status.text = msg
