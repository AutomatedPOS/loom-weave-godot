extends Control

## First screen. Black backdrop. The canvas is the read-only view;
## the monitor stays in the scene, hidden, until the owner strikes it.
## Gear opens the loadout. Hands the interface Theme to every
## Control on the Interface layer. A CanvasLayer stops Theme
## propagation, so each root there gets it.

@onready var _backdrop: ColorRect = $Backdrop
@onready var _interface: CanvasLayer = $Interface
@onready var _gear: SettingsGear = $Interface/Gear
@onready var _panel: LoadoutPanel = $Interface/Panel


func _ready() -> void:
	var theme_res := LoomTheme.shared()
	for child in _interface.get_children():
		if child is Control:
			child.theme = theme_res
	_backdrop.color = LoomTokens.BACKDROP
	_gear.pressed.connect(_panel.toggle)
