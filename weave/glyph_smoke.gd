extends SceneTree

## Glyph smoke. Three noun marks, one bust, a hat is a role.
## Canvas draws through LoomGlyphs. Nothing writes.


func _fail(msg: String) -> void:
	push_error(msg)
	quit(1)


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	if LoomGlyphs.KINDS != [&"persona", &"process", &"tool"]:
		_fail("noun kinds are not persona, process, tool")
		return
	if LoomGlyphs.HAT_NONE != &"" or LoomGlyphs.HAT_ROLE != &"hat":
		_fail("hat slot names moved")
		return

	var src := FileAccess.get_file_as_string("res://weave/Glyphs.gd")
	for word in ["add_theme_color_override", "add_theme_font_size_override", "add_theme_stylebox_override"]:
		if word in src:
			_fail("glyphs style by hand: %s" % word)
			return
	if "Color(" in src:
		_fail("glyphs picked a colour")
		return
	if "LoomTokens.ACCENT" in src or "LoomTokens.HAZARD" in src or "LoomTokens.CHANGED" in src:
		_fail("glyphs spent an accent")
		return
	if "func _hat" not in src or "HAT_ROLE" not in src:
		_fail("persona lost the hat slot")
		return

	var canvas_src := FileAccess.get_file_as_string("res://weave/Canvas.gd")
	if "LoomGlyphs.draw_on" not in canvas_src:
		_fail("canvas does not draw through LoomGlyphs")
		return
	if "Persona is a circle" in canvas_src:
		_fail("canvas still has the old circle/square/diamond glyphs")
		return

	var sheet := GlyphSheet.new()
	root.add_child(sheet)
	await process_frame
	if sheet.get_child_count() > 0:
		_fail("glyph sheet grew child controls")
		return
	var sheet_src := FileAccess.get_file_as_string("res://weave/GlyphSheet.gd")
	if "HAT_ROLE" not in sheet_src:
		_fail("sheet does not show a hat on the same bust")
		return

	print("SMOKE glyphs: persona bust, process rect, tool square, hat is a role")
	quit(0)
