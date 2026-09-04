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
	var starter := Loadout.new()
	if starter.load_local():
		push_error("missing store reported a save")
		quit(1)
		return
	if starter.get_field("chat", "credential") != "":
		push_error("starter leaked a credential")
		quit(1)
		return
	if starter.get_field("chat", "endpoint") == "" or starter.get_field("chat", "model") == "":
		push_error("starter did not point chat")
		quit(1)
		return
	if not starter.get_field("chat", "endpoint").begins_with("https://"):
		push_error("starter chat endpoint has no scheme")
		quit(1)
		return
	if starter.get_field("speech", "model") == "" or starter.get_field("hear", "model") == "":
		push_error("starter did not point speech or hear")
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
	shown.text = "abc"
	panel._on_save()
	if panel.status_text() != "saved on this browser. chat endpoint has no http:// or https://":
		push_error("bare endpoint status is %s" % panel.status_text())
		quit(1)
		return
	shown.text = "https://example.invalid/v1"
	panel._on_save()
	if panel.status_text() != "saved on this browser":
		push_error("schemed endpoint status is %s" % panel.status_text())
		quit(1)
		return
	shown.text = "keep-me"
	panel.close()
	panel.open()
	if panel.field_edit("chat", "endpoint").text != "keep-me":
		push_error("typed text did not survive toggle")
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
	var fresh: Control = packed.instantiate()
	root.add_child(fresh)
	await process_frame
	var blank := fresh.get_node_or_null("Interface/Panel") as LoadoutPanel
	if blank == null:
		push_error("no panel after clear")
		quit(1)
		return
	blank.toggle()
	var pointed: Dictionary = Loadout.default_data()["chat"]
	var chat_ep := blank.field_edit("chat", "endpoint")
	if chat_ep == null or chat_ep.text != str(pointed.get("endpoint", "")):
		push_error("cleared panel did not show starter endpoint")
		quit(1)
		return
	if blank.field_edit("chat", "model").text != str(pointed.get("model", "")):
		push_error("cleared panel did not show starter model")
		quit(1)
		return
	if blank.field_edit("chat", "credential").text != "":
		push_error("starter credential was not blank")
		quit(1)
		return
	blank.field_edit("chat", "credential").text = "only-key"
	blank._on_save()
	if blank.field_edit("speech", "credential").text != "only-key":
		push_error("one key did not fill speech")
		quit(1)
		return
	if blank.field_edit("hear", "credential").text != "only-key":
		push_error("one key did not fill hear")
		quit(1)
		return
	# Paste lands in the focused field, else the first empty credential.
	# The status never echoes the pasted text.
	var pasted := "dummy-key-not-secret"
	blank.open()
	for cap in Loadout.CAPS:
		blank.field_edit(cap, "credential").text = ""
	blank.field_edit("chat", "credential").release_focus()
	blank.paste_text(pasted)
	if blank.field_edit("chat", "credential").text != pasted:
		push_error("paste with no focus missed the first empty credential")
		quit(1)
		return
	if blank.status_text() != LoadoutPanel.PASTED:
		push_error("paste status is %s" % blank.status_text())
		quit(1)
		return
	if pasted in blank.status_text():
		push_error("paste status echoed the text")
		quit(1)
		return
	var model := blank.field_edit("speech", "model")
	model.grab_focus()
	model.text = "voice-"
	model.caret_column = model.text.length()
	blank.paste_text("b")
	if model.text != "voice-b":
		push_error("paste did not go to the focused field: %s" % model.text)
		quit(1)
		return
	model.release_focus()
	blank.paste_text("")
	if blank.status_text() != LoadoutPanel.PASTE_EMPTY:
		push_error("empty paste status is %s" % blank.status_text())
		quit(1)
		return
	blank._on_save()
	if blank.field_edit("hear", "credential").text != pasted:
		push_error("pasted key did not share to hear")
		quit(1)
		return
	var paste_button := false
	for button in blank.find_children("*", "Button", true, false):
		if button.text == "Paste":
			paste_button = true
	if not paste_button:
		push_error("no Paste button")
		quit(1)
		return
	# IME overlay publishes every visible field. The keyboard opens
	# from a page touchstart, not from a Godot focus() after the tap.
	var ime_src := FileAccess.get_file_as_string("res://weave/LoadoutPanel.gd")
	if ime_src.find("touchstart") < 0 or ime_src.find("loomIme") < 0:
		push_error("IME lost the page gesture listener")
		quit(1)
		return
	blank.open()
	var ids := blank.ime_field_ids()
	if ids.find("chat/credential") < 0 or ids.find("speech/model") < 0:
		push_error("IME field list missed a loadout edit: %s" % ", ".join(ids))
		quit(1)
		return
	if ids.size() > Loadout.CAPS.size() * Loadout.FIELDS.size():
		push_error("IME field list grew past the loadout: %s" % ", ".join(ids))
		quit(1)
		return

	b.clear_local()
	print("SMOKE loadout save/export/import/paste + hidden panel")
	quit(0)
