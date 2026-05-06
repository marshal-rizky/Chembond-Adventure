extends Node
class_name UITheme

# Industrial lab terminal palette
const BG_DEEP    := Color("#070b14")
const BG_PANEL   := Color("#0d1626")
const BG_HOVER   := Color("#152238")
const BG_PRESSED := Color("#1d3554")
const BORDER     := Color("#14b8a6")
const BORDER_HI  := Color("#5eead4")
const BORDER_DIM := Color("#0c5b54")
const TEXT       := Color("#cfeae6")
const TEXT_HI    := Color("#5eead4")
const TEXT_DIM   := Color("#6b7a85")
const ACCENT_RED := Color("#ef4444")

static func _make_stylebox(bg: Color, border: Color, border_w: int = 1) -> StyleBoxFlat:
	var sb = StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(border_w)
	sb.set_corner_radius_all(0)
	sb.set_content_margin_all(8)
	return sb

static func create_game_theme() -> Theme:
	var theme = Theme.new()

	var font_reg  = load("res://assets/fonts/PixelifySans-Regular.ttf") as FontFile
	if font_reg:
		theme.set_default_font(font_reg)
		theme.set_default_font_size(16)

	var btn_normal   = _make_stylebox(BG_PANEL,   BORDER,    1)
	var btn_hover    = _make_stylebox(BG_HOVER,   BORDER_HI, 2)
	var btn_pressed  = _make_stylebox(BG_PRESSED, BORDER_HI, 2)
	var btn_disabled = _make_stylebox(BG_DEEP,    BORDER_DIM, 1)

	theme.set_stylebox("normal",   "Button", btn_normal)
	theme.set_stylebox("hover",    "Button", btn_hover)
	theme.set_stylebox("pressed",  "Button", btn_pressed)
	theme.set_stylebox("disabled", "Button", btn_disabled)
	theme.set_stylebox("focus",    "Button", _make_stylebox(BG_HOVER, BORDER_HI, 2))
	theme.set_color("font_color",          "Button", TEXT)
	theme.set_color("font_hover_color",    "Button", TEXT_HI)
	theme.set_color("font_pressed_color",  "Button", Color.WHITE)
	theme.set_color("font_disabled_color", "Button", TEXT_DIM)
	theme.set_constant("h_separation", "Button", 4)

	var panel_style = _make_stylebox(Color(0.027, 0.043, 0.075, 0.92), BORDER, 1)
	panel_style.set_content_margin_all(10)
	theme.set_stylebox("panel", "Panel", panel_style)

	theme.set_color("font_color", "Label", TEXT)
	theme.set_font_size("font_size", "Label", 16)

	return theme
