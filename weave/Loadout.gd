class_name Loadout
extends RefCounted

## User loadout. Nothing here is in the deploy.
const STORE := "user://loadout.json"
const VERSION := 1
const CAPS := ["chat", "speech", "hear"]
const FIELDS := ["endpoint", "credential", "model"]
const SECRET_FIELDS := ["credential"]

var data: Dictionary = {}


func _init() -> void:
	data = empty_data()


static func is_secret(field: String) -> bool:
	return field in SECRET_FIELDS


static func empty_cap() -> Dictionary:
	return {"endpoint": "", "credential": "", "model": ""}


static func empty_data() -> Dictionary:
	return {
		"v": VERSION,
		"chat": empty_cap(),
		"speech": empty_cap(),
		"hear": empty_cap(),
	}


func cap_block(cap: String) -> Dictionary:
	var raw: Variant = data.get(cap, {})
	if typeof(raw) != TYPE_DICTIONARY:
		var fresh := empty_cap()
		data[cap] = fresh
		return fresh
	return raw


func set_field(cap: String, field: String, value: String) -> void:
	var block := cap_block(cap)
	block[field] = value


func get_field(cap: String, field: String) -> String:
	return str(cap_block(cap).get(field, ""))


func is_empty() -> bool:
	for cap in CAPS:
		var block := cap_block(cap)
		for field in FIELDS:
			if str(block.get(field, "")).strip_edges() != "":
				return false
	return true


## Caps whose endpoint is set but does not start with http:// or https://.
func endpoints_without_scheme() -> Array[String]:
	var out: Array[String] = []
	for cap in CAPS:
		var ep := get_field(cap, "endpoint").strip_edges()
		if ep != "" and not (ep.begins_with("http://") or ep.begins_with("https://")):
			out.append(cap)
	return out


func to_text() -> String:
	return JSON.stringify(data, "\t")


func from_text(text: String) -> bool:
	var json := JSON.new()
	if json.parse(text) != OK:
		return false
	if typeof(json.data) != TYPE_DICTIONARY:
		return false
	data = _sanitize(json.data)
	return true


func save() -> Error:
	var fa := FileAccess.open(STORE, FileAccess.WRITE)
	if fa == null:
		return FileAccess.get_open_error()
	fa.store_string(to_text())
	return OK


func load_local() -> bool:
	if not FileAccess.file_exists(STORE):
		data = empty_data()
		return false
	var fa := FileAccess.open(STORE, FileAccess.READ)
	if fa == null:
		data = empty_data()
		return false
	if not from_text(fa.get_as_text()):
		data = empty_data()
		return false
	return true


func clear_local() -> void:
	data = empty_data()
	if FileAccess.file_exists(STORE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(STORE))


static func _sanitize(raw: Dictionary) -> Dictionary:
	var out := empty_data()
	if raw.has("v"):
		out["v"] = int(raw.get("v", VERSION))
	for cap in CAPS:
		var src: Variant = raw.get(cap, {})
		if typeof(src) != TYPE_DICTIONARY:
			continue
		var block: Dictionary = src
		var dst: Dictionary = out[cap]
		for field in FIELDS:
			dst[field] = str(block.get(field, ""))
	return out
