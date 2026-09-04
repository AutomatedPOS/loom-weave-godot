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

# Web paste: a small bridge object in the page. See _web_paste_setup.
var _web_paste: JavaScriptObject
var _web_paste_text_cb: JavaScriptObject
var _web_paste_fail_cb: JavaScriptObject

# Web IME: a real <input> over the focused field so the tablet
# keyboard opens. Godot's canvas LineEdit selects and does not type.
var _web_ime: JavaScriptObject
var _web_ime_text_cb: JavaScriptObject
var _ime_edit: LineEdit

const PASTED := "pasted. Save to keep it on this browser."
const PASTE_EMPTY := "clipboard is empty"
const PASTE_BLOCKED := "paste blocked by the browser. tap Paste again, or long-press a field."
const PASTE_NO_FIELD := "focus a field, then Paste"


func _ready() -> void:
	visible = false
	_build()
	_place()
	get_viewport().size_changed.connect(_place)
	_reload_from_store()
	if _is_web():
		_web_paste_setup()
		_web_ime_setup()


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
	_web_ime_hide()
	_note("")


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed(&"ui_cancel"):
		close()
		get_viewport().set_input_as_handled()


## Status line under the buttons. Public for the smoke test.
func status_text() -> String:
	return _status.text if _status else ""


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
	if _ime_edit:
		_web_ime_show(_ime_edit)


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
	col.add_child(_label("defaults are pointed. paste a credential.", LoomTokens.V_MUTED))

	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", LoomTokens.SPACE_2)
	col.add_child(row)
	row.add_child(_button("Save", _on_save))
	row.add_child(_button("Export", _on_export))
	row.add_child(_button("Import", _on_import))
	var paste := _button("Paste", _on_paste)
	# Paste must not take focus from the field it is about to fill.
	paste.focus_mode = Control.FOCUS_NONE
	paste.button_down.connect(_on_paste_down)
	paste.button_up.connect(_on_paste_up)
	row.add_child(paste)

	_status = _label("", LoomTokens.V_MUTED)
	col.add_child(_status)

	for cap in Loadout.CAPS:
		var section := LoadoutSection.new()
		section.setup(cap)
		col.add_child(section)
		_sections[cap] = section
		for field in Loadout.FIELDS:
			var e := section.edit(field)
			e.gui_input.connect(_on_edit_input.bind(e))
			e.focus_entered.connect(_web_ime_show.bind(e))


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
	_share_one_credential()
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


## Put clipboard text into the focused field, or the first empty
## credential when no field has focus. Public: both paste paths and
## the smoke test land here. Never logs the text.
func paste_text(text: String) -> void:
	if text == "":
		_note(PASTE_EMPTY)
		return
	var target := _paste_target()
	if target == null:
		_note(PASTE_NO_FIELD)
		return
	var clean := text.strip_edges()
	if target.has_focus():
		target.insert_text_at_caret(clean)
	else:
		target.text = clean
		target.grab_focus()
		target.caret_column = target.text.length()
	_web_ime_show(target)
	_note(PASTED)


func _paste_target() -> LineEdit:
	var owner := get_viewport().gui_get_focus_owner()
	if owner is LineEdit and is_ancestor_of(owner):
		return owner
	for cap in Loadout.CAPS:
		var edit := field_edit(cap, "credential")
		if edit and edit.text.strip_edges() == "":
			return edit
	return null


func _on_paste() -> void:
	if _is_web():
		if _web_paste:
			_web_paste.request()
		return
	paste_text(DisplayServer.clipboard_get())


## Godot's web LineEdit pastes a stale copy of the clipboard on
## Ctrl/Cmd+V. The browser paste event carries the real text, so on
## web that event feeds paste_text and the built-in action is dropped.
## A tap selects the field and does not open the tablet keyboard;
## that same gesture attaches a real page input over the field.
func _on_edit_input(event: InputEvent, edit: LineEdit) -> void:
	if not _is_web():
		return
	if event is InputEventKey and event.is_action(&"ui_paste") and event.is_pressed():
		accept_event()
		return
	if not visible:
		return
	var tap := false
	if event is InputEventScreenTouch and event.pressed:
		tap = true
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		tap = true
	if tap:
		_web_ime_show(edit)


static func _is_web() -> bool:
	return OS.has_feature("web") and Engine.has_singleton("JavaScriptBridge")


# --- web paste: clipboard through JavaScriptBridge --------------------------
#
# Godot's key listener cancels the browser's own paste on keydown, so
# the paste event never fires for Ctrl/Cmd+V. A keydown listener in
# the page reads the clipboard inside that gesture instead. The Paste
# button has no keyboard behind it on a tablet, so a pointerup listener
# reads the clipboard inside the tap; button_down arms it, button_up
# disarms it, and the button's own pressed signal is the fallback for
# browsers that allow a read one frame later. A real paste event, from
# an Edit menu, still lands, once, through the last listener.

const WEB_PASTE_JS := """
(function () {
	if (window.loomPaste) { return; }
	var p = { armed: false, busy: false, last: 0, onText: null, onFail: null };
	function deliver(text) {
		p.busy = false;
		p.last = Date.now();
		if (p.onText) { p.onText(String(text || "")); }
	}
	function fail(name) {
		p.busy = false;
		if (p.onFail) { p.onFail(String(name || "")); }
	}
	p.arm = function (on) { p.armed = !!on; };
	p.request = function () {
		if (p.busy) { return; }
		if (!navigator.clipboard || !navigator.clipboard.readText) { fail("unsupported"); return; }
		p.busy = true;
		navigator.clipboard.readText().then(deliver, function (e) { fail(e && e.name); });
	};
	function gesture() { if (p.armed) { p.request(); } }
	window.addEventListener("pointerup", gesture, true);
	window.addEventListener("touchend", gesture, true);
	window.addEventListener("keydown", function (evt) {
		var v = evt.key === "v" || evt.key === "V" || evt.code === "KeyV";
		if (v && (evt.ctrlKey || evt.metaKey) && !evt.altKey && !evt.repeat) { p.request(); }
	}, true);
	window.addEventListener("paste", function (evt) {
		if (p.busy || Date.now() - p.last < 500) { return; }
		var data = evt.clipboardData || window.clipboardData;
		var text = data ? data.getData("text/plain") || data.getData("text") : "";
		if (text) { evt.preventDefault(); deliver(text); }
	}, true);
	window.loomPaste = p;
})();
"""


func _web_paste_setup() -> void:
	JavaScriptBridge.eval(WEB_PASTE_JS, true)
	_web_paste = JavaScriptBridge.get_interface("loomPaste")
	if _web_paste == null:
		return
	_web_paste_text_cb = JavaScriptBridge.create_callback(_on_web_paste_text)
	_web_paste_fail_cb = JavaScriptBridge.create_callback(_on_web_paste_fail)
	_web_paste.onText = _web_paste_text_cb
	_web_paste.onFail = _web_paste_fail_cb


func _on_paste_down() -> void:
	if _web_paste:
		_web_paste.arm(true)


func _on_paste_up() -> void:
	if _web_paste:
		_web_paste.arm(false)


func _on_web_paste_text(args: Array) -> void:
	if not visible:
		return
	paste_text(str(args[0]) if args.size() > 0 else "")


func _on_web_paste_fail(_args: Array) -> void:
	if not visible:
		return
	_note(PASTE_BLOCKED)


# --- web IME: real <input> so a tablet tap opens the keyboard ---------------
#
# The canvas LineEdit takes focus and draws a caret. Chrome on a
# tablet does not open the virtual keyboard for a canvas. A page
# <input> focused in the same tap does. Font size 16px; smaller
# and mobile Chrome zooms or refuses the keyboard. The input sits
# on the field. Keystrokes never get logged.

const WEB_IME_JS := """
(function () {
	if (window.loomIme) { return; }
	var input = document.createElement("input");
	input.autocomplete = "off";
	input.autocorrect = "off";
	input.autocapitalize = "none";
	input.spellcheck = false;
	input.style.position = "fixed";
	input.style.zIndex = "2147483647";
	input.style.border = "none";
	input.style.outline = "none";
	input.style.padding = "0 8px";
	input.style.margin = "0";
	input.style.borderRadius = "0";
	input.style.fontSize = "16px";
	input.style.fontFamily = "sans-serif";
	input.style.left = "-9999px";
	input.style.top = "0";
	input.style.width = "1px";
	input.style.height = "1px";
	document.body.appendChild(input);
	var p = { onText: null };
	p.show = function (vx, vy, vw, vh, vpw, vph, text, secret, bg, fg) {
		var c = document.querySelector("canvas");
		if (!c) { return; }
		var br = c.getBoundingClientRect();
		var x = br.left + (vx / vpw) * br.width;
		var y = br.top + (vy / vph) * br.height;
		var w = (vw / vpw) * br.width;
		var h = (vh / vph) * br.height;
		input.style.background = bg;
		input.style.color = fg;
		input.style.caretColor = fg;
		input.type = secret ? "password" : "text";
		input.value = text || "";
		input.style.left = x + "px";
		input.style.top = y + "px";
		input.style.width = Math.max(8, w) + "px";
		input.style.height = Math.max(16, h) + "px";
		input.focus();
		var n = input.value.length;
		try { input.setSelectionRange(n, n); } catch (e) {}
	};
	p.hide = function () {
		input.blur();
		input.style.left = "-9999px";
		input.style.width = "1px";
		input.style.height = "1px";
	};
	p.set = function (text) {
		input.value = text || "";
	};
	input.addEventListener("input", function () {
		if (p.onText) { p.onText(String(input.value || "")); }
	});
	window.loomIme = p;
})();
"""


func _web_ime_setup() -> void:
	JavaScriptBridge.eval(WEB_IME_JS, true)
	_web_ime = JavaScriptBridge.get_interface("loomIme")
	if _web_ime == null:
		return
	_web_ime_text_cb = JavaScriptBridge.create_callback(_on_web_ime_text)
	_web_ime.onText = _web_ime_text_cb


func _web_ime_show(edit: LineEdit) -> void:
	if not _is_web() or _web_ime == null or not visible or edit == null:
		return
	_ime_edit = edit
	var r := edit.get_global_rect()
	var vp := get_viewport().get_visible_rect().size
	_web_ime.show(
		r.position.x, r.position.y, r.size.x, r.size.y,
		vp.x, vp.y, edit.text, edit.secret,
		_css_color(LoomTokens.WELL), _css_color(LoomTokens.INK)
	)


func _css_color(c: Color) -> String:
	return "#%02x%02x%02x" % [int(c.r * 255.0), int(c.g * 255.0), int(c.b * 255.0)]


func _web_ime_hide() -> void:
	_ime_edit = null
	if _web_ime:
		_web_ime.hide()


func _on_web_ime_text(args: Array) -> void:
	if _ime_edit == null or not visible:
		return
	_ime_edit.text = str(args[0]) if args.size() > 0 else ""
	_ime_edit.caret_column = _ime_edit.text.length()


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


## One pasted key covers the empty credential fields. Different
## keys still win if they typed more than one.
func _share_one_credential() -> void:
	var filled: Array[String] = []
	for cap in Loadout.CAPS:
		if loadout.get_field(cap, "credential") != "":
			filled.append(cap)
	if filled.size() != 1:
		return
	var key := loadout.get_field(filled[0], "credential")
	for cap in Loadout.CAPS:
		if loadout.get_field(cap, "credential") == "":
			loadout.set_field(cap, "credential", key)


func _note(msg: String) -> void:
	if _status:
		_status.text = msg
