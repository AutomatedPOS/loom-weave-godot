class_name LoomTokens
extends RefCounted

## Design tokens for the interface track. The one place a value lives.
## LoomTheme reads these to build the Theme. Scripts read them for layout.
## Nothing else in weave/ may spell out a colour, a size, or a font size.

# --- colour, semantic -------------------------------------------------------
const BACKDROP := Color(1, 1, 1, 1)
const INK := Color(0.68, 0.68, 0.70, 1)
const INK_HOVER := Color(0.78, 0.78, 0.80, 1)
const DIM := Color(0.42, 0.42, 0.44, 1)
const SURFACE := Color(0.04, 0.04, 0.045, 0.96)
const WELL := Color(0.10, 0.10, 0.11, 1)
const EDGE := Color(0.22, 0.22, 0.24, 1)
## The one colour that is not gray: the actual path and the seat.
const ACCENT := Color(0.93, 0.45, 0.13, 1)
## DIM at less than half alpha. The planned path and parked stations.
const GHOST := Color(0.42, 0.42, 0.44, 0.45)

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
	&"accent": ACCENT,
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
const GLYPH_TILE := 64     # bible 4.3 inner-skin tile
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
