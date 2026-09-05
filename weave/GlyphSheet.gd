class_name GlyphSheet
extends Control

## The three noun marks on a black field. Picture for the owner's
## Check. Not the first screen. Rails stay off.


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func _draw() -> void:
	var font := get_theme_default_font()
	var tile := float(LoomTokens.GLYPH_TILE)
	var gap := float(LoomTokens.SPACE_5 + LoomTokens.SPACE_5)
	var total := 3.0 * tile + 2.0 * gap
	var x0 := (size.x - total) * 0.5
	var y := size.y * 0.32
	var r := tile * 0.38
	var labels := ["personas", "processes", "tools"]
	for i in LoomGlyphs.KINDS.size():
		var origin := Vector2(x0 + i * (tile + gap), y)
		var c := origin + Vector2(tile, tile) * 0.5
		LoomGlyphs.draw_on(self, LoomGlyphs.KINDS[i], c, r, Color.TRANSPARENT, LoomTokens.INK)
		_caps(font, Vector2(c.x, origin.y + tile + LoomTokens.SPACE_5), labels[i], LoomTokens.DIM)
	# Same bust, a hat on it: that is a role, not a second body.
	var hat_c := Vector2(x0 + tile * 0.5, y + tile + LoomTokens.SPACE_5 * 5 + r)
	LoomGlyphs.draw_on(self, &"persona", hat_c, r, Color.TRANSPARENT, LoomTokens.INK, LoomGlyphs.HAT_ROLE)
	_caps(font, Vector2(hat_c.x, hat_c.y + r + LoomTokens.SPACE_4), "a role is a hat", LoomTokens.DIM)


func _caps(font: Font, pos: Vector2, text: String, color: Color) -> void:
	var s := text.to_upper()
	var w := font.get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, LoomTokens.TEXT_SM).x
	draw_string(font, Vector2(pos.x - w * 0.5, pos.y), s, HORIZONTAL_ALIGNMENT_LEFT, -1, LoomTokens.TEXT_SM, color)
