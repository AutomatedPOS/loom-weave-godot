extends Control

## First screen. Black backdrop. Gear opens the loadout.

@onready var _gear: SettingsGear = $Interface/Gear
@onready var _panel: LoadoutPanel = $Interface/Panel


func _ready() -> void:
	_gear.pressed.connect(_panel.toggle)
