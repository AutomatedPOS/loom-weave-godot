extends SceneTree

## Theme smoke. The interface takes every colour, size, and font size
## from LoomTokens through LoomTheme. Nothing is styled by hand.


func _fail(msg: String) -> void:
	push_error(msg)
	quit(1)


func _init() -> void:
	LoomTokens.apply_mode(LoomTokens.MODE_DARK)
	var t := LoomTheme.build()
	for name in LoomTokens.COLORS:
		if not t.has_color(name, LoomTokens.THEME_TYPE):
			_fail("theme lacks Loom colour %s" % name)
			return
		if t.get_color(name, LoomTokens.THEME_TYPE) != LoomTokens.COLORS[name]:
			_fail("theme colour %s is not the token" % name)
			return
	# Bible 4.2: three accents, each on the Loom type, none orange, none
	# the old one-colour ACCENT. Bible 4.7: ranked task, hazard, changed;
	# two show at a time.
	if t.has_color(&"accent", LoomTokens.THEME_TYPE):
		_fail("the old single accent is still published")
		return
	var seen: Array[Color] = []
	for name in LoomTokens.ACCENT_RANK:
		if not t.has_color(name, LoomTokens.THEME_TYPE):
			_fail("accent %s is not on the Loom type" % name)
			return
		var c := t.get_color(name, LoomTokens.THEME_TYPE)
		if c.a < 1.0:
			_fail("accent %s is not opaque" % name)
			return
		if c.is_equal_approx(Color(0.93, 0.45, 0.13, 1)):
			_fail("accent %s is the old orange; orange is out" % name)
			return
		if seen.has(c):
			_fail("accent %s repeats another accent" % name)
			return
		seen.append(c)
	if LoomTokens.ACCENT_RANK != [&"task", &"hazard", &"changed"] or LoomTokens.ACCENT_SHOW != 2:
		_fail("accent precedence is not task, hazard, changed, top two")
		return
	if t.get_color(&"hazard", LoomTokens.THEME_TYPE) != LoomTokens.HAZARD \
			or t.get_color(&"task", LoomTokens.THEME_TYPE) != LoomTokens.TASK \
			or t.get_color(&"changed", LoomTokens.THEME_TYPE) != LoomTokens.CHANGED:
		_fail("an accent on the theme is not its token")
		return
	if LoomTokens.HAZARD != Color("#8B1E1E") or LoomTokens.TASK != Color("#D99A1F") or LoomTokens.CHANGED != Color("#6B8FAE"):
		_fail("dark accents are not the glyph packet")
		return
	LoomTokens.apply_mode(LoomTokens.MODE_LIGHT)
	var light := LoomTheme.build()
	if LoomTokens.HAZARD != Color("#8B1E1E"):
		_fail("light hazard is not oxblood")
		return
	if LoomTokens.TASK != Color("#A06E10") or LoomTokens.CHANGED != Color("#4F7291"):
		_fail("light task/changed are not the pulled-down packet values")
		return
	if light.get_color(&"task", LoomTokens.THEME_TYPE) != LoomTokens.TASK \
			or light.get_color(&"changed", LoomTokens.THEME_TYPE) != LoomTokens.CHANGED \
			or light.get_color(&"backdrop", LoomTokens.THEME_TYPE) != Color("#FFFFFF"):
		_fail("light theme did not publish the light palette")
		return
	LoomTokens.apply_mode(LoomTokens.MODE_DARK)
	t = LoomTheme.build()
	var edit_box := t.get_stylebox(&"normal", &"LineEdit") as StyleBoxFlat
	if edit_box == null or edit_box.bg_color != LoomTokens.WELL or edit_box.border_width_left != LoomTokens.BORDER:
		_fail("LineEdit normal box is not the well")
		return
	var panel_box := t.get_stylebox(&"panel", &"PanelContainer") as StyleBoxFlat
	if panel_box == null or panel_box.bg_color != LoomTokens.SURFACE or panel_box.border_color != LoomTokens.EDGE:
		_fail("PanelContainer box is not the surface")
		return
	for pair in [
		[LoomTokens.V_TITLE, &"Label"],
		[LoomTokens.V_MUTED, &"Label"],
		[LoomTokens.V_GEAR, &"Button"],
	]:
		if t.get_type_variation_base(pair[0]) != pair[1]:
			_fail("variation %s does not extend %s" % [pair[0], pair[1]])
			return
	if t.get_font_size(&"font_size", LoomTokens.V_TITLE) != LoomTokens.TEXT_LG:
		_fail("title size is not TEXT_LG")
		return
	if t.get_color(&"font_color", LoomTokens.V_MUTED) != LoomTokens.DIM:
		_fail("muted label is not DIM")
		return

	_scene_checks.call_deferred()


func _scene_checks() -> void:
	var packed := load("res://weave/Main.tscn")
	var main: Control = packed.instantiate()
	root.add_child(main)
	await process_frame
	for child in main.get_node("Interface").get_children():
		if child is Control and child.theme != LoomTheme.shared():
			_fail("%s on the Interface layer lacks the shared theme" % child.name)
			return
	var backdrop := main.get_node("Backdrop") as ColorRect
	if backdrop.color != LoomTokens.BACKDROP:
		_fail("backdrop is not the token")
		return

	var gear := main.get_node("Interface/Gear") as SettingsGear
	if gear.theme_type_variation != LoomTokens.V_GEAR:
		_fail("gear is not on the GearButton variation")
		return
	if gear.has_theme_stylebox_override(&"normal"):
		_fail("gear still carries a stylebox override")
		return
	if gear.get_theme_color(&"ink", LoomTokens.THEME_TYPE) != LoomTokens.INK:
		_fail("gear cannot read ink from the theme")
		return
	if gear.size != Vector2(LoomTokens.GEAR_SIZE, LoomTokens.GEAR_SIZE):
		_fail("gear size is %s not the token" % gear.size)
		return

	var panel := main.get_node("Interface/Panel") as LoadoutPanel
	if panel == null or not (panel is PanelContainer):
		_fail("panel is not a PanelContainer")
		return
	var sections := panel.find_children("*", "LoadoutSection", true, false)
	if sections.size() != Loadout.CAPS.size():
		_fail("expected %d sections, found %d" % [Loadout.CAPS.size(), sections.size()])
		return
	for cap in Loadout.CAPS:
		for field in Loadout.FIELDS:
			var e := panel.field_edit(cap, field)
			if e == null:
				_fail("no edit for %s.%s" % [cap, field])
				return
			if e.secret != Loadout.is_secret(field):
				_fail("%s.%s secret flag is wrong" % [cap, field])
				return
			if e.has_theme_stylebox_override(&"normal") or e.has_theme_color_override(&"font_color"):
				_fail("%s.%s is styled by hand" % [cap, field])
				return
	for l in panel.find_children("*", "Label", true, false):
		if l.has_theme_color_override(&"font_color") or l.has_theme_font_size_override(&"font_size"):
			_fail("label '%s' is styled by hand" % l.text)
			return
	for b in panel.find_children("*", "Button", true, false):
		if b.has_theme_stylebox_override(&"normal"):
			_fail("button '%s' is styled by hand" % b.text)
			return

	panel.toggle()
	var vp := root.get_visible_rect().size
	var r := panel.get_rect()
	if r.position.y < LoomTokens.INSET or r.end.y > vp.y or r.end.x > vp.x:
		_fail("panel %s leaves the viewport %s" % [r, vp])
		return
	if r.size.x != LoomTokens.PANEL_W:
		_fail("panel width %s is not the token" % r.size.x)
		return
	panel.field_edit("chat", "endpoint").text = "  kept  "
	panel.close()
	panel.open()
	if panel.field_edit("chat", "endpoint").text != "  kept  ":
		_fail("toggle discarded an unsaved edit")
		return
	panel.close()

	print("SMOKE theme: tokens flow through LoomTheme, no hand styling")
	quit(0)
