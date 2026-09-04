class_name LoomTheme
extends RefCounted

## Builds the interface Theme from LoomTokens. Main hands shared() to each
## Control on the Interface layer; their subtrees inherit. Godot does not
## propagate a Theme across a CanvasLayer, so the Window theme is not enough.
## No node in weave/ calls add_theme_*_override for style; pick a type
## variation instead. Container separations and margins are layout and
## still come from LoomTokens.

static var _shared: Theme


static func shared() -> Theme:
	if _shared == null:
		_shared = build()
	return _shared


static func build() -> Theme:
	var t := Theme.new()
	t.default_font_size = LoomTokens.TEXT_MD
	_colors(t)
	_labels(t)
	_line_edits(t)
	_buttons(t)
	_panels(t)
	return t


static func _colors(t: Theme) -> void:
	for name in LoomTokens.COLORS:
		t.set_color(name, LoomTokens.THEME_TYPE, LoomTokens.COLORS[name])


static func _labels(t: Theme) -> void:
	t.set_color(&"font_color", &"Label", LoomTokens.INK)
	t.set_font_size(&"font_size", &"Label", LoomTokens.TEXT_MD)

	t.add_type(LoomTokens.V_TITLE)
	t.set_type_variation(LoomTokens.V_TITLE, &"Label")
	t.set_font_size(&"font_size", LoomTokens.V_TITLE, LoomTokens.TEXT_LG)

	t.add_type(LoomTokens.V_MUTED)
	t.set_type_variation(LoomTokens.V_MUTED, &"Label")
	t.set_color(&"font_color", LoomTokens.V_MUTED, LoomTokens.DIM)
	t.set_font_size(&"font_size", LoomTokens.V_MUTED, LoomTokens.TEXT_SM)


static func _line_edits(t: Theme) -> void:
	var normal := well_box(LoomTokens.SPACE_2)
	var focus := well_box(LoomTokens.SPACE_2)
	focus.border_color = LoomTokens.INK
	t.set_stylebox(&"normal", &"LineEdit", normal)
	t.set_stylebox(&"focus", &"LineEdit", focus)
	t.set_stylebox(&"read_only", &"LineEdit", normal)
	t.set_color(&"font_color", &"LineEdit", LoomTokens.INK)
	t.set_color(&"font_placeholder_color", &"LineEdit", LoomTokens.DIM)
	t.set_color(&"caret_color", &"LineEdit", LoomTokens.INK)
	t.set_color(&"font_selected_color", &"LineEdit", LoomTokens.INK)
	t.set_color(&"selection_color", &"LineEdit", LoomTokens.EDGE)
	t.set_font_size(&"font_size", &"LineEdit", LoomTokens.TEXT_MD)


static func _buttons(t: Theme) -> void:
	var normal := well_box(LoomTokens.SPACE_3)
	var lit := well_box(LoomTokens.SPACE_3)
	lit.border_color = LoomTokens.INK
	t.set_stylebox(&"normal", &"Button", normal)
	t.set_stylebox(&"hover", &"Button", lit)
	t.set_stylebox(&"pressed", &"Button", lit)
	t.set_stylebox(&"focus", &"Button", StyleBoxEmpty.new())
	t.set_stylebox(&"disabled", &"Button", normal)
	for name in [&"font_color", &"font_hover_color", &"font_pressed_color",
			&"font_focus_color", &"font_hover_pressed_color"]:
		t.set_color(name, &"Button", LoomTokens.INK)
	t.set_color(&"font_disabled_color", &"Button", LoomTokens.DIM)
	t.set_font_size(&"font_size", &"Button", LoomTokens.TEXT_MD)

	# The gear draws itself. Its variation erases every button face.
	t.add_type(LoomTokens.V_GEAR)
	t.set_type_variation(LoomTokens.V_GEAR, &"Button")
	for state in [&"normal", &"hover", &"pressed", &"focus", &"disabled"]:
		t.set_stylebox(state, LoomTokens.V_GEAR, StyleBoxEmpty.new())


static func _panels(t: Theme) -> void:
	var surface := StyleBoxFlat.new()
	surface.bg_color = LoomTokens.SURFACE
	surface.border_color = LoomTokens.EDGE
	surface.set_border_width_all(LoomTokens.BORDER)
	surface.set_corner_radius_all(LoomTokens.RADIUS)
	t.set_stylebox(&"panel", &"PanelContainer", surface)
	t.set_stylebox(&"panel", &"ScrollContainer", StyleBoxEmpty.new())


## A sunken field or button face: well fill, edge border, side padding.
static func well_box(pad_x: int) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = LoomTokens.WELL
	box.border_color = LoomTokens.EDGE
	box.set_border_width_all(LoomTokens.BORDER)
	box.set_corner_radius_all(LoomTokens.RADIUS)
	box.content_margin_left = pad_x
	box.content_margin_right = pad_x
	return box
