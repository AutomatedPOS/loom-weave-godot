class_name LoadoutSection
extends VBoxContainer

## One capability block on the loadout: a caption and one field per
## Loadout.FIELDS. The panel holds one of these per Loadout.CAPS.
## Field identity is the field name, never a position.

var cap: String = ""
var _edits: Dictionary = {}


func setup(p_cap: String) -> void:
	cap = p_cap
	name = cap
	add_theme_constant_override(&"separation", LoomTokens.SPACE_1)
	var caption := Label.new()
	caption.text = cap
	add_child(caption)
	for field in Loadout.FIELDS:
		var edit := LineEdit.new()
		edit.name = field
		edit.placeholder_text = field
		edit.secret = Loadout.is_secret(field)
		edit.custom_minimum_size = Vector2(0, LoomTokens.CONTROL_H)
		edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		add_child(edit)
		_edits[field] = edit


func edit(field: String) -> LineEdit:
	return _edits.get(field)


## Field values, edges trimmed.
func read() -> Dictionary:
	var block := Loadout.empty_cap()
	for field in _edits:
		block[field] = (_edits[field] as LineEdit).text.strip_edges()
	return block


func write(block: Dictionary) -> void:
	for field in _edits:
		(_edits[field] as LineEdit).text = str(block.get(field, ""))
