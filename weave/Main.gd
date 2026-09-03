extends Control

const BACKDROP := Color(0.102, 0.094, 0.078)
const INTERFACE := Color(0.055, 0.047, 0.039)
const INTERFACE_INK := Color(0.77, 0.71, 0.60)
const RULE := Color(0.77, 0.36, 0.15)

var loader = preload("res://weave/TreeLoader.gd").new()
var selected: Dictionary = {}

@onready var _cards: Control = $Slots
@onready var _title: Label = $Interface/Bar/Title
@onready var _just: Label = $Interface/Bar/JustDid
@onready var _next: Label = $Interface/Bar/Next
@onready var _status: Label = $Interface/Bar/Status


func _ready() -> void:
	var path := _loom_path()
	if not loader.load_tree(path):
		_title.text = "loom"
		_just.text = loader.error
		_next.text = "Set LOOM_TREE to the loom repo, or put it at trees/loom."
		_status.text = "no tree"
		return
	selected = loader.root
	_paint_interface(loader.root)
	_layout_cards()
	_status.text = "%d nodes  ·  %s" % [loader.nodes.size(), loader.tree_path]


func _loom_path() -> String:
	var env := OS.get_environment("LOOM_TREE")
	if env != "" and FileAccess.file_exists(env.path_join("thread.json")):
		return env
	var here := ProjectSettings.globalize_path("res://").trim_suffix("/")
	var guesses := PackedStringArray([
		here.path_join("_incoming/loom"),
		here.path_join("trees/loom"),
		here.path_join("../loom"),
		"/tmp/loom-repos/loom",
	])
	for g in guesses:
		if FileAccess.file_exists(g.path_join("thread.json")):
			return g
	return here.path_join("trees/loom")


func _paint_interface(n: Dictionary) -> void:
	_title.text = str(n.get("name", "loom"))
	var jd := str(n.get("justDid", "")).strip_edges()
	var nx := str(n.get("next", "")).strip_edges()
	_just.text = ("Just did. " + jd) if jd != "" else ""
	_next.text = ("Next. " + nx) if nx != "" else ""


func _layout_cards() -> void:
	for child in _cards.get_children():
		child.queue_free()

	var by_depth: Dictionary = {}
	var max_d := 0
	for node in loader.nodes:
		var d: int = loader.depth_of(node)
		max_d = max(max_d, d)
		if not by_depth.has(d):
			by_depth[d] = []
		by_depth[d].append(node)

	# Slot = -depth: root at 0, deeper nodes further back. Draw back to front.
	var vp := size
	if vp.x < 8.0:
		vp = Vector2(1440, 900)
	var top := 150.0
	var usable_h := vp.y - top - 36.0
	var row_h := usable_h / float(max_d + 1)

	for d in range(max_d, -1, -1):
		var row: Array = by_depth.get(d, [])
		var slot := -d
		var count := row.size()
		var card_h: float = clampf(row_h - 16.0, 72.0, 132.0)
		var card_w: float = clampf((vp.x * 0.92) / float(maxi(count, 1)) - 10.0, 120.0, 300.0)
		var card_size := Vector2(card_w, card_h)
		var y: float = top + float(d) * row_h + 8.0
		for i in count:
			var n: Dictionary = row[i]
			var card = preload("res://weave/ThreadCard.gd").new()
			var x: float = vp.x * 0.04 + (float(i) + 0.5) * (vp.x * 0.92 / float(maxi(count, 1)))
			card.setup(n, slot, card_size)
			card.position = Vector2(x - card_size.x * 0.5, y)
			card.z_index = slot + 32
			card.modulate = Color(1, 1, 1, 1.0 - d * 0.06)
			card.focused.connect(_on_card)
			_cards.add_child(card)


func _on_card(n: Dictionary) -> void:
	selected = n
	_paint_interface(n)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and loader.nodes.size() > 0:
		_layout_cards()
