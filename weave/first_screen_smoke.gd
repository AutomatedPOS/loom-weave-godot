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
	if backdrop.color != LoomTokens.BACKDROP:
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

	var here := main.get_node_or_null("Interface/Here")
	if here == null or not here.visible:
		push_error("no visible Interface/Here")
		quit(1)
		return

	for name in ["Gear", "Panel", "Monitor", "Canvas"]:
		var node := main.get_node_or_null("Interface/%s" % name)
		if node == null:
			push_error("no Interface/%s" % name)
			quit(1)
			return
		if node.visible:
			push_error("%s is still on the window" % name)
			quit(1)
			return

	print("SMOKE first-screen black + where-am-i")
	quit(0)
