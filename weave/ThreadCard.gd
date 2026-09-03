class_name ThreadCard
extends Control

signal focused(node: Dictionary)

var node: Dictionary = {}
var slot: int = 0

const INK := Color(0.11, 0.09, 0.06)
const MUTED := Color(0.42, 0.31, 0.22)
const PAPER := Color(0.91, 0.86, 0.78)
const RULE := Color(0.77, 0.36, 0.15)


func setup(n: Dictionary, p_slot: int, size: Vector2) -> void:
	node = n
	slot = p_slot
	custom_minimum_size = size
	self.size = size
	mouse_filter = Control.MOUSE_FILTER_STOP
	gui_input.connect(_on_input)

	var bg := ColorRect.new()
	bg.color = PAPER
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var edge := ColorRect.new()
	edge.color = RULE
	edge.position = Vector2(0, 0)
	edge.size = Vector2(6, size.y)
	edge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(edge)

	var pad := 14.0
	var type_l := Label.new()
	type_l.text = str(n.get("type", "")).to_upper()
	type_l.position = Vector2(pad + 4, 10)
	type_l.size = Vector2(size.x - pad * 2, 18)
	type_l.add_theme_font_size_override("font_size", 11)
	type_l.add_theme_color_override("font_color", MUTED)
	add_child(type_l)

	var name_l := Label.new()
	name_l.text = str(n.get("name", ""))
	name_l.position = Vector2(pad + 4, 28)
	name_l.size = Vector2(size.x - pad * 2, 44)
	name_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_l.add_theme_font_size_override("font_size", 18)
	name_l.add_theme_color_override("font_color", INK)
	add_child(name_l)

	var state := str(n.get("state", ""))
	if state != "":
		var st := Label.new()
		st.text = state
		st.position = Vector2(pad + 4, size.y - 28)
		st.size = Vector2(size.x - pad * 2, 18)
		st.add_theme_font_size_override("font_size", 12)
		st.add_theme_color_override("font_color", RULE)
		add_child(st)


func _on_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		focused.emit(node)
