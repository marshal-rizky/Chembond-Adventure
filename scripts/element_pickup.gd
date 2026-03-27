extends Area2D

signal collected(element_symbol)

@export var element_symbol: String = "H"

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
	"Zn": Color.LIGHT_SLATE_GRAY
}

func _ready():
	$Label.text = element_symbol
	var color = element_colors.get(element_symbol, Color.WHITE)
	$Sprite2D.modulate = color
	
	# Bobbing animation (Visual Only - keeps collision center static)
	var tween = create_tween().set_loops()
	tween.set_parallel(true)
	tween.tween_property($Sprite2D, "position:y", -2, 0.8).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property($Label, "position:y", -14, 0.8).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.chain().tween_property($Sprite2D, "position:y", 2, 0.8).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property($Label, "position:y", -10, 0.8).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	
	# Pulse glow
	var glow_tween = create_tween().set_loops()
	glow_tween.tween_property($Sprite2D, "modulate:a", 0.5, 1.0)
	glow_tween.tween_property($Sprite2D, "modulate:a", 1.0, 1.0)

func collect():
	play_collect_effect()
	collected.emit(element_symbol)
	# Disconnect from all to be safe before queue_free
	for sig in collected.get_connections():
		collected.disconnect(sig.callable)
	queue_free()

func play_collect_effect():
	var color = element_colors.get(element_symbol, Color.WHITE)
	var scene_root = get_tree().current_scene

	# Central flash
	var flash = Sprite2D.new()
	flash.texture = $Sprite2D.texture
	flash.global_position = global_position
	flash.modulate = Color.WHITE
	flash.z_index = 10
	scene_root.add_child(flash)
	var ft = flash.create_tween()
	ft.set_parallel(true)
	ft.tween_property(flash, "scale", Vector2(3, 3), 0.3)
	ft.tween_property(flash, "modulate:a", 0.0, 0.3)
	ft.tween_callback(flash.queue_free).set_delay(0.3)

	# Particle burst - 8 colored particles flying outward
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
