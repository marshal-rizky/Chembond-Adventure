extends Area2D

signal level_completed

@export var required_elements: Dictionary = {"H": 2, "O": 1} # Default H2O
var is_open: bool = false
var pulse_tween: Tween

var tex_locked: Texture2D = preload("res://assets/sprites/gate_locked.png")
var tex_open: Texture2D = preload("res://assets/sprites/gate_open.png")

func _ready():
	body_entered.connect(_on_body_entered)
	update_visuals()
	start_pulse()

func start_pulse():
	if pulse_tween: pulse_tween.kill()
	pulse_tween = create_tween().set_loops()
	pulse_tween.tween_property($Sprite2D, "modulate:v", 1.5, 0.6) # Increase brightness
	pulse_tween.tween_property($Sprite2D, "modulate:v", 1.0, 0.6)

func update_visuals():
	if is_open:
		$Sprite2D.texture = tex_open
		$Sprite2D.modulate = Color.WHITE
		$Label.text = "OPEN"
		$Label.add_theme_color_override("font_color", Color.GREEN)
	else:
		$Sprite2D.texture = tex_locked
		$Sprite2D.modulate = Color.WHITE
		$Label.text = "LOCKED"
		$Label.add_theme_color_override("font_color", Color.DARK_RED)

func check_requirements(inventory: Dictionary):
	var all_met = true
	for element in required_elements:
		if inventory.get(element, 0) != required_elements[element]:
			all_met = false
			break
	
	if all_met:
		for element in inventory:
			var count = inventory[element]
			if count == 0: continue
			if not required_elements.has(element) or count != required_elements[element]:
				all_met = false
				break
	
	if all_met:
		if not is_open:
			is_open = true
			update_visuals()
			AudioManager.play_sfx("gate_unlock")
	else:
		if is_open:
			is_open = false
			update_visuals()

func _on_body_entered(body):
	if is_open and body is CharacterBody2D:
		level_completed.emit()
