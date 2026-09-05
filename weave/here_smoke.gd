extends SceneTree

## Here smoke. Black field, the seat's close-out, task accent on the
## name. No rails, no ports, no child controls, nothing writes.


func _fail(msg: String) -> void:
	push_error(msg)
	quit(1)


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	var packed := load("res://weave/Main.tscn")
	if packed == null:
		_fail("no Main.tscn")
		return
	var main: Control = packed.instantiate()
	root.add_child(main)
	await process_frame

	var here := main.get_node_or_null("Interface/Here") as LoomHere
	if here == null:
		_fail("no Interface/Here")
		return
	if not here.visible:
		_fail("here is off the window")
		return
	if here.theme != LoomTheme.shared():
		_fail("here lacks the shared theme")
		return
	if here.get_child_count() > 0:
		_fail("here grew child controls; it draws in one pass")
		return
	if here.seat_name() != "loom-weave-godot":
		_fail("seat is %s, not the root" % here.seat_name())
		return
	if here.just_did() == "" or here.next_text() == "" or here.waiting_on() == "":
		_fail("close-out is empty")
		return

	var src := FileAccess.get_file_as_string("res://weave/Here.gd")
	for word in ["add_theme_color_override", "add_theme_font_size_override", "add_theme_stylebox_override"]:
		if word in src:
			_fail("here styles by hand: %s" % word)
			return
	if "LoomTokens.ACCENT" in src:
		_fail("here still names the old single accent")
		return
	if "LoomTokens.TASK" not in src:
		_fail("here does not mark where you are with the task accent")
		return
	for word in ["LoomTokens.HAZARD", "LoomTokens.CHANGED"]:
		if word in src:
			_fail("here paints %s with nothing to say" % word)
			return
	for word in ["RAIL_W", "TIMELINE_H", "CHIP_W", "_sockets"]:
		if word in src:
			_fail("here brought a paused mark back: %s" % word)
			return

	var before := FileAccess.get_file_as_string("res://thread.json")
	await process_frame
	if FileAccess.get_file_as_string("res://thread.json") != before:
		_fail("here wrote a thread.json")
		return

	print("SMOKE here: black field, close-out, task accent, no rails")
	quit(0)
