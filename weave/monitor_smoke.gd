extends SceneTree

## Monitor smoke. The read-only transit map: spine, PDCA words, tree,
## focus, placard. Trunk stays on screen; a branch opens on focus.
## Does not write.


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

	var monitor := main.get_node_or_null("Interface/Monitor") as Monitor
	if monitor == null:
		_fail("no Interface/Monitor")
		return
	if monitor.theme != LoomTheme.shared():
		_fail("monitor lacks the shared theme")
		return
	if monitor.focused_name() == "":
		_fail("monitor focused nothing")
		return
	var line := monitor.pdca_line()
	if line.find("DO") < 0:
		_fail("PDCA line missing an open DO: %s" % line)
		return
	if monitor.detail_text().find("just did") < 0 and monitor.detail_text().find("body") < 0:
		_fail("detail has no close-out")
		return
	for l in monitor.find_children("*", "Label", true, false):
		if l.has_theme_color_override(&"font_color") or l.has_theme_font_size_override(&"font_size"):
			_fail("placard label '%s' is styled by hand" % l.text)
			return
	if monitor.find_children("*", "Button", true, false).size() > 0:
		_fail("monitor still carries buttons")
		return

	var loader := TreeLoader.new()
	if not loader.load_tree("res://"):
		_fail(loader.error)
		return

	# Trunk only: the root's children show, a grandchild does not.
	var shown := monitor.visible_names()
	if shown.find("loom-weave-godot") < 0 or shown.find("loadout") < 0:
		_fail("trunk missing from the field: %s" % ", ".join(shown))
		return
	if shown.find("specs-act-one") >= 0:
		_fail("a branch the seat is not in is open")
		return

	# Focus a branch and it opens under the trunk.
	var specs := ""
	for node in loader.nodes:
		if str(node.get("name", "")) == "specs":
			specs = str(node.get("guid", ""))
	if specs == "" or not monitor.focus_guid(specs):
		_fail("could not focus specs")
		return
	shown = monitor.visible_names()
	if shown.find("specs-act-one") < 0 or shown.find("loadout") < 0:
		_fail("focusing specs lost the trunk or did not open the branch: %s" % ", ".join(shown))
		return
	if monitor.focused_name() != "specs":
		_fail("focus did not move")
		return

	# A station answers to a click at its own position, and nothing writes.
	var before := FileAccess.get_file_as_string("res://specs/thread.json")
	var hit := monitor.station_at(monitor._pos[specs])
	if str(hit.get("name", "")) != "specs":
		_fail("station_at missed specs")
		return
	if FileAccess.get_file_as_string("res://specs/thread.json") != before:
		_fail("monitor wrote a thread.json")
		return

	print("SMOKE monitor spine + PDCA + tree + focus")
	quit(0)
