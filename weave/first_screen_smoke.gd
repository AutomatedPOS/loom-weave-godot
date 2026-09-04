extends SceneTree


func _init() -> void:
	var packed := load("res://weave/Main.tscn")
	if packed == null:
		push_error("no Main.tscn")
		quit(1)
		return
	var main: Control = packed.instantiate()
	root.add_child(main)
	# The tree is not live inside _init; wait for _ready to have run.
	_checks.call_deferred(main)


func _checks(main: Control) -> void:
	await process_frame

	var backdrop := main.get_node_or_null("Backdrop") as ColorRect
	if backdrop == null:
		push_error("no Backdrop")
		quit(1)
		return
	if backdrop.color != Color(0, 0, 0, 1):
		push_error("backdrop is not black: %s" % backdrop.color)
		quit(1)
		return

	if main.get_node_or_null("Slots") != null:
		push_error("Slots still on the first screen")
		quit(1)
		return
	if main.get_node_or_null("Interface/Bar") != null:
		push_error("interface bar still on the first screen")
		quit(1)
		return

	var gear := main.get_node_or_null("Interface/Gear")
	if gear == null:
		push_error("no Interface/Gear")
		quit(1)
		return
	if gear.get_script() == null:
		push_error("Gear has no script")
		quit(1)
		return

	var panel := main.get_node_or_null("Interface/Panel")
	if panel != null and panel.visible:
		push_error("loadout panel is on the first screen")
		quit(1)
		return

	var monitor := main.get_node_or_null("Interface/Monitor")
	if monitor == null:
		push_error("no Interface/Monitor")
		quit(1)
		return

	if monitor.visible:
		push_error("monitor is still on the window")
		quit(1)
		return
	var canvas := main.get_node_or_null("Interface/Canvas")
	if canvas == null or not canvas.visible:
		push_error("no visible Interface/Canvas")
		quit(1)
		return

	print("SMOKE first-screen black + canvas + gear")
	quit(0)
