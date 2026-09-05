extends SceneTree

## Glyph smoke. Four packet tiles. Diamond retired. Frame is the hit.
## Light palette sits beside dark. Canvas draws through LoomGlyphs.
## Nothing writes.


func _fail(msg: String) -> void:
	push_error(msg)
	quit(1)


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	if LoomGlyphs.KINDS != [&"persona", &"process", &"tool"]:
		_fail("noun kinds are not persona, process, tool")
		return
	if LoomGlyphs.SKINS != [&"human", &"robot", &"process", &"tool"]:
		_fail("skins are not human, robot, process, tool")
		return
	if LoomGlyphs.skin_for(&"persona", "Brains") != &"robot":
		_fail("Brains is not the robot placeholder")
		return
	if LoomGlyphs.skin_for(&"persona", "Archivus") != &"human":
		_fail("Archivus is not the human placeholder")
		return
	if LoomGlyphs.stroke_px(24.0) != 1.0:
		_fail("chip stroke did not snap to 1 px")
		return
	if LoomGlyphs.stroke_px(64.0) != 2.0:
		_fail("native stroke is not 2 px")
		return
	if not LoomGlyphs.frame_has_point(&"persona", Vector2.ZERO, 64.0, Vector2(32, 32)):
		_fail("persona frame missed its centre")
		return
	if LoomGlyphs.frame_has_point(&"persona", Vector2.ZERO, 64.0, Vector2(0, 0)):
		_fail("persona frame hit a corner the circle does not own")
		return
	if not LoomGlyphs.frame_has_point(&"process", Vector2.ZERO, 64.0, Vector2(32, 32)):
		_fail("process frame missed its centre")
		return
	if not LoomGlyphs.frame_has_point(&"tool", Vector2.ZERO, 64.0, Vector2(32, 32)):
		_fail("tool frame missed its centre")
		return

	var src := FileAccess.get_file_as_string("res://weave/Glyphs.gd")
	for word in ["add_theme_color_override", "add_theme_font_size_override", "add_theme_stylebox_override"]:
		if word in src:
			_fail("glyphs style by hand: %s" % word)
			return
	if "Color(" in src:
		_fail("glyphs picked a colour")
		return
	if "HAT_ROLE" in src or "func _hat" in src:
		_fail("hat-as-role survived the packet")
		return
	if "draw_on" in src:
		_fail("old draw_on API is still here")
		return
	for word in ["LoomTokens.HAZARD", "LoomTokens.TASK", "LoomTokens.CHANGED"]:
		if word not in src:
			_fail("glyphs lost the accent grammar: %s" % word)
			return

	var canvas_src := FileAccess.get_file_as_string("res://weave/Canvas.gd")
	if "LoomGlyphs.draw_tile" not in canvas_src or "LoomGlyphs.draw_frame_only" not in canvas_src:
		_fail("canvas does not draw through LoomGlyphs tiles")
		return
	if "frame_has_point" not in canvas_src:
		_fail("canvas drop is not the frame")
		return
	if "diamond" in canvas_src.to_lower():
		_fail("canvas still names the diamond")
		return
	if "draw_on" in canvas_src:
		_fail("canvas still calls draw_on")
		return

	var sheet := GlyphSheet.new()
	root.add_child(sheet)
	await process_frame
	if sheet.get_child_count() > 0:
		_fail("glyph sheet grew child controls")
		return
	var sheet_src := FileAccess.get_file_as_string("res://weave/GlyphSheet.gd")
	if "HAT_ROLE" in sheet_src or "a role is a hat" in sheet_src:
		_fail("sheet still draws a hat")
		return
	if "draw_tile" not in sheet_src:
		_fail("sheet does not draw the packet tiles")
		return

	if not FileAccess.file_exists("res://artifacts/glyph-look/PACKET.md"):
		_fail("packet index is missing")
		return
	if not FileAccess.file_exists("res://artifacts/glyph-look/tokens.json"):
		_fail("packet tokens.json is missing")
		return

	if LoomTokens.HAZARD != Color("#8B1E1E") or LoomTokens.TASK != Color("#D99A1F") or LoomTokens.CHANGED != Color("#6B8FAE"):
		_fail("dark accents are not the packet")
		return
	LoomTokens.apply_mode(LoomTokens.MODE_LIGHT)
	if LoomTokens.BACKDROP != Color("#FFFFFF"):
		_fail("light field is not white")
		return
	if LoomTokens.HAZARD != Color("#8B1E1E"):
		_fail("hazard moved in light mode")
		return
	if LoomTokens.TASK != Color("#A06E10") or LoomTokens.CHANGED != Color("#4F7291"):
		_fail("light task/changed are not the pulled-down packet values")
		return
	LoomTokens.apply_mode(LoomTokens.MODE_DARK)
	if LoomTokens.BACKDROP != Color("#000000") or LoomTokens.TASK != Color("#D99A1F"):
		_fail("dark mode did not restore")
		return

	print("SMOKE glyphs: four tiles, frame is the hit, diamond retired, both palettes")
	quit(0)
