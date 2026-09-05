extends Control

## First screen. Black field. Where you are is the close-out.
## Canvas and monitor stay in the scene, off the window. The gear
## is on: it opens the loadout so a credential can be pasted.
## Owner paused the painted canvas 2026-09-05; rails stay off.

@onready var _backdrop: ColorRect = $Backdrop
@onready var _interface: CanvasLayer = $Interface
@onready var _canvas: Control = $Interface/Canvas
@onready var _here: Control = $Interface/Here
@onready var _monitor: Control = $Interface/Monitor
@onready var _gear: SettingsGear = $Interface/Gear
@onready var _panel: LoadoutPanel = $Interface/Panel


func _ready() -> void:
	var theme_res := LoomTheme.shared()
	for child in _interface.get_children():
		if child is Control:
			child.theme = theme_res
	_backdrop.color = LoomTokens.BACKDROP
	_canvas.visible = false
	_monitor.visible = false
	_gear.visible = true
	_panel.visible = false
	_here.visible = true
	_gear.pressed.connect(_panel.toggle)
