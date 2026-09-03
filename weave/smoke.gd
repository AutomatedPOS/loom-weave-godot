extends SceneTree


func _init() -> void:
	var loader: TreeLoader = TreeLoader.new()
	var path := OS.get_environment("LOOM_TREE")
	if path == "":
		path = ProjectSettings.globalize_path("res://").path_join("_incoming/loom")
	if not loader.load_tree(path):
		push_error(loader.error)
		quit(1)
		return
	print("SMOKE nodes=%d root=%s type=%s" % [
		loader.nodes.size(),
		str(loader.root.get("name", "")),
		str(loader.root.get("type", "")),
	])
	if loader.nodes.size() < 1:
		quit(1)
		return
	quit(0)
