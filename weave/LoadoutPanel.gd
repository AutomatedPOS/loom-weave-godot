class_name LoadoutPanel
extends Control

## Interface-track loadout. Opens from the gear. No vendor. No chat.
const INK := Color(0.68, 0.68, 0.70, 1)
const DIM := Color(0.42, 0.42, 0.44, 1)
const PANEL := Color(0.04, 0.04, 0.045, 0.96)
const WELL := Color(0.10, 0.10, 0.11, 1)
const EDGE := Color(0.22, 0.22, 0.24, 1)

var loadout := Loadout.new()
var _line_edits: Array[LineEdit] = []
var _status: Label
var _pick_cb: Callable


func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build()
	_reload_from_store()


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
	var bg := ColorRect.new()
	bg.color = PANEL
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(bg)

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

	_status = _label("", 12, DIM)
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(_status)

	_line_edits.clear()
	col.add_child(_section("chat"))
	col.add_child(_section("speech"))
	col.add_child(_section("hear"))


func _draw_frame() -> void:
	var top := ColorRect.new()
	top.color = EDGE
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top.offset_bottom = 1
	add_child(top)
	var bot := ColorRect.new()
	bot.color = EDGE
	bot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bot.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bot.offset_top = -1
	add_child(bot)
	var left := ColorRect.new()
	left.color = EDGE
	left.mouse_filter = Control.MOUSE_FILTER_IGNORE
	left.set_anchors_preset(Control.PRESET_LEFT_WIDE)
	left.offset_right = 1
	add_child(left)
	var right := ColorRect.new()
	right.color = EDGE
	right.mouse_filter = Control.MOUSE_FILTER_IGNORE
	right.set_anchors_preset(Control.PRESET_RIGHT_WIDE)
	right.offset_left = -1
	add_child(right)


func _section(cap: String) -> VBoxContainer:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	box.add_child(_label(cap, 14, INK))
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
	var normal := StyleBoxFlat.new()
	normal.bg_color = WELL
	normal.border_color = EDGE
	normal.set_border_width_all(1)
	normal.content_margin_left = 8
	normal.content_margin_right = 8
	var focus := normal.duplicate()
	focus.border_color = INK
	edit.add_theme_stylebox_override("normal", normal)
	edit.add_theme_stylebox_override("focus", focus)
	edit.add_theme_color_override("font_color", INK)
	edit.add_theme_color_override("font_placeholder_color", DIM)
	edit.add_theme_color_override("caret_color", INK)
	edit.add_theme_font_size_override("font_size", 14)


func _label(text: String, size: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l


func _button(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(88, 36)
	var normal := StyleBoxFlat.new()
	normal.bg_color = WELL
	normal.border_color = EDGE
	normal.set_border_width_all(1)
	normal.content_margin_left = 10
	normal.content_margin_right = 10
	var hover := normal.duplicate()
	hover.border_color = INK
	b.add_theme_stylebox_override("normal", normal)
	b.add_theme_stylebox_override("hover", hover)
	b.add_theme_stylebox_override("pressed", hover)
	b.add_theme_color_override("font_color", INK)
	b.add_theme_font_size_override("font_size", 14)
	b.pressed.connect(cb)
	return b


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
	_note("imported. Save to keep it on this browser.")


func _note(msg: String) -> void:
	if _status:
		_status.text = msg
