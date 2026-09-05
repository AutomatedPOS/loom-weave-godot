class_name LoomShape
extends RefCounted

## A saved shape is a query. Version 1, allowlisted. Nothing here is
## tree data, a transcript, a credential, or a snapshot of a pane.
## The Python twin is scripts/canvas_model.py; if a key is legal here
## and forbidden there, the Python tests are the ones that fail the
## build. Persistence is user://shapes/current.json, the same class of
## store as the loadout, for shapes.

const DIR := "user://shapes"
const CURRENT := "user://shapes/current.json"
const VERSION := 1
const KIND := "shape"
const SHAPE_KEYS := ["v", "kind", "as_of", "windows", "attachments"]
const WINDOW_KEYS := ["id", "slot", "ask"]
const ASK_KINDS := ["none", "node", "kids", "path", "roster", "pdca"]
const RAILS := ["personas", "processes", "tools"]
const REF_KINDS := ["roster", "window"]
const ONTO_KINDS := ["window"]
const FORBIDDEN := [
	"body", "justDid", "next", "waitingOn", "context", "chose",
	"consequences", "nodes", "children", "children_of", "by_guid",
	"transcript", "messages", "session", "credential", "endpoint",
	"model", "inbox", "snapshot", "text", "items", "panes",
]

const GUID_PATTERN := "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"
const DAY_PATTERN := "^[0-9]{4}-[0-9]{2}-[0-9]{2}$"


static func empty() -> Dictionary:
	return {
		"v": VERSION,
		"kind": KIND,
		"as_of": "now",
		"windows": [{"id": "field", "slot": 0, "ask": {"kind": "none"}}],
		"attachments": [],
	}


static func dumps(shape: Dictionary) -> String:
	var err := validate(shape)
	if err != "":
		return ""
	return JSON.stringify(shape, "\t") + "\n"


static func parse(text: String) -> Dictionary:
	var json := JSON.new()
	if json.parse(text) != OK or typeof(json.data) != TYPE_DICTIONARY:
		return {}
	var data: Dictionary = json.data
	if validate(data) != "":
		return {}
	return data


static func validate(obj: Variant) -> String:
	if typeof(obj) != TYPE_DICTIONARY:
		return "shape must be an object"
	var hit := _forbidden(obj)
	if hit != "":
		return hit
	var shape: Dictionary = obj
	for key in shape.keys():
		if not SHAPE_KEYS.has(str(key)):
			return "shape extra keys: %s" % key
	if str(shape.get("kind", "")) != KIND:
		return "kind must be shape"
	if _as_int(shape.get("v", 0)) != VERSION:
		return "v must be 1"
	var as_of := str(shape.get("as_of", "now"))
	if as_of.strip_edges() == "":
		return "as_of must be a string"
	var day_err := _as_of_ok(as_of)
	if day_err != "":
		return day_err
	var windows: Variant = shape.get("windows")
	if typeof(windows) != TYPE_ARRAY or (windows as Array).is_empty():
		return "windows must be a non-empty list"
	var ids: Dictionary = {}
	for window in windows:
		var werr := _validate_window(window, ids)
		if werr != "":
			return werr
	var attachments: Variant = shape.get("attachments", [])
	if typeof(attachments) != TYPE_ARRAY:
		return "attachments must be a list"
	for att in attachments:
		var aerr := _validate_attachment(att, ids)
		if aerr != "":
			return aerr
	return ""


static func write_current(shape: Dictionary) -> Error:
	var text := dumps(shape)
	if text == "":
		return ERR_INVALID_DATA
	var dir := DirAccess.open("user://")
	if dir == null:
		return ERR_CANT_OPEN
	if not dir.dir_exists("shapes"):
		var mk := dir.make_dir("shapes")
		if mk != OK:
			return mk
	var fa := FileAccess.open(CURRENT, FileAccess.WRITE)
	if fa == null:
		return FileAccess.get_open_error()
	fa.store_string(text)
	return OK


static func read_current() -> Dictionary:
	if not FileAccess.file_exists(CURRENT):
		return {}
	var fa := FileAccess.open(CURRENT, FileAccess.READ)
	if fa == null:
		return {}
	return parse(fa.get_as_text())


static func clear_current() -> void:
	if FileAccess.file_exists(CURRENT):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(CURRENT))


static func _validate_window(window: Variant, ids: Dictionary) -> String:
	if typeof(window) != TYPE_DICTIONARY:
		return "window must be an object"
	var win: Dictionary = window
	for key in win.keys():
		if not WINDOW_KEYS.has(str(key)):
			return "window extra keys: %s" % key
	var wid := str(win.get("id", ""))
	if wid.strip_edges() == "" or _is_guid(wid):
		return "window id must be a non-guid local id"
	if ids.has(wid):
		return "duplicate window id %s" % wid
	ids[wid] = true
	if not _is_int(win.get("slot")):
		return "slot must be an integer"
	var ask: Variant = win.get("ask")
	if typeof(ask) != TYPE_DICTIONARY:
		return "ask must be an object"
	var kind := str(ask.get("kind", ""))
	if not ASK_KINDS.has(kind):
		return "ask.kind %s is not a query" % kind
	var allowed := ["kind"]
	if kind in ["node", "kids", "path"]:
		allowed.append("guid")
		var guid := str(ask.get("guid", ""))
		if not _is_guid(guid):
			return "ask.guid must be a tree guid"
	elif kind == "roster":
		allowed.append("rail")
		if not RAILS.has(str(ask.get("rail", ""))):
			return "ask.rail must be personas, processes, or tools"
	for key in ask.keys():
		if not allowed.has(str(key)):
			return "ask extra keys: %s" % key
	return ""


static func _validate_attachment(att: Variant, ids: Dictionary) -> String:
	if typeof(att) != TYPE_DICTIONARY:
		return "attachment must be an object"
	var row: Dictionary = att
	for key in row.keys():
		if str(key) != "from" and str(key) != "onto":
			return "attachment extra keys: %s" % key
	var src_err := _validate_ref(row.get("from"), "from", ids, true)
	if src_err != "":
		return src_err
	return _validate_ref(row.get("onto"), "onto", ids, false)


static func _validate_ref(ref: Variant, side: String, ids: Dictionary, allow_roster: bool) -> String:
	if typeof(ref) != TYPE_DICTIONARY:
		return "%s must be an object" % side
	var row: Dictionary = ref
	for key in row.keys():
		if str(key) != "kind" and str(key) != "guid" and str(key) != "id":
			return "%s extra keys: %s" % [side, key]
	var kind := str(row.get("kind", ""))
	if allow_roster:
		if not REF_KINDS.has(kind):
			return "%s.kind %s is not allowed" % [side, kind]
	elif not ONTO_KINDS.has(kind):
		return "%s.kind %s is not allowed" % [side, kind]
	if kind == "roster":
		if not _is_guid(str(row.get("guid", ""))):
			return "%s.guid must be a tree guid" % side
		if row.has("id"):
			return "%s roster ref cannot carry a window id" % side
	else:
		var wid := str(row.get("id", ""))
		if not ids.has(wid):
			return "%s.id must name a window in this shape" % side
		if row.has("guid"):
			return "%s window ref cannot carry a tree guid" % side
	return ""


static func _forbidden(obj: Variant) -> String:
	if typeof(obj) == TYPE_DICTIONARY:
		for key in obj.keys():
			if FORBIDDEN.has(str(key)):
				return "shape carries data keys: %s" % key
			var child := _forbidden(obj[key])
			if child != "":
				return child
	elif typeof(obj) == TYPE_ARRAY:
		for item in obj:
			var child := _forbidden(item)
			if child != "":
				return child
	return ""


static func _as_of_ok(as_of: String) -> String:
	var text := as_of.strip_edges()
	if text == "now":
		return ""
	if "T" in text:
		text = text.split("T")[0]
	var re := RegEx.new()
	re.compile(DAY_PATTERN)
	if re.search(text) == null:
		return "as_of is not a UTC day: %s" % as_of
	return ""


static func _is_guid(text: String) -> bool:
	var re := RegEx.new()
	re.compile(GUID_PATTERN)
	return re.search(text) != null


static func _is_int(v: Variant) -> bool:
	if typeof(v) == TYPE_INT:
		return true
	if typeof(v) == TYPE_FLOAT:
		return is_equal_approx(float(v), roundf(float(v)))
	return false


static func _as_int(v: Variant) -> int:
	return int(v)
