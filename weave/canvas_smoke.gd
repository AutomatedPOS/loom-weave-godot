extends SceneTree

## Canvas smoke. Rails left, field with the seat and its frames, ports
## right and unlabelled, timeline along the bottom. Tap looks, drag
## attaches, nothing writes. The monitor is off the window.


func _fail(msg: String) -> void:
	push_error(msg)
	quit(1)


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	LoomShape.clear_current()
	var packed := load("res://weave/Main.tscn")
	if packed == null:
		_fail("no Main.tscn")
		return
	var main: Control = packed.instantiate()
	root.add_child(main)
	await process_frame

	var canvas := main.get_node_or_null("Interface/Canvas") as LoomCanvas
	if canvas == null:
		_fail("no Interface/Canvas")
		return
	if canvas.theme != LoomTheme.shared():
		_fail("canvas lacks the shared theme")
		return
	var monitor := main.get_node_or_null("Interface/Monitor")
	if monitor != null and monitor.visible:
		_fail("monitor is still on the window")
		return
	if canvas.get_child_count() > 0:
		_fail("canvas grew child controls; it draws in one pass")
		return
	if canvas.seat_name() == "":
		_fail("no seat")
		return

	# Rails: three kinds. Chips that exist are touch targets. Tools is
	# empty until the owner names one. Invented stand-ins are gone.
	if canvas.rail_names(&"persona").find("Brains") < 0:
		_fail("personas rail missed Brains")
		return
	if canvas.rail_names(&"process").find("Brief") < 0:
		_fail("processes rail missed Brief")
		return
	if canvas.rail_names(&"process").find("Walk") >= 0:
		_fail("invented process still on the rail")
		return
	if not canvas.rail_names(&"tool").is_empty():
		_fail("tools rail was filled without an authored tool")
		return
	for kind in LoomCanvas.KINDS:
		for name in canvas.rail_names(kind):
			var r := canvas.chip_rect(kind, name)
			if r.size.y < LoomTokens.TOUCH_H or r.size.x != LoomTokens.RAIL_W:
				_fail("chip %s/%s is not a touch target: %s" % [kind, name, r])
				return
	# Ports: three, the same size, on the right, unlabelled.
	if canvas.port_count() != LoomCanvas.PORTS:
		_fail("expected %d ports" % LoomCanvas.PORTS)
		return
	for i in canvas.port_count():
		var p := canvas.port_rect(i)
		if p.size != Vector2(LoomTokens.RAIL_W, LoomTokens.TOUCH_H) or p.end.x > canvas.size.x - LoomTokens.INSET + 0.5:
			_fail("port %d is off: %s" % [i, p])
			return
	var src := FileAccess.get_file_as_string("res://weave/Canvas.gd")
	for word in ["\"save\"", "\"export\"", "\"discard\""]:
		if word in src.to_lower():
			_fail("a port carries a label: %s" % word)
			return
	for word in ["add_theme_color_override", "add_theme_font_size_override", "add_theme_stylebox_override"]:
		if word in src:
			_fail("canvas styles by hand: %s" % word)
			return
	# The marks that say where you are wear the task accent: the seat's top
	# edge, the arriving chip's ring and leader, the clock's now square, the
	# timeline's cursor and selected period. Nothing on the canvas is
	# broken or changed-since today, so hazard and changed stay unused.
	if "LoomTokens.ACCENT" in src:
		_fail("canvas still names the old single accent")
		return
	if "LoomTokens.TASK" not in src:
		_fail("canvas does not mark where you are with the task accent")
		return
	for word in ["LoomTokens.HAZARD", "LoomTokens.CHANGED"]:
		if word in src:
			_fail("canvas paints %s with nothing to say" % word)
			return

	# The seat sits in the field, between rails and ports, above the timeline.
	var seat := canvas.seat_rect()
	var tl := canvas.timeline_rect()
	if seat.position.x < LoomTokens.INSET + LoomTokens.RAIL_W or seat.end.x > canvas.size.x - LoomTokens.INSET - LoomTokens.RAIL_W:
		_fail("seat overlaps a rail or port: %s" % seat)
		return
	if seat.end.y > tl.position.y:
		_fail("seat overlaps the timeline")
		return
	if tl.end.y > canvas.size.y - LoomTokens.INSET - LoomTokens.GEAR_SIZE:
		_fail("timeline reaches the gear")
		return
	if canvas.position_date() == "" or not canvas.at_now():
		_fail("clock does not start at now")
		return

	# Tap a tile behind the seat and it becomes the seat; the frames follow the path.
	var loader := TreeLoader.new()
	if not loader.load_tree("res://"):
		_fail(loader.error)
		return
	var specs := ""
	for node in loader.nodes:
		if str(node.get("name", "")) == "specs":
			specs = str(node.get("guid", ""))
	if specs == "" or not canvas.focus_guid(specs):
		_fail("could not focus specs")
		return
	if canvas.seat_name() != "specs" or canvas.path_names().size() != 2 or canvas.frame_rect(0).size.x <= 0:
		_fail("focusing specs did not nest one frame: %s" % ", ".join(canvas.path_names()))
		return
	var tiles := canvas.tile_names()
	if tiles.find("loadout") < 0:
		_fail("siblings are not behind the seat: %s" % ", ".join(tiles))
		return
	var loadout_tile := canvas.tile_rect("loadout")
	if loadout_tile.size.x > 0:
		canvas.tap(loadout_tile.get_center())
		if canvas.seat_name() != "loadout":
			_fail("tap on a tile did not move the seat")
			return
	# Tap the outer frame's label band and the seat goes back out.
	canvas.tap(canvas.frame_rect(0).position + Vector2(LoomTokens.SPACE_4, LoomTokens.SPACE_4))
	if canvas.seat_name() != "loom-weave-godot":
		_fail("tap on a frame did not move the seat out: %s" % canvas.seat_name())
		return

	# Drag a persona from its rail onto the seat's persona socket: docked. The rail keeps it.
	var brains := canvas.chip_rect(&"persona", "Brains")
	canvas.drag(brains.get_center(), canvas.socket_pos(&"persona"))
	if canvas.docked().get(&"persona", "") != "Brains":
		_fail("drag to the socket did not dock: %s" % canvas.docked())
		return
	if canvas.rail_names(&"persona").find("Brains") < 0:
		_fail("the roster was consumed")
		return
	var query := canvas.query()
	var qerr := LoomShape.validate(query)
	if qerr != "":
		_fail("docked arrangement is not a v1 query: %s" % qerr)
		return
	var blob := LoomShape.dumps(query)
	for word in ["justDid", "waitingOn", "credential", "transcript", "\"body\""]:
		if word in blob:
			_fail("query carries data: %s" % word)
			return
	if "13bc00fd-1276-498d-9b35-c2980c5fd10f" not in blob:
		_fail("query missed the brains guid")
		return
	var main2: Control = packed.instantiate()
	root.add_child(main2)
	await process_frame
	var canvas2 := main2.get_node_or_null("Interface/Canvas") as LoomCanvas
	if canvas2 == null:
		_fail("no second canvas")
		return
	if canvas2.docked().get(&"persona", "") != "Brains":
		_fail("second canvas missed the stored dock: %s" % canvas2.docked())
		return
	if canvas2.seat_guid() != canvas.seat_guid():
		_fail("second canvas did not restore the seat")
		return
	main2.queue_free()
	await process_frame
	# A process cannot take the persona socket.
	canvas.drag(canvas.chip_rect(&"process", "Brief").get_center(), canvas.socket_pos(&"persona"))
	if canvas.docked().has(&"process"):
		_fail("a process docked on the persona socket")
		return
	# Drag the docked chip out through a port: gone. Any port; which is which is open.
	canvas.drag(canvas.socket_pos(&"persona"), canvas.port_rect(2).get_center())
	if canvas.docked().has(&"persona"):
		_fail("port did not take the chip off the field")
		return

	# Scrub the timeline back a day and the clock follows. Nothing writes.
	var before := FileAccess.get_file_as_string("res://thread.json")
	var today := canvas.position_date()
	canvas.tap(Vector2(tl.position.x + tl.size.x * 0.1, tl.get_center().y))
	if canvas.at_now() or canvas.position_date() >= today:
		_fail("scrub did not move the clock back: %s" % canvas.position_date())
		return
	canvas.tap(Vector2(tl.end.x, tl.get_center().y))
	if not canvas.at_now():
		_fail("scrub to the end is not now")
		return
	if FileAccess.get_file_as_string("res://thread.json") != before:
		_fail("canvas wrote a thread.json")
		return

	print("SMOKE canvas rails + seat + ports + timeline + tap + drag")
	quit(0)
