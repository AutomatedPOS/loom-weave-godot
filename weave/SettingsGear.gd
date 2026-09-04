class_name SettingsGear
extends Control

## Interface-track chrome. A settings cog. Opens the loadout.
signal pressed

const INK := Color(0.68, 0.68, 0.70, 1)
const INK_HOVER := Color(0.78, 0.78, 0.80, 1)
const TEETH := 8

var _hover := false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	mouse_entered.connect(_on_enter)
	mouse_exited.connect(_on_exit)


func _on_enter() -> void:
	_hover = true
	queue_redraw()


func _on_exit() -> void:
	_hover = false
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		pressed.emit()
		accept_event()


func _draw() -> void:
	var ink := INK_HOVER if _hover else INK
	var c := size * 0.5
	var r_tip := minf(size.x, size.y) * 0.48
	var r_valley := r_tip * 0.70
	var r_hole := r_tip * 0.28
	draw_colored_polygon(_gear_points(c, r_tip, r_valley), ink)
	draw_circle(c, r_hole, Color(0, 0, 0, 1))


func _gear_points(center: Vector2, r_tip: float, r_valley: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var step := TAU / float(TEETH)
	var tip_half := step * 0.16
	var valley_half := step * 0.30
	for i in TEETH:
		var a := float(i) * step - PI * 0.5
		pts.append(center + Vector2.from_angle(a - valley_half) * r_valley)
		pts.append(center + Vector2.from_angle(a - tip_half) * r_tip)
		pts.append(center + Vector2.from_angle(a + tip_half) * r_tip)
		pts.append(center + Vector2.from_angle(a + valley_half) * r_valley)
	return pts
