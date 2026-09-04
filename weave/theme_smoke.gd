extends SceneTree


func _fail(msg: String) -> void:
	push_error(msg)
	quit(1)


func _init() -> void:
	var store := ProjectSettings.globalize_path(ThemeEngine.STORE)
	if FileAccess.file_exists(store):
		DirAccess.remove_absolute(store)

	var e := ThemeEngine.new()
	if not e.boot():
		_fail("boot failed: %s" % e.last_error)
		return
	if e.get_color("surface.base") != Color.html("#12141a"):
		_fail("default surface.base is wrong")
		return
	if e.get_color("text.primary") != Color.html("#ffffff"):
		_fail("default text.primary is wrong")
		return
	if not e.css_vars.has("--surface-base"):
		_fail("css var --surface-base missing")
		return
	if e.css_vars["--menu-item-bg-hover"] != "#1c1f28":
		_fail("css var hover is %s" % e.css_vars.get("--menu-item-bg-hover", ""))
		return
	if e.get_number("space.gutter") != 16.0:
		_fail("space.gutter is %s" % e.get_number("space.gutter"))
		return
	if e.get_font("font.heading") != "Barlow Condensed":
		_fail("font.heading is %s" % e.get_font("font.heading"))
		return

	var minimal := {
		"$schema": ThemeEngine.SCHEMA,
		"meta": {"id": "thin", "name": "Thin", "author": "test", "base": "dark"},
		"primitives": {
			"color": {"brand-500": "#3ba7ff"},
		},
	}
	if not e.ingest(minimal):
		_fail("minimal theme rejected: %s" % e.last_error)
		return

	var prior := e.get_color("accent.default")
	var bad_schema := {"meta": {"id": "x"}, "primitives": {}}
	if e.ingest(bad_schema):
		_fail("missing $schema was accepted")
		return
	if e.get_color("accent.default") != prior:
		_fail("failed ingest mutated preview")
		return

	if e.ingest({"$schema": "fence.theme/v0", "primitives": {}}):
		_fail("unknown schema was accepted")
		return

	var drop_pack := {
		"$schema": ThemeEngine.SCHEMA,
		"nope": 1,
		"primitives": {"color": {"neon-1": "#ff00ff", "brand-500": "#2f9cff"}},
	}
	if not e.apply_patch(drop_pack):
		_fail("patch with unknown keys failed: %s" % e.last_error)
		return
	var dropped := false
	for line in e.log_lines:
		if "neon-1" in line or "nope" in line:
			dropped = true
	if not dropped:
		_fail("unknown keys were not logged")
		return
	if e.get_color("color.brand-500") != Color.html("#2f9cff"):
		_fail("whitelisted patch color missed")
		return

	var literal := {
		"$schema": ThemeEngine.SCHEMA,
		"semantic": {"text.primary": "#ffffff"},
	}
	if e.apply_patch(literal):
		_fail("literal in semantic was accepted")
		return

	var dangling := {
		"$schema": ThemeEngine.SCHEMA,
		"semantic": {"text.primary": "{color.missing}"},
	}
	if e.apply_patch(dangling):
		_fail("dangling ref was accepted")
		return

	var cycle := {
		"$schema": ThemeEngine.SCHEMA,
		"semantic": {
			"text.primary": "{text.muted}",
			"text.muted": "{text.primary}",
		},
	}
	if e.apply_patch(cycle):
		_fail("cycle was accepted")
		return

	var bad_color := {
		"$schema": ThemeEngine.SCHEMA,
		"primitives": {"color": {"ink-900": "blueish"}},
	}
	if e.apply_patch(bad_color):
		_fail("bad color was accepted")
		return

	var bad_space := {
		"$schema": ThemeEngine.SCHEMA,
		"primitives": {"space": ["wide", 4, 8, 12, 16, 24, 32, 48]},
	}
	if e.apply_patch(bad_space):
		_fail("non-number space was accepted")
		return

	var saved_brand := e.get_color("color.brand-500")
	var contrast_fail := {
		"$schema": ThemeEngine.SCHEMA,
		"primitives": {
			"color": {
				"ink-000": "#808080",
				"ink-100": "#808080",
				"ink-200": "#808080",
				"ink-800": "#808080",
				"ink-900": "#808080",
				"brand-500": "#808080",
			},
		},
	}
	if e.apply_patch(contrast_fail):
		_fail("unrecoverable contrast was accepted")
		return
	if e.get_color("color.brand-500") != saved_brand:
		_fail("failed contrast patch mutated preview")
		return

	var nudge := {
		"$schema": ThemeEngine.SCHEMA,
		"primitives": {"color": {"ink-800": "#6e7380"}},
	}
	if not e.apply_patch(nudge):
		_fail("close contrast should nudge: %s" % e.last_error)
		return
	if not e.nudged.has("text.muted"):
		_fail("text.muted was not nudged")
		return

	e.refresh()
	if e.get_color("surface.base") != Color.html("#12141a"):
		_fail("refresh did not restore last good")
		return

	var persist := {
		"$schema": ThemeEngine.SCHEMA,
		"primitives": {"color": {"brand-500": "#44ccff"}},
	}
	if not e.apply_patch(persist):
		_fail("persist patch failed: %s" % e.last_error)
		return
	if e.save() != OK:
		_fail("theme save failed")
		return
	var e2 := ThemeEngine.new()
	if not e2.boot():
		_fail("re-boot after save failed: %s" % e2.last_error)
		return
	if e2.get_color("color.brand-500") != Color.html("#44ccff"):
		_fail("saved theme did not reload")
		return
	if FileAccess.file_exists(store):
		DirAccess.remove_absolute(store)

	var packed := load("res://weave/Main.tscn")
	var main: Control = packed.instantiate()
	root.add_child(main)
	var backdrop := main.get_node_or_null("Backdrop") as ColorRect
	if backdrop == null or backdrop.color != Color(0, 0, 0, 1):
		_fail("backdrop is not black after theme boot")
		return
	var chat := main.get_node_or_null("Interface/Chat")
	if chat != null and chat.visible:
		_fail("chat visible before capabilities are green")
		return

	print("SMOKE theme ingest/whitelist/refs/contrast/patch/css")
	quit(0)
