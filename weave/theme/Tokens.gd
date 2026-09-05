class_name LoomTokens
extends RefCounted

## Design tokens for the interface track. The one place a value lives.
## LoomTheme reads these to build the Theme. Scripts read them for layout.
## Nothing else in weave/ may spell out a colour, a size, or a font size.

# --- colour, two modes. artifacts/glyph-look/tokens.json is the source. -----
const MODE_DARK := &"dark"
const MODE_LIGHT := &"light"
## First screen while the painted canvas is paused. A blank sheet.
## Not the light-mode field; that is BACKDROP after apply_mode(MODE_LIGHT).
const BLANK := Color(1, 1, 1, 1)

const PALETTE := {
	MODE_DARK: {
		&"backdrop": Color("#000000"),
		&"ink": Color("#ADADB3"),
		&"ink_hover": Color("#C7C7CC"),
		&"dim": Color("#6B6B70"),
		&"surface": Color("#0A0A0B"),
		&"well": Color("#1A1A1C"),
		&"edge": Color("#38383D"),
		&"ghost": Color(107.0 / 255.0, 107.0 / 255.0, 112.0 / 255.0, 0.45),
		&"hazard": Color("#8B1E1E"),
		&"task": Color("#D99A1F"),
		&"changed": Color("#6B8FAE"),
	},
	MODE_LIGHT: {
		&"backdrop": Color("#FFFFFF"),
		&"ink": Color("#4A4A50"),
		&"ink_hover": Color("#303036"),
		&"dim": Color("#8E8E94"),
		&"surface": Color("#F7F7F8"),
		&"well": Color("#EDEDEF"),
		&"edge": Color("#D2D2D6"),
		&"ghost": Color(142.0 / 255.0, 142.0 / 255.0, 148.0 / 255.0, 0.45),
		&"hazard": Color("#8B1E1E"),
		&"task": Color("#A06E10"),
		&"changed": Color("#4F7291"),
	},
}

static var mode: StringName = MODE_DARK
static var BACKDROP: Color = Color("#000000")
static var INK: Color = Color("#ADADB3")
static var INK_HOVER: Color = Color("#C7C7CC")
static var DIM: Color = Color("#6B6B70")
static var SURFACE: Color = Color("#0A0A0B")
static var WELL: Color = Color("#1A1A1C")
static var EDGE: Color = Color("#38383D")
static var GHOST: Color = Color(107.0 / 255.0, 107.0 / 255.0, 112.0 / 255.0, 0.45)
## Accent 1 hazard, 2 current task, 3 changed-since. Ranked, not additive.
static var HAZARD: Color = Color("#8B1E1E")
static var TASK: Color = Color("#D99A1F")
static var CHANGED: Color = Color("#6B8FAE")

## Names under which the colours are published on the Theme, type "Loom".
## Any Control can read them with get_theme_color(name, THEME_TYPE).
const THEME_TYPE := &"Loom"
static var COLORS: Dictionary = {}

## Precedence when more than one accent wants the same mark. Where you
## are beats what is wrong beats what moved. The top ACCENT_SHOW draw.
const ACCENT_RANK: Array[StringName] = [&"task", &"hazard", &"changed"]
const ACCENT_SHOW := 2

## No ink. Skins use this for hollow fill so weave/Glyphs never spells a colour.
const CLEAR := Color(0, 0, 0, 0)

static func _static_init() -> void:
	_load_palette(MODE_DARK)


## Pick dark or light. Rebuilds the live colour vars and drops the Theme
## cache so the next shared() is this palette. Default is dark.
static func apply_mode(which: StringName) -> void:
	_load_palette(which)
	LoomTheme.reset()


static func _load_palette(which: StringName) -> void:
	mode = which if PALETTE.has(which) else MODE_DARK
	var pal: Dictionary = PALETTE[mode]
	BACKDROP = pal[&"backdrop"]
	INK = pal[&"ink"]
	INK_HOVER = pal[&"ink_hover"]
	DIM = pal[&"dim"]
	SURFACE = pal[&"surface"]
	WELL = pal[&"well"]
	EDGE = pal[&"edge"]
	GHOST = pal[&"ghost"]
	HAZARD = pal[&"hazard"]
	TASK = pal[&"task"]
	CHANGED = pal[&"changed"]
	COLORS = {
		&"backdrop": BACKDROP,
		&"blank": BLANK,
		&"ink": INK,
		&"ink_hover": INK_HOVER,
		&"dim": DIM,
		&"surface": SURFACE,
		&"well": WELL,
		&"edge": EDGE,
		&"hazard": HAZARD,
		&"task": TASK,
		&"changed": CHANGED,
		&"ghost": GHOST,
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
const BUTTON_MIN_W := 72
const GEAR_SIZE := 32
const INSET := 16
const PANEL_W := 384
const PANEL_H_MAX := 760

# --- monitor: a transit map of the tree ------------------------------------
const LINE_W := 3          # actual path, spine
const GHOST_W := 2         # planned path, parked edges
const EDGE_W := 1          # tree edges that carry no path
const STATION_R := 6       # node circle
const GLYPH_NATIVE := 64   # one noun tile, as drawn in artifacts/glyph-look
const GLYPH_STROKE := 2    # stroke at native size
const GLYPH_CHIP := 24     # rail chip, as the sheet; stroke snaps to 1 px
const GLYPH_SOCKET := 48   # seat socket, a touch target, the frame is the hit
const GLYPH_TILE := 64     # alias of native, for the sheet
const INTERCHANGE_R := 10  # fork ring, seat ring
const DASH := 8            # dash length; gap equal
const SPINE_H := 80        # the spine's band under the top edge
const SPINE_STEP := 256    # one spine station to the next
const ROW_H := 160         # one depth of the tree
const COL_W := 96          # one sibling across
const BUS_UP := 24         # the horizontal run sits this far above its child row
const SIGN_ANGLE := 30     # degrees a sign turns when the row is tighter than the sign
const PLACARD_W := 488     # the focused node's placard, bottom left

# --- canvas: rails, field, ports, seat, timeline ------------------------------
const TEXT_XL := 24        # the close-out lines on the seat, the clock
const TOUCH_H := 48        # a tablet target: a rail chip, a port
const RAIL_W := 144        # the rails on the left and the ports on the right
const FIELD_TOP := 64      # the field starts here; the clock sits above it
const FRAME_STEP := 32     # one slot further in is one frame inset
const SEAT_W := 736        # the seat window, slot 0
const SEAT_H := 392
const SEAT_GUTTER := 72    # the seat's own rails and ports, one gutter each side
const SEAT_HEAD := 104     # the title row; the close-out starts under it
const CLOSEOUT_STEP := 96  # one close-out block to the next, two lines deep
const SOCKET_STEP := 40    # one socket to the next on the seat's edge
const CHIP_W := 120        # a docked chip
const CHIP_H := 32
const TILE_W := 128        # a closed window behind the seat
const TILE_H := 40
const TILE_MORE_W := 56    # the overflow tile
const TIMELINE_H := 56     # the band along the bottom
const TIMELINE_DAYS := 4   # days on the scale until zoom lands
const HANDLE_W := 12       # the selected period's handles

# --- Theme type variations. Set control.theme_type_variation to one. -------
const V_TITLE := &"TitleLabel"
const V_MUTED := &"MutedLabel"
const V_GEAR := &"GearButton"


## Where the loadout panel's bottom edge sits: above the gear, one gap up.
static func panel_bottom_inset() -> int:
	return INSET + GEAR_SIZE + SPACE_3
