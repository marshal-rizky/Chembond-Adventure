extends Area2D

signal collected(element_symbol)

@export var element_symbol: String = "H"

var _tutorial_tween: Tween = null

var element_colors = {
	"H": Color.CYAN,
	"O": Color.RED,
	"C": Color.GRAY,
	"Na": Color.YELLOW,
	"Cl": Color.GREEN,
	"N": Color.BLUE,
	"Mg": Color.ORANGE,
	"Ca": Color.ORANGE_RED,
	"Si": Color.SADDLE_BROWN,
	"S": Color.YELLOW_GREEN,
	"K": Color.MEDIUM_PURPLE,
	"Fe": Color.DARK_GRAY,
	"Cu": Color.CORAL,
	"Zn": Color.LIGHT_SLATE_GRAY,
	"P": Color.LIME_GREEN,
	"Al": Color.SILVER
}

func _ready():
	var bob_tween = create_tween().set_loops()
	bob_tween.tween_property(self, "position:y", position.y - 2, 0.8).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	bob_tween.tween_property(self, "position:y", position.y + 2, 0.8).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

	var glow_tween = create_tween().set_loops()
	glow_tween.tween_property(self, "modulate:a", 0.5, 1.0)
	glow_tween.tween_property(self, "modulate:a", 1.0, 1.0)

	queue_redraw()

func _draw():
	var color = element_colors.get(element_symbol, Color.WHITE)

	# Pixel-art flat-top hexagon at radius 7
	var pts := PackedVector2Array()
	for i in 6:
		var a := deg_to_rad(60.0 * i - 30.0)
		pts.append(Vector2(cos(a), sin(a)) * 7.0)

	# Fill
	var fill_color = color
	fill_color.a = 0.18
	draw_colored_polygon(pts, fill_color)

	# Stroke — close the loop
	var stroke_pts = pts + PackedVector2Array([pts[0]])
	draw_polyline(stroke_pts, color, 1.5, false)

	# Symbol centered
	var font = ThemeDB.fallback_font
	var font_size = 8
	var text_size = font.get_string_size(element_symbol, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	var text_pos = Vector2(-text_size.x / 2.0, text_size.y / 2.0 - 2.0)
	draw_string(font, text_pos, element_symbol, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)

func collect():
	play_collect_effect()
	collected.emit(element_symbol)
	queue_free()

func play_collect_effect():
	var color = element_colors.get(element_symbol, Color.WHITE)
	var scene_root = get_tree().current_scene

	var dot = ColorRect.new()
	dot.size = Vector2(14, 14)
	dot.color = color
	dot.global_position = global_position - Vector2(7, 7)
	dot.z_index = 10
	scene_root.add_child(dot)
	var ft = dot.create_tween()
	ft.set_parallel(true)
	ft.tween_property(dot, "scale", Vector2(3, 3), 0.3)
	ft.tween_property(dot, "modulate:a", 0.0, 0.3)
	ft.tween_callback(dot.queue_free).set_delay(0.3)

	for i in range(8):
		var particle = ColorRect.new()
		particle.size = Vector2(4, 4)
		particle.color = color
		particle.global_position = global_position - Vector2(2, 2)
		particle.z_index = 9
		scene_root.add_child(particle)
		var angle = i * TAU / 8.0
		var dist = randf_range(15, 30)
		var target = global_position + Vector2(cos(angle) * dist, sin(angle) * dist)
		var pt = particle.create_tween()
		pt.set_parallel(true)
		pt.tween_property(particle, "global_position", target, 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		pt.tween_property(particle, "modulate:a", 0.0, 0.4)
		pt.tween_property(particle, "scale", Vector2(0.2, 0.2), 0.4)
		pt.tween_callback(particle.queue_free).set_delay(0.4)

func set_tutorial_highlight(is_required: bool):
	if _tutorial_tween:
		_tutorial_tween.kill()
		_tutorial_tween = null
	if is_required:
		modulate.a = 1.0
		scale = Vector2(1.0, 1.0)
		_tutorial_tween = create_tween().set_loops()
		_tutorial_tween.tween_property(self, "scale", Vector2(1.18, 1.18), 0.5).set_ease(Tween.EASE_IN_OUT)
		_tutorial_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.5).set_ease(Tween.EASE_IN_OUT)
	else:
		modulate.a = 0.4

func clear_tutorial_highlight():
	if _tutorial_tween:
		_tutorial_tween.kill()
		_tutorial_tween = null
	modulate.a = 1.0
	scale = Vector2(1.0, 1.0)
