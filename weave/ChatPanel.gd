class_name ChatPanel
extends Control

## Talk window. Ephemeral. Hidden until capabilities are green.

signal minimized
signal maximized

var talk: TalkClient
var engine: ThemeEngine
var muted := false
var always_on := false
var busy := false
var _messages: Array = []
var _log: VBoxContainer
var _scroll: ScrollContainer
var _input: LineEdit
var _status: Label
var _wave: ColorRect
var _bubble: Label
var _bg: ColorRect
var _frame: Array[ColorRect] = []
var _title: Label
var _btns: Array[Button] = []
var _ink_labels: Array[Label] = []
var _dim_labels: Array[Label] = []
var _sys_labels: Array[Label] = []
var _maximized := false
var _recording := false
var _listen_btn: Button
var _mode_btn: Button
var _mute_btn: Button

const SYS := """You are the interface. Chat history is ephemeral.
The current theme token file is:
%s
To change appearance, call apply_theme_patch with a partial patch.
Include "$schema":"fence.theme/v1". Only primitives may hold literals.
semantic and components values must be {references}. Unknown keys drop.
Contrast must stay 4.5:1. A bad patch changes nothing.
Keep replies short. Do not mention vendors."""


func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	_layout_normal()
	_build()
	if engine:
		_skin()


func bind(p_engine: ThemeEngine, p_talk: TalkClient) -> void:
	engine = p_engine
	talk = p_talk
	if engine and not engine.applied.is_connected(_skin):
		engine.applied.connect(_skin)
	if is_inside_tree():
		_skin()


func show_talk() -> void:
	visible = true
	_maximized = false
	_layout_normal()


func hide_talk() -> void:
	visible = false
	_stop_listen()


func clear_session() -> void:
	_messages.clear()
	if _log:
		for c in _log.get_children():
			c.queue_free()
	if _status:
		_status.text = ""
	_bubble_hide()


func _layout_normal() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	offset_left = 16
	offset_top = -460
	offset_right = 500
	offset_bottom = -16


func _layout_max() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	offset_left = 16
	offset_top = 16
	offset_right = -16
	offset_bottom = -16


func _build() -> void:
	if _bg != null:
		return
	_bg = ColorRect.new()
	_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_bg.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_bg)
	_draw_frame()

	var col := VBoxContainer.new()
	col.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	col.offset_left = 12
	col.offset_top = 10
	col.offset_right = -12
	col.offset_bottom = -10
	col.add_theme_constant_override("separation", 8)
	add_child(col)

	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 8)
	col.add_child(top)
	_title = _label("talk", 16, false)
	_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(_title)
	top.add_child(_button("min", _on_min))
	top.add_child(_button("max", _on_max))

	_scroll = ScrollContainer.new()
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_child(_scroll)
	_log = VBoxContainer.new()
	_log.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_log.add_theme_constant_override("separation", 6)
	_scroll.add_child(_log)

	_wave = ColorRect.new()
	_wave.custom_minimum_size = Vector2(0, 6)
	_wave.visible = false
	col.add_child(_wave)

	_bubble = _label("", 14, true)
	_bubble.visible = false
	col.add_child(_bubble)

	var tools := HBoxContainer.new()
	tools.add_theme_constant_override("separation", 8)
	col.add_child(tools)
	_listen_btn = _button("mic", _on_mic)
	_mode_btn = _button("push to talk", _on_mode)
	_mute_btn = _button("mute out", _on_mute)
	tools.add_child(_listen_btn)
	tools.add_child(_mode_btn)
	tools.add_child(_mute_btn)

	_input = LineEdit.new()
	_input.placeholder_text = "say something"
	_input.custom_minimum_size = Vector2(0, 36)
	_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_input.text_submitted.connect(_on_submit)
	col.add_child(_input)

	_status = _label("", 12, true)
	col.add_child(_status)


func _draw_frame() -> void:
	_frame.clear()
	for preset in [
		Control.PRESET_TOP_WIDE,
		Control.PRESET_BOTTOM_WIDE,
		Control.PRESET_LEFT_WIDE,
		Control.PRESET_RIGHT_WIDE,
	]:
		var edge := ColorRect.new()
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


func _skin() -> void:
	if engine == null or _bg == null:
		return
	_bg.color = engine.get_color("menu.panel.bg")
	for edge in _frame:
		edge.color = engine.get_color("menu.panel.border")
	_wave.color = engine.get_color("accent.default")
	_style_edit(_input)
	for b in _btns:
		_style_button(b)
	for l in _ink_labels:
		l.add_theme_color_override("font_color", engine.get_color("text.primary"))
	for l in _dim_labels:
		l.add_theme_color_override("font_color", engine.get_color("text.muted"))
	for l in _sys_labels:
		l.add_theme_color_override("font_color", engine.get_color("state.warning"))
	_title.add_theme_font_size_override("font_size", int(engine.get_number("size.2")))


func _style_edit(edit: LineEdit) -> void:
	if engine == null or edit == null:
		return
	var r := int(engine.get_number("radius.control"))
	var normal := StyleBoxFlat.new()
	normal.bg_color = engine.get_color("surface.base")
	normal.border_color = engine.get_color("border.subtle")
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(r)
	normal.content_margin_left = 8
	normal.content_margin_right = 8
	var focus := normal.duplicate()
	focus.border_color = engine.get_color("focus.ring")
	edit.add_theme_stylebox_override("normal", normal)
	edit.add_theme_stylebox_override("focus", focus)
	edit.add_theme_color_override("font_color", engine.get_color("text.primary"))
	edit.add_theme_color_override("font_placeholder_color", engine.get_color("text.muted"))
	edit.add_theme_color_override("caret_color", engine.get_color("text.primary"))
	edit.add_theme_font_size_override("font_size", int(engine.get_number("size.1")))


func _style_button(b: Button) -> void:
	if engine == null:
		return
	var r := int(engine.get_number("radius.control"))
	var normal := StyleBoxFlat.new()
	normal.bg_color = engine.get_color("surface.base")
	normal.border_color = engine.get_color("border.subtle")
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(r)
	normal.content_margin_left = 10
	normal.content_margin_right = 10
	var hover := normal.duplicate()
	hover.bg_color = engine.get_color("menu.item.bg.hover")
	hover.border_color = engine.get_color("accent.default")
	b.add_theme_stylebox_override("normal", normal)
	b.add_theme_stylebox_override("hover", hover)
	b.add_theme_stylebox_override("pressed", hover)
	b.add_theme_color_override("font_color", engine.get_color("text.primary"))
	b.add_theme_font_size_override("font_size", int(engine.get_number("size.1")))


func _label(text: String, size: int, dim: bool) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if dim:
		_dim_labels.append(l)
	else:
		_ink_labels.append(l)
	return l


func _button(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, 32)
	b.pressed.connect(cb)
	_btns.append(b)
	return b


func _on_min() -> void:
	hide_talk()
	minimized.emit()


func _on_max() -> void:
	_maximized = not _maximized
	if _maximized:
		_layout_max()
		maximized.emit()
	else:
		_layout_normal()


func _on_mute() -> void:
	muted = not muted
	_mute_btn.text = "unmute out" if muted else "mute out"


func _on_mode() -> void:
	always_on = not always_on
	_mode_btn.text = "always on" if always_on else "push to talk"
	if always_on:
		_start_listen()
	else:
		_stop_listen()


func _on_mic() -> void:
	if always_on:
		return
	if _recording:
		_finish_listen()
	else:
		_start_listen()


func _on_submit(text: String) -> void:
	var line := text.strip_edges()
	if line == "":
		return
	_input.text = ""
	await _turn(line)


func add_system(text: String) -> void:
	_add_line(text, "system")


func _add_line(text: String, kind: String) -> void:
	if kind == "system":
		var rt := RichTextLabel.new()
		rt.bbcode_enabled = true
		rt.fit_content = true
		rt.scroll_active = false
		rt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var warn := engine.get_color("state.warning") if engine else Color(1, 0.7, 0.2)
		rt.add_theme_color_override("default_color", warn)
		rt.add_theme_font_size_override("normal_font_size", 13)
		rt.text = "[i]%s[/i]" % text.replace("[", "").replace("]", "")
		_log.add_child(rt)
	else:
		var l := Label.new()
		l.text = text
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		l.add_theme_font_size_override("font_size", 14)
		if kind == "user":
			l.add_theme_color_override("font_color", engine.get_color("text.primary") if engine else Color(1, 1, 1))
			_ink_labels.append(l)
		else:
			l.add_theme_color_override("font_color", engine.get_color("text.muted") if engine else Color(0.8, 0.8, 0.8))
			_dim_labels.append(l)
		_log.add_child(l)
	await get_tree().process_frame
	_scroll.scroll_vertical = int(_scroll.get_v_scroll_bar().max_value)


func _system_prompt() -> String:
	var theme_json := "{}"
	if engine:
		theme_json = JSON.stringify(engine.theme_for_prompt(), "\t")
	return SYS % theme_json


func _turn(user_text: String) -> void:
	if busy:
		return
	busy = true
	_input.editable = false
	_add_line(user_text, "user")
	_messages.append({"role": "user", "content": user_text})
	var payload: Array = [{"role": "system", "content": _system_prompt()}]
	payload.append_array(_messages)
	var res: Dictionary = await talk.complete(payload, 256, talk.theme_tools())
	if not res.get("ok", false):
		_fail_visible(res)
		busy = false
		_input.editable = true
		return
	var calls: Array = res.get("tool_calls", [])
	if not calls.is_empty():
		var tool_msgs: Array = await _run_tools(calls)
		_messages.append({"role": "assistant", "content": str(res.get("text", "")), "tool_calls": calls})
		for tm in tool_msgs:
			_messages.append(tm)
		payload = [{"role": "system", "content": _system_prompt()}]
		payload.append_array(_messages)
		res = await talk.complete(payload, 256, [])
		if not res.get("ok", false):
			_fail_visible(res)
			busy = false
			_input.editable = true
			return
	var reply := str(res.get("text", "")).strip_edges()
	if reply != "":
		_messages.append({"role": "assistant", "content": reply})
		_add_line(reply, "assistant")
		if not muted:
			var spoken: Dictionary = await talk.synthesize(reply)
			if spoken.get("ok", false):
				talk.play_audio(spoken.get("audio", PackedByteArray()), str(spoken.get("mime", "")))
			else:
				_fail_visible(spoken)
	busy = false
	_input.editable = true


func _run_tools(calls: Array) -> Array:
	var out: Array = []
	for call in calls:
		if typeof(call) != TYPE_DICTIONARY:
			continue
		var fn: Variant = call.get("function", {})
		var name := ""
		var args_text := "{}"
		if typeof(fn) == TYPE_DICTIONARY:
			name = str(fn.get("name", ""))
			args_text = str(fn.get("arguments", "{}"))
		var tid := str(call.get("id", name))
		var result := "nothing changed"
		if name == TalkClient.THEME_TOOL:
			result = _apply_theme_tool(args_text)
		out.append({"role": "tool", "tool_call_id": tid, "content": result})
	return out


func _apply_theme_tool(args_text: String) -> String:
	var json := JSON.new()
	if json.parse(args_text) != OK or typeof(json.data) != TYPE_DICTIONARY:
		return "rejected: not an object"
	var patch: Dictionary = json.data
	if not patch.has("$schema"):
		patch["$schema"] = ThemeEngine.SCHEMA
	if engine.apply_patch(patch):
		add_system("theme applied")
		return "applied"
	add_system(engine.last_error)
	return engine.last_error


func apply_spoken_patch(patch: Dictionary) -> bool:
	if not patch.has("$schema"):
		patch["$schema"] = ThemeEngine.SCHEMA
	if engine == null:
		return false
	if engine.apply_patch(patch):
		add_system("theme applied")
		return true
	add_system(engine.last_error)
	return false


func _fail_visible(res: Dictionary) -> void:
	var kind := str(res.get("kind", "other"))
	var msg := str(res.get("error", "failed"))
	match kind:
		"credit":
			msg = "out of credit / quota exceeded"
		"revoked":
			msg = "invalid or revoked key"
		"offline":
			msg = "network unreachable / offline"
		"timeout":
			msg = "provider timeout"
	add_system(msg)


func _start_listen() -> void:
	if _recording:
		return
	_recording = true
	_wave.visible = true
	_bubble.text = "listening"
	_bubble.visible = true
	_listen_btn.text = "stop"
	if OS.has_feature("web") and Engine.has_singleton("JavaScriptBridge"):
		JavaScriptBridge.eval(
			"(async function(){try{const s=await navigator.mediaDevices.getUserMedia({audio:true});window._fenceMic={stream:s,chunks:[],rec:new MediaRecorder(s)};window._fenceMic.rec.ondataavailable=e=>{if(e.data&&e.data.size)window._fenceMic.chunks.push(e.data)};window._fenceMic.rec.start(250);window._fenceMicState='rec';}catch(e){window._fenceMicState='err';window._fenceMicErr=String(e);}})();",
			true
		)
	else:
		_status.text = "mic needs the web weave"


func _finish_listen() -> void:
	if not _recording:
		return
	_recording = false
	_wave.visible = false
	_listen_btn.text = "mic"
	var audio := PackedByteArray()
	if OS.has_feature("web") and Engine.has_singleton("JavaScriptBridge"):
		JavaScriptBridge.eval(
			"(async function(){const m=window._fenceMic;if(!m||!m.rec){window._fenceMicState='idle';return;}await new Promise(r=>{m.rec.onstop=r;m.rec.stop();});m.stream.getTracks().forEach(t=>t.stop());const blob=new Blob(m.chunks,{type:m.rec.mimeType||'audio/webm'});const buf=await blob.arrayBuffer();const u=new Uint8Array(buf);let s='';const step=0x8000;for(let i=0;i<u.length;i+=step){s+=String.fromCharCode.apply(null,u.subarray(i,i+step));}window._fenceMicB64=btoa(s);window._fenceMicMime=blob.type;window._fenceMicState='done';})();",
			true
		)
		var n := 0
		while n < 80:
			await get_tree().create_timer(0.05).timeout
			var st := str(JavaScriptBridge.eval("window._fenceMicState", true))
			if st == "done" or st == "err" or st == "idle":
				break
			n += 1
		if str(JavaScriptBridge.eval("window._fenceMicState", true)) == "done":
			var b64 := str(JavaScriptBridge.eval("window._fenceMicB64", true))
			audio = Marshalls.base64_to_raw(b64)
		elif str(JavaScriptBridge.eval("window._fenceMicState", true)) == "err":
			add_system(str(JavaScriptBridge.eval("window._fenceMicErr", true)))
			_bubble_hide()
			return
	if audio.is_empty():
		_bubble_hide()
		if not OS.has_feature("web"):
			add_system("mic needs the web weave")
		return
	var heard: Dictionary = await talk.transcribe(audio)
	_bubble_hide()
	if not heard.get("ok", false):
		_fail_visible(heard)
		return
	var text := str(heard.get("text", "")).strip_edges()
	if text == "":
		add_system("hear returned no text")
		return
	_bubble.text = text
	_bubble.visible = true
	await _turn(text)
	_bubble_hide()


func _stop_listen() -> void:
	if _recording:
		_finish_listen()
	always_on = false
	if _mode_btn:
		_mode_btn.text = "push to talk"


func _bubble_hide() -> void:
	if _bubble:
		_bubble.visible = false
		_bubble.text = ""
	if _wave:
		_wave.visible = false
