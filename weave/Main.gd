extends Control

## First screen. Black backdrop. Gear opens the loadout. Talk waits on green.

@onready var _gear: SettingsGear = $Interface/Gear
@onready var _panel: LoadoutPanel = $Interface/Panel

var _talk: TalkClient
var _chat: ChatPanel


func _ready() -> void:
	ThemeEngine.boot_current()
	_talk = TalkClient.new()
	_talk.name = "Talk"
	add_child(_talk)
	_chat = ChatPanel.new()
	_chat.name = "Chat"
	$Interface.add_child(_chat)
	_gear.bind_theme(ThemeEngine.current)
	_panel.bind(ThemeEngine.current, _talk)
	_chat.bind(ThemeEngine.current, _talk)
	_gear.pressed.connect(_panel.toggle)
	_panel.caps_changed.connect(_on_caps)
	_panel.minimized.connect(_on_panel_min)
	_chat.minimized.connect(_on_chat_min)


func _on_caps(all_green: bool) -> void:
	if all_green and not _panel.visible:
		_chat.show_talk()
	elif not all_green:
		_chat.hide_talk()


func _on_panel_min() -> void:
	if _panel.all_green():
		_chat.show_talk()


func _on_chat_min() -> void:
	pass
