class_name TreeLoader
extends RefCounted

var nodes: Array[Dictionary] = []
var by_guid: Dictionary = {}
var children_of: Dictionary = {}
var root: Dictionary = {}
var tree_path: String = ""
var error: String = ""


func load_tree(path: String) -> bool:
	tree_path = path
	nodes.clear()
	by_guid.clear()
	children_of.clear()
	root = {}
	error = ""

	var root_file := path.path_join("thread.json")
	if not FileAccess.file_exists(root_file):
		error = "no thread.json at %s" % path
		return false

	_walk(path)
	if nodes.is_empty():
		error = "no nodes under %s" % path
		return false

	for node in nodes:
		var guid: String = str(node.get("guid", ""))
		if guid == "":
			continue
		by_guid[guid] = node
		var parent: String = str(node.get("isPartOf", ""))
		if not children_of.has(parent):
			children_of[parent] = []
		children_of[parent].append(node)

	for node in nodes:
		if str(node.get("isPartOf", "")) == "":
			root = node
			break
	if root.is_empty():
		root = nodes[0]
	return true


func kids(node: Dictionary) -> Array:
	return children_of.get(str(node.get("guid", "")), [])


func depth_of(node: Dictionary) -> int:
	var d := 0
	var cur := node
	var seen := {}
	while true:
		var parent: String = str(cur.get("isPartOf", ""))
		if parent == "" or not by_guid.has(parent) or seen.has(parent):
			break
		seen[parent] = true
		d += 1
		cur = by_guid[parent]
	return d


func _walk(dir: String) -> void:
	var f := dir.path_join("thread.json")
	if FileAccess.file_exists(f):
		var parsed = _read_json(f)
		if typeof(parsed) == TYPE_DICTIONARY:
			var node: Dictionary = parsed
			node["_path"] = f
			nodes.append(node)
	var da := DirAccess.open(dir)
	if da == null:
		return
	da.list_dir_begin()
	var name := da.get_next()
	while name != "":
		if name.begins_with("."):
			name = da.get_next()
			continue
		if da.current_is_dir():
			_walk(dir.path_join(name))
		name = da.get_next()
	da.list_dir_end()


func _read_json(path: String) -> Variant:
	var fa := FileAccess.open(path, FileAccess.READ)
	if fa == null:
		return null
	var txt := fa.get_as_text()
	var json := JSON.new()
	if json.parse(txt) != OK:
		return null
	return json.data
