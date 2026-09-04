class_name LoadoutPanel
extends PanelContainer

## Interface-track loadout. Opens from the gear. No vendor. No chat.
## Style comes from the Theme. Layout numbers come from LoomTokens.
## Sections are LoadoutSection, one per Loadout.CAPS.

var loadout := Loadout.new()
var _sections: Dictionary = {}
var _status: Label
var _pick_cb: Callable

# Web import: a hidden <input type=file> and the callbacks that own it.
var _web_input: JavaScriptObject
var _web_reader: JavaScriptObject
var _web_change_cb: JavaScriptObject
var _web_load_cb: JavaScriptObject


func _ready() -> void:
	visible = false
	_build()
	_place()
	get_viewport().size_changed.connect(_place)
	_reload_from_store()


func toggle() -> void:
	if visible:
		close()
	else:
		open()


## Opening shows what is in the fields now. Unsaved edits are kept.
func open() -> void:
	visible = true


func close() -> void:
	visible = false
	_note("")


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed(&"ui_cancel"):
		close()
		get_viewport().set_input_as_handled()


## The field for one capability and field name. Public for the smoke test.
func field_edit(cap: String, field: String) -> LineEdit:
	var section: LoadoutSection = _sections.get(cap)
	return section.edit(field) if section else null


## Bottom-right, above the gear, never taller than the viewport allows.
func _place() -> void:
	var vp := get_viewport_rect().size
	var inset := float(LoomTokens.INSET)
	var bottom := float(LoomTokens.panel_bottom_inset())
	var h := minf(float(LoomTokens.PANEL_H_MAX), vp.y - bottom - inset)
	set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	offset_left = -(float(LoomTokens.PANEL_W) + inset)
	offset_top = -(h + bottom)
	offset_right = -inset
	offset_bottom = -bottom


func _reload_from_store() -> void:
	loadout.load_local()
	_write_fields(loadout.data)


func _build() -> void:
	if not _sections.is_empty():
		return
	var pad := MarginContainer.new()
	for side in [&"margin_left", &"margin_right", &"margin_top", &"margin_bottom"]:
		pad.add_theme_constant_override(side, LoomTokens.SPACE_4)
	add_child(pad)

	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	pad.add_child(scroll)

	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override(&"separation", LoomTokens.SPACE_3)
	scroll.add_child(col)

	col.add_child(_label("loadout", LoomTokens.V_TITLE))
	col.add_child(_label("point each after deploy. nothing is in the base.", LoomTokens.V_MUTED))

	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", LoomTokens.SPACE_2)
	col.add_child(row)
	row.add_child(_button("Save", _on_save))
	row.add_child(_button("Export", _on_export))
	row.add_child(_button("Import", _on_import))

	_status = _label("", LoomTokens.V_MUTED)
	col.add_child(_status)

	for cap in Loadout.CAPS:
		var section := LoadoutSection.new()
		section.setup(cap)
		col.add_child(section)
		_sections[cap] = section


func _label(text: String, variation: StringName) -> Label:
	var l := Label.new()
	l.text = text
	l.theme_type_variation = variation
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l


func _button(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(LoomTokens.BUTTON_MIN_W, LoomTokens.CONTROL_H)
	b.pressed.connect(cb)
	return b


func _read_fields() -> Dictionary:
	var out := Loadout.empty_data()
	for cap in _sections:
		out[cap] = (_sections[cap] as LoadoutSection).read()
	return out


func _write_fields(src: Dictionary) -> void:
	for cap in _sections:
		var raw: Variant = src.get(cap, {})
		var block: Dictionary = raw if typeof(raw) == TYPE_DICTIONARY else Loadout.empty_cap()
		(_sections[cap] as LoadoutSection).write(block)


func _on_save() -> void:
	loadout.data = _read_fields()
	_write_fields(loadout.data)
	var err := loadout.save()
	if err != OK:
		_note("save failed")
		return
	var odd := loadout.endpoints_without_scheme()
	if odd.is_empty():
		_note("saved on this browser")
	else:
		_note("saved on this browser. %s endpoint has no http:// or https://" % ", ".join(odd))


func _on_export() -> void:
	loadout.data = _read_fields()
	var text := loadout.to_text()
	if OS.has_feature("web") and Engine.has_singleton("JavaScriptBridge"):
		JavaScriptBridge.download_buffer(text.to_utf8_buffer(), "loadout.json", "application/json")
		_note("export wrote loadout.json")
		return
	if not DisplayServer.has_feature(DisplayServer.FEATURE_NATIVE_DIALOG_FILE):
		_export_picked(OS.get_user_data_dir().path_join("loadout.json"))
		return
	_pick_cb = _export_picked
	var err := DisplayServer.file_dialog_show(
		"Export loadout",
		OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS),
		"loadout.json",
		false,
		DisplayServer.FILE_DIALOG_MODE_SAVE_FILE,
		PackedStringArray(["*.json ; Loadout"]),
		_on_dialog
	)
	if err != OK:
		_export_picked(OS.get_user_data_dir().path_join("loadout.json"))


func _on_import() -> void:
	if OS.has_feature("web") and Engine.has_singleton("JavaScriptBridge"):
		_web_import()
		return
	if not DisplayServer.has_feature(DisplayServer.FEATURE_NATIVE_DIALOG_FILE):
		_note("no file picker on this platform")
		return
	_pick_cb = _import_picked
	var err := DisplayServer.file_dialog_show(
		"Import loadout",
		"",
		"",
		false,
		DisplayServer.FILE_DIALOG_MODE_OPEN_FILE,
		PackedStringArray(["*.json ; Loadout"]),
		_on_dialog
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
	_note("export wrote %s" % path.get_file())


func _import_picked(path: String) -> void:
	var fa := FileAccess.open(path, FileAccess.READ)
	if fa == null:
		_note("import failed")
		return
	_import_text(fa.get_as_text())


func _import_text(text: String) -> void:
	if not loadout.from_text(text):
		_note("import rejected")
		return
	_write_fields(loadout.data)
	_note("imported. Save to keep it on this browser.")


# --- web import: browser file picker through JavaScriptBridge ---------------

func _web_import() -> void:
	if _web_input == null:
		var document: JavaScriptObject = JavaScriptBridge.get_interface("document")
		_web_input = document.createElement("input")
		_web_input.type = "file"
		_web_input.accept = ".json,application/json"
		_web_input.style.display = "none"
		document.body.appendChild(_web_input)
		_web_change_cb = JavaScriptBridge.create_callback(_on_web_file_chosen)
		_web_input.addEventListener("change", _web_change_cb)
	_web_input.value = ""
	_web_input.click()


func _on_web_file_chosen(_args: Array) -> void:
	var files: JavaScriptObject = _web_input.files
	if files == null or int(files.length) == 0:
		return
	_web_reader = JavaScriptBridge.create_object("FileReader")
	_web_load_cb = JavaScriptBridge.create_callback(_on_web_file_read)
	_web_reader.onload = _web_load_cb
	_web_reader.readAsText(files.item(0))


func _on_web_file_read(_args: Array) -> void:
	_import_text(str(_web_reader.result))


func _note(msg: String) -> void:
	if _status:
		_status.text = msg
