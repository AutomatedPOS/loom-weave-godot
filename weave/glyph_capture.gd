extends SceneTree

const OUT := "user://glyph-packet.png"


func _init() -> void:
	var bg := ColorRect.new()
	bg.color = LoomTokens.BACKDROP
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(bg)
	var sheet := GlyphSheet.new()
	sheet.theme = LoomTheme.shared()
	root.add_child(sheet)
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
	var mid := img.get_pixel(img.get_width() / 2, img.get_height() / 2)
	if not _near(mid, LoomTokens.BACKDROP):
		img.flip_y()
	var err := img.save_png(OUT)
	if err != OK:
		push_error("save_png failed: %s" % err)
		quit(1)
		return
	print("CAPTURE %s %dx%d" % [OUT, img.get_width(), img.get_height()])
	quit(0)


func _near(a: Color, b: Color) -> bool:
	return absf(a.r - b.r) < 0.08 and absf(a.g - b.g) < 0.08 and absf(a.b - b.b) < 0.08
