extends SceneTree

## Monitor smoke. The first visible read-only view: spine, PDCA line,
## this repo's tree, node detail. Does not write.


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
	if line.find("monitor") < 0 or line.find("DO") < 0:
		_fail("PDCA line missing monitor DO: %s" % line)
		return
	if line.find("loadout") < 0 or line.find("CHECK") < 0:
		_fail("PDCA line missing loadout CHECK: %s" % line)
		return
	if monitor.detail_text().find("just did") < 0 and monitor.detail_text().find("body") < 0:
		_fail("detail has no close-out")
		return

	var loader := TreeLoader.new()
	if not loader.load_tree("res://"):
		_fail(loader.error)
		return
	var other := ""
	for node in loader.nodes:
		var guid := str(node.get("guid", ""))
		if guid != "" and str(node.get("name", "")) != monitor.focused_name():
			other = guid
			break
	if other == "":
		_fail("no second node to focus")
		return
	if not monitor.focus_guid(other):
		_fail("focus_guid failed")
		return
	if monitor.focused_name() == "":
		_fail("focus cleared the name")
		return

	print("SMOKE monitor spine + PDCA + tree")
	quit(0)
