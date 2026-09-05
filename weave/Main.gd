extends Control

## First screen. Black field. Where you are is the close-out.
## Canvas, monitor, gear, and loadout stay in the scene, off the
## window. Owner paused that look 2026-09-05; this loop puts the
## bible's first mark back: absence, then the one thing that is
## yours. Hands the interface Theme to every Control on the
## Interface layer. A CanvasLayer stops Theme propagation, so each
## root there gets it.

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
	_gear.visible = false
	_panel.visible = false
	_here.visible = true
	_gear.pressed.connect(_panel.toggle)
