extends SceneTree

const OUT := "user://first-screen.png"


func _init() -> void:
	var packed := load("res://weave/Main.tscn")
	if packed == null:
		push_error("no Main.tscn")
		quit(1)
		return
	root.add_child(packed.instantiate())
	_snap.call_deferred()


func _snap() -> void:
	await process_frame
	await process_frame
	RenderingServer.force_draw()
	var img := root.get_viewport().get_texture().get_image()
	if img == null:
		push_error("no viewport image")
		quit(1)
		return
	# Viewport is y-flipped in Godot 4.
	img.flip_y()
	var err := img.save_png(OUT)
	if err != OK:
		push_error("save_png failed: %s" % err)
		quit(1)
		return
	print("CAPTURE %s %dx%d" % [OUT, img.get_width(), img.get_height()])
	quit(0)
