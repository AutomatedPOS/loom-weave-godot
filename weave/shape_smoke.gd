extends SceneTree

## Shape is a query. These tests fail if a snapshot sneaks into the
## store. The canvas restore is in canvas_smoke; this file is the
## allowlist itself.


func _fail(msg: String) -> void:
	push_error(msg)
	quit(1)


func _init() -> void:
	LoomShape.clear_current()
	var empty := LoomShape.empty()
	if LoomShape.validate(empty) != "":
		_fail("empty shape is invalid: %s" % LoomShape.validate(empty))
		return
	var text := LoomShape.dumps(empty)
	if text == "" or "body" in text or "justDid" in text:
		_fail("empty dumps leaked data")
		return
	var again := LoomShape.parse(text)
	if again.is_empty() or str(again.get("kind", "")) != "shape":
		_fail("empty did not round-trip")
		return

	var bad := LoomShape.empty()
	bad["body"] = "a snapshot"
	if LoomShape.validate(bad) == "":
		_fail("body was accepted")
		return
	bad = LoomShape.empty()
	bad["credential"] = "sk-never"
	if LoomShape.validate(bad) == "":
		_fail("credential was accepted")
		return
	bad = LoomShape.empty()
	(bad["windows"] as Array)[0]["transcript"] = ["hello"]
	if LoomShape.validate(bad) == "":
		_fail("transcript was accepted")
		return
	bad = LoomShape.empty()
	(bad["windows"] as Array)[0]["id"] = "aaaaaaaa-aaaa-aaaa-aaaa-000000000001"
	if LoomShape.validate(bad) == "":
		_fail("window guid-as-id was accepted")
		return

	var brains := "13bc00fd-1276-498d-9b35-c2980c5fd10f"
	var op := "65d82731-e9c3-451a-a223-be0bb4d56b06"
	var shape := LoomShape.empty()
	(shape["windows"] as Array).append({
		"id": "seat",
		"slot": 0,
		"ask": {"kind": "node", "guid": op},
	})
	(shape["attachments"] as Array).append({
		"from": {"kind": "roster", "guid": brains},
		"onto": {"kind": "window", "id": "seat"},
	})
	if LoomShape.validate(shape) != "":
		_fail("legal attachment was rejected: %s" % LoomShape.validate(shape))
		return
	if LoomShape.write_current(shape) != OK:
		_fail("write_current failed")
		return
	var loaded := LoomShape.read_current()
	if loaded.is_empty():
		_fail("read_current missed the file")
		return
	var blob := JSON.stringify(loaded)
	if brains not in blob:
		_fail("stored query dropped the persona guid")
		return
	if "sk-never" in blob or "justDid" in blob:
		_fail("stored query grew data")
		return
	if LoomShape.parse("{not json").is_empty() == false:
		_fail("bad json was accepted")
		return
	LoomShape.clear_current()
	if not LoomShape.read_current().is_empty():
		_fail("clear_current left a file")
		return
	print("SMOKE shape query allowlist + user://shapes store")
	quit(0)
