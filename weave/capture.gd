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
	if not _is_blank(img) and not _is_field(img) and not _gear_shows_ink(img):
		img.flip_y()
		if not _gear_shows_ink(img):
			img.flip_y()
	var err := img.save_png(OUT)
	if err != OK:
		push_error("save_png failed: %s" % err)
		quit(1)
		return
	print("CAPTURE %s %dx%d" % [OUT, img.get_width(), img.get_height()])
	quit(0)


func _is_blank(img: Image) -> bool:
	var c := img.get_pixel(img.get_width() / 2, img.get_height() / 2)
	return _near(c, LoomTokens.BLANK)


func _is_field(img: Image) -> bool:
	var c := img.get_pixel(img.get_width() / 2, img.get_height() / 2)
	return _near(c, LoomTokens.BACKDROP)


## Gear sits bottom-right, INSET in, GEAR_SIZE square. Hub is backdrop;
## teeth are ink. If the rect has no ink, the image is upside down.
func _gear_shows_ink(img: Image) -> bool:
	var inset := LoomTokens.INSET
	var gs := LoomTokens.GEAR_SIZE
	var x0 := img.get_width() - inset - gs
	var y0 := img.get_height() - inset - gs
	if x0 < 0 or y0 < 0:
		return false
	var ink := LoomTokens.INK
	for y in range(y0, y0 + gs):
		for x in range(x0, x0 + gs):
			if _near(img.get_pixel(x, y), ink):
				return true
	return false


func _near(a: Color, b: Color) -> bool:
	return absf(a.r - b.r) < 0.08 and absf(a.g - b.g) < 0.08 and absf(a.b - b.b) < 0.08
