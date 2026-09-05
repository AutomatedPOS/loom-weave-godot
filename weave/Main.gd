extends Control

## First screen. White field. The canvas is the read-only view;
## the monitor stays in the scene, hidden, until the owner strikes it.
## Gear is off the window. Hands the interface Theme to every
## Control on the Interface layer. A CanvasLayer stops Theme
## propagation, so each root there gets it.

@onready var _backdrop: ColorRect = $Backdrop
@onready var _interface: CanvasLayer = $Interface


func _ready() -> void:
	var theme_res := LoomTheme.shared()
	for child in _interface.get_children():
		if child is Control:
			child.theme = theme_res
	_backdrop.color = LoomTokens.BACKDROP
	var gear := _interface.get_node_or_null("Gear") as Control
	if gear != null:
		gear.visible = false
		gear.mouse_filter = Control.MOUSE_FILTER_IGNORE
