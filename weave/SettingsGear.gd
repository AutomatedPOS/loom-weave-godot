class_name SettingsGear
extends Button

## Interface-track chrome. A settings cog. Opens the loadout.
## Colour comes from the Theme (type "Loom"). Size comes from LoomTokens.
## The five ratios below are the cog's shape, not its style.
const TEETH := 8
const TIP_RATIO := 0.48       # tooth tip radius, of the short side
const VALLEY_RATIO := 0.70    # valley radius, of the tip radius
const HOLE_RATIO := 0.28      # hub hole radius, of the tip radius
const TOOTH_TIP_HALF := 0.16  # half-width of a tooth tip, of one step
const TOOTH_VALLEY_HALF := 0.30  # half-width at the valley, of one step

var _hover := false


func _ready() -> void:
	theme_type_variation = LoomTokens.V_GEAR
	flat = true
	focus_mode = Control.FOCUS_NONE
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_place()
	mouse_entered.connect(_on_enter)
	mouse_exited.connect(_on_exit)


## Bottom-right, one inset in from both edges.
func _place() -> void:
	var s := float(LoomTokens.GEAR_SIZE)
	var inset := float(LoomTokens.INSET)
	custom_minimum_size = Vector2(s, s)
	set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	offset_left = -(s + inset)
	offset_top = -(s + inset)
	offset_right = -inset
	offset_bottom = -inset


func _on_enter() -> void:
	_hover = true
	queue_redraw()


func _on_exit() -> void:
	_hover = false
	queue_redraw()


func _draw() -> void:
	var ink_name := &"ink_hover" if _hover else &"ink"
	var ink := get_theme_color(ink_name, LoomTokens.THEME_TYPE)
	var hub := get_theme_color(&"backdrop", LoomTokens.THEME_TYPE)
	var c := size * 0.5
	var r_tip := minf(size.x, size.y) * TIP_RATIO
	var r_valley := r_tip * VALLEY_RATIO
	var r_hole := r_tip * HOLE_RATIO
	draw_colored_polygon(_gear_points(c, r_tip, r_valley), ink)
	draw_circle(c, r_hole, hub)


func _gear_points(center: Vector2, r_tip: float, r_valley: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var step := TAU / float(TEETH)
	var tip_half := step * TOOTH_TIP_HALF
	var valley_half := step * TOOTH_VALLEY_HALF
	for i in TEETH:
		var a := float(i) * step - PI * 0.5
		pts.append(center + Vector2.from_angle(a - valley_half) * r_valley)
		pts.append(center + Vector2.from_angle(a - tip_half) * r_tip)
		pts.append(center + Vector2.from_angle(a + tip_half) * r_tip)
		pts.append(center + Vector2.from_angle(a + valley_half) * r_valley)
	return pts
