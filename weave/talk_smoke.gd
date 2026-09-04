extends SceneTree


func _fail(msg: String) -> void:
	push_error(msg)
	quit(1)


func _init() -> void:
	var wav := TalkClient.sample_wav()
	if wav.size() < 44:
		_fail("sample wav too small")
		return
	if wav.slice(0, 4).get_string_from_ascii() != "RIFF":
		_fail("sample wav is not RIFF")
		return

	var talk := TalkClient.new()
	var revoked := talk._classify_http(HTTPRequest.RESULT_SUCCESS, 401, PackedByteArray())
	if str(revoked.get("kind", "")) != "revoked":
		_fail("401 did not map to revoked")
		return
	var credit := talk._classify_http(
		HTTPRequest.RESULT_SUCCESS,
		429,
		PackedByteArray("insufficient_quota".to_utf8_buffer())
	)
	if str(credit.get("kind", "")) != "credit":
		_fail("429 did not map to credit")
		return
	var offline := talk._classify_http(HTTPRequest.RESULT_CANT_CONNECT, 0, PackedByteArray())
	if str(offline.get("kind", "")) != "offline":
		_fail("connect fail did not map to offline")
		return
	var timeout := talk._classify_http(HTTPRequest.RESULT_TIMEOUT, 0, PackedByteArray())
	if str(timeout.get("kind", "")) != "timeout":
		_fail("timeout did not map")
		return

	if talk.cap_ready("chat"):
		_fail("empty loadout reported chat ready")
		return

	var store := ProjectSettings.globalize_path(ThemeEngine.STORE)
	if FileAccess.file_exists(store):
		DirAccess.remove_absolute(store)
	var engine := ThemeEngine.new()
	if not engine.boot():
		_fail("theme boot failed: %s" % engine.last_error)
		return
	var before := engine.get_color("color.ink-100")
	var ok_patch := {
		"$schema": ThemeEngine.SCHEMA,
		"primitives": {"color": {"ink-100": "#0a1020"}},
	}
	if not engine.apply_patch(ok_patch):
		_fail("live patch failed: %s" % engine.last_error)
		return
	if engine.get_color("surface.base") == before:
		_fail("surface.base did not follow ink-100")
		return
	var bad := {
		"$schema": ThemeEngine.SCHEMA,
		"primitives": {
			"color": {
				"ink-000": "#777777",
				"ink-100": "#777777",
				"ink-200": "#777777",
				"ink-800": "#777777",
				"ink-900": "#777777",
				"brand-500": "#777777",
			},
		},
	}
	var mid := engine.get_color("surface.base")
	if engine.apply_patch(bad):
		_fail("live contrast reject failed")
		return
	if engine.get_color("surface.base") != mid:
		_fail("rejected live patch mutated theme")
		return

	var packed := load("res://weave/Main.tscn")
	var main: Control = packed.instantiate()
	root.add_child(main)
	var panel := main.get_node_or_null("Interface/Panel") as LoadoutPanel
	if panel == null:
		_fail("no panel")
		return
	if panel.visible:
		_fail("panel visible on first screen")
		return
	if panel.all_green():
		_fail("fresh caps are green")
		return
	var chat := main.get_node_or_null("Interface/Chat")
	if chat != null and chat.visible:
		_fail("chat visible without green caps")
		return
	var backdrop := main.get_node("Backdrop") as ColorRect
	if backdrop.color != Color(0, 0, 0, 1):
		_fail("backdrop left black")
		return

	print("SMOKE talk wav + error kinds + live theme patch + hidden chat")
	quit(0)
