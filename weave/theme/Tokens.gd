class_name LoomTokens
extends RefCounted

## Design tokens for the interface track. The one place a value lives.
## LoomTheme reads these to build the Theme. Scripts read them for layout.
## Nothing else in weave/ may spell out a colour, a size, or a font size.

# --- colour, semantic -------------------------------------------------------
const BACKDROP := Color(0, 0, 0, 1)
const INK := Color(0.68, 0.68, 0.70, 1)
const INK_HOVER := Color(0.78, 0.78, 0.80, 1)
const DIM := Color(0.42, 0.42, 0.44, 1)
const SURFACE := Color(0.04, 0.04, 0.045, 0.96)
const WELL := Color(0.10, 0.10, 0.11, 1)
const EDGE := Color(0.22, 0.22, 0.24, 1)

## Names under which the colours are published on the Theme, type "Loom".
## Any Control can read them with get_theme_color(name, THEME_TYPE).
const THEME_TYPE := &"Loom"
const COLORS := {
	&"backdrop": BACKDROP,
	&"ink": INK,
	&"ink_hover": INK_HOVER,
	&"dim": DIM,
	&"surface": SURFACE,
	&"well": WELL,
	&"edge": EDGE,
}

# --- spacing scale, px at design size ---------------------------------------
const SPACE_1 := 4
const SPACE_2 := 8
const SPACE_3 := 12
const SPACE_4 := 16
const SPACE_5 := 24

# --- type scale. Godot default font. No family is named. -------------------
const TEXT_SM := 12
const TEXT_MD := 14
const TEXT_LG := 18

# --- sizes -------------------------------------------------------------------
const BORDER := 1
const RADIUS := 0
const CONTROL_H := 36
const BUTTON_MIN_W := 88
const GEAR_SIZE := 32
const INSET := 16
const PANEL_W := 384
const PANEL_H_MAX := 760

# --- Theme type variations. Set control.theme_type_variation to one. -------
const V_TITLE := &"TitleLabel"
const V_MUTED := &"MutedLabel"
const V_GEAR := &"GearButton"
const V_ROW := &"TreeRowButton"
const V_ROW_DIM := &"TreeRowDimButton"


## Where the loadout panel's bottom edge sits: above the gear, one gap up.
static func panel_bottom_inset() -> int:
	return INSET + GEAR_SIZE + SPACE_3
