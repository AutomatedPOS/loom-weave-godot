extends SceneTree


func _init() -> void:
	var store := ProjectSettings.globalize_path(Loadout.STORE)
	if FileAccess.file_exists(store):
		DirAccess.remove_absolute(store)

	var a := Loadout.new()
	if not a.is_empty():
		push_error("fresh loadout is not empty")
		quit(1)
		return
	a.set_field("chat", "endpoint", "https://example.invalid/v1")
	a.set_field("chat", "credential", "secret-test")
	a.set_field("speech", "model", "voice-a")
	if a.save() != OK:
		push_error("save failed")
		quit(1)
		return

	var b := Loadout.new()
	if not b.load_local():
		push_error("load_local missed the save")
		quit(1)
		return
	if b.get_field("chat", "endpoint") != "https://example.invalid/v1":
		push_error("endpoint did not survive save")
		quit(1)
		return
	if b.get_field("chat", "credential") != "secret-test":
		push_error("credential did not survive save")
		quit(1)
		return
	if b.get_field("speech", "model") != "voice-a":
		push_error("speech model did not survive save")
		quit(1)
		return
	if b.get_field("hear", "endpoint") != "":
		push_error("empty hear field was filled")
		quit(1)
		return

	var c := Loadout.new()
	if not c.from_text(b.to_text()):
		push_error("roundtrip parse failed")
		quit(1)
		return
	if c.get_field("chat", "credential") != "secret-test":
		push_error("export text dropped credential")
		quit(1)
		return

	var before := c.to_text()
	if c.from_text("{not json"):
		push_error("bad json was accepted")
		quit(1)
		return
	if c.to_text() != before:
		push_error("bad import clobbered the loadout")
		quit(1)
		return

	# Scene checks need a live tree: _enter_tree and _ready have not run
	# inside SceneTree._init. Defer them one frame.
	_scene_checks.call_deferred(b)


func _scene_checks(b: Loadout) -> void:
	var packed := load("res://weave/Main.tscn")
	var main: Control = packed.instantiate()
	root.add_child(main)
	await process_frame
	var panel := main.get_node_or_null("Interface/Panel") as LoadoutPanel
	if panel == null:
		push_error("no Interface/Panel")
		quit(1)
		return
	if panel.visible:
		push_error("panel visible on first screen")
		quit(1)
		return
	var gear := main.get_node_or_null("Interface/Gear")
	if gear == null:
		push_error("gear missing")
		quit(1)
		return
	if not (gear is BaseButton):
		push_error("gear is not a button")
		quit(1)
		return
	panel.toggle()
	if not panel.visible:
		push_error("panel did not open")
		quit(1)
		return
	var shown: LineEdit = panel.field_edit("chat", "endpoint")
	if shown == null or shown.text != "https://example.invalid/v1":
		push_error("panel did not show the saved endpoint")
		quit(1)
		return
	panel.close()
	if panel.visible:
		push_error("panel did not close")
		quit(1)
		return

	# Base install has no vendor and no secrets in res://.
	for path in ["res://weave/Loadout.gd", "res://weave/LoadoutPanel.gd", "res://weave/LoadoutSection.gd", "res://weave/Main.gd", "res://weave/theme/Tokens.gd", "res://weave/theme/LoomTheme.gd"]:
		var res := FileAccess.get_file_as_string(path)
		for word in ["OpenAI", "Anthropic", "openai", "anthropic", "api.openai"]:
			if word in res:
				push_error("vendor in %s: %s" % [path, word])
				quit(1)
				return

	b.clear_local()
	print("SMOKE loadout save/export/import + hidden panel")
	quit(0)
