# ui_theme.gd
# Kumpulan konstanta warna dan fungsi buat bikin tema UI game secara terpusat.
# Semua warna mengikuti palet "industrial lab terminal" — nuansa gelap dengan aksen teal.
# Dipanggil sebagai UITheme.create_game_theme() dari mana saja.
extends Node
class_name UITheme

# Industrial lab terminal palette — palet warna utama game
const BG_DEEP    := Color("#070b14")  # Background paling gelap
const BG_PANEL   := Color("#0d1626")  # Background panel/card
const BG_HOVER   := Color("#152238")  # Background saat hover
const BG_PRESSED := Color("#1d3554")  # Background saat tombol ditekan
const BORDER     := Color("#14b8a6")  # Border utama — teal
const BORDER_HI  := Color("#5eead4")  # Border highlight — teal terang
const BORDER_DIM := Color("#0c5b54")  # Border redup — buat tombol disabled
const TEXT       := Color("#cfeae6")  # Teks normal
const TEXT_HI    := Color("#5eead4")  # Teks highlight — objective label
const TEXT_DIM   := Color("#6b7a85")  # Teks redup — hint/label sekunder
const ACCENT_RED := Color("#ef4444")  # Aksen merah — buat warning/error

static func _make_stylebox(bg: Color, border: Color, border_w: int = 1) -> StyleBoxFlat:
	# Helper buat bikin StyleBoxFlat dengan warna dan border yang konsisten
	var sb = StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(border_w)
	sb.set_corner_radius_all(0)  # Sharp corner — sesuai estetik pixel art
	sb.set_content_margin_all(8)
	return sb

static func create_game_theme() -> Theme:
	# Bikin dan return Theme lengkap yang langsung bisa di-assign ke node UI
	var theme = Theme.new()

	# Load font pixel art — kalau file ada, pakai sebagai default font
	var font_reg  = load("res://assets/fonts/PixelifySans-Regular.ttf") as FontFile
	if font_reg:
		theme.set_default_font(font_reg)
		theme.set_default_font_size(16)

	# Bikin 4 varian stylebox untuk tombol: normal, hover, pressed, disabled
	var btn_normal   = _make_stylebox(BG_PANEL,   BORDER,    1)
	var btn_hover    = _make_stylebox(BG_HOVER,   BORDER_HI, 2)
	var btn_pressed  = _make_stylebox(BG_PRESSED, BORDER_HI, 2)
	var btn_disabled = _make_stylebox(BG_DEEP,    BORDER_DIM, 1)

	# Terapkan semua stylebox ke tema Button
	theme.set_stylebox("normal",   "Button", btn_normal)
	theme.set_stylebox("hover",    "Button", btn_hover)
	theme.set_stylebox("pressed",  "Button", btn_pressed)
	theme.set_stylebox("disabled", "Button", btn_disabled)
	theme.set_stylebox("focus",    "Button", _make_stylebox(BG_HOVER, BORDER_HI, 2))

	# Warna teks tombol di berbagai state
	theme.set_color("font_color",          "Button", TEXT)
	theme.set_color("font_hover_color",    "Button", TEXT_HI)
	theme.set_color("font_pressed_color",  "Button", Color.WHITE)
	theme.set_color("font_disabled_color", "Button", TEXT_DIM)
	theme.set_constant("h_separation", "Button", 4)

	# Style untuk Panel — background gelap transparan dengan border teal
	var panel_style = _make_stylebox(Color(0.027, 0.043, 0.075, 0.92), BORDER, 1)
	panel_style.set_content_margin_all(10)
	theme.set_stylebox("panel", "Panel", panel_style)

	# Warna dan ukuran font default untuk Label
	theme.set_color("font_color", "Label", TEXT)
	theme.set_font_size("font_size", "Label", 16)

	return theme
