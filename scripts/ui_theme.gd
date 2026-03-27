extends Node
class_name UITheme

static func create_game_theme() -> Theme:
	var theme = Theme.new()

	# Button styling - dark blue with cyan border
	var btn_normal = StyleBoxFlat.new()
	btn_normal.bg_color = Color("#1a1a3e")
	btn_normal.border_color = Color("#00cccc")
	btn_normal.set_border_width_all(2)
	btn_normal.set_corner_radius_all(4)
	btn_normal.set_content_margin_all(8)

	var btn_hover = StyleBoxFlat.new()
	btn_hover.bg_color = Color("#252560")
	btn_hover.border_color = Color("#00ffff")
	btn_hover.set_border_width_all(2)
	btn_hover.set_corner_radius_all(4)
	btn_hover.set_content_margin_all(8)

	var btn_pressed = StyleBoxFlat.new()
	btn_pressed.bg_color = Color("#0d0d2b")
	btn_pressed.border_color = Color("#00ffff")
	btn_pressed.set_border_width_all(3)
	btn_pressed.set_corner_radius_all(4)
	btn_pressed.set_content_margin_all(8)

	theme.set_stylebox("normal", "Button", btn_normal)
	theme.set_stylebox("hover", "Button", btn_hover)
	theme.set_stylebox("pressed", "Button", btn_pressed)
	theme.set_color("font_color", "Button", Color("#ccddff"))
	theme.set_color("font_hover_color", "Button", Color("#00ffff"))
	theme.set_color("font_pressed_color", "Button", Color.WHITE)

	# Panel styling - semi-transparent dark blue
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.06, 0.06, 0.14, 0.85)
	panel_style.border_color = Color("#0088aa")
	panel_style.set_border_width_all(1)
	panel_style.set_corner_radius_all(6)
	panel_style.set_content_margin_all(12)
	theme.set_stylebox("panel", "Panel", panel_style)

	# Label defaults
	theme.set_color("font_color", "Label", Color("#ccddff"))
	theme.set_font_size("font_size", "Label", 16)

	return theme
