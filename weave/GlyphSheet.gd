class_name GlyphSheet
extends Control

## The four noun tiles and the null on a black field. Picture for
## the owner's Check. Not the first screen. Rails stay off. The
## packet sheets in artifacts/glyph-look/ are the reference; this
## is the live Godot after-image of the same geometry.


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func _draw() -> void:
	var font := get_theme_default_font()
	var tile := float(LoomTokens.GLYPH_TILE)
	var gap := float(LoomTokens.SPACE_5 + LoomTokens.SPACE_5)
	var labels := ["human", "robot", "process", "tool"]
	var cols := float(LoomGlyphs.SKINS.size())
	var total := cols * tile + (cols - 1.0) * gap
	var x0 := (size.x - total) * 0.5
	var y := size.y * 0.22
	for i in LoomGlyphs.SKINS.size():
		var origin := Vector2(x0 + float(i) * (tile + gap), y)
		LoomGlyphs.draw_tile(self, origin, tile, LoomGlyphs.SKINS[i], &"hollow")
		_caps(font, Vector2(origin.x + tile * 0.5, origin.y + tile + LoomTokens.SPACE_5), labels[i], LoomTokens.DIM)
		var solid := origin + Vector2(0, tile + float(LoomTokens.SPACE_5) * 4)
		LoomGlyphs.draw_tile(self, solid, tile, LoomGlyphs.SKINS[i], &"solid")
	var null_c := Vector2(size.x * 0.5 - tile * 0.5, y + tile * 2.0 + float(LoomTokens.SPACE_5) * 8)
	LoomGlyphs.draw_tile(self, null_c, tile, &"null", &"hollow")
	_caps(font, Vector2(null_c.x + tile * 0.5, null_c.y + tile + LoomTokens.SPACE_4), "null", LoomTokens.DIM)


func _caps(font: Font, pos: Vector2, text: String, color: Color) -> void:
	var s := text.to_upper()
	var w := font.get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, LoomTokens.TEXT_SM).x
	draw_string(font, Vector2(pos.x - w * 0.5, pos.y), s, HORIZONTAL_ALIGNMENT_LEFT, -1, LoomTokens.TEXT_SM, color)
