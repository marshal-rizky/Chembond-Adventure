extends Area2D

signal level_completed

@export var required_elements: Dictionary = {"H": 2, "O": 1}
var is_open: bool = false
var pulse_tween: Tween
var players_on_gate: int = 0
var legend_mode: bool = false  # set by main.gd when spawning in legend mode

var tex_locked: Texture2D = preload("res://assets/sprites/gate_locked.png")
var tex_open: Texture2D = preload("res://assets/sprites/gate_open.png")

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	update_visuals()
	start_pulse()

func start_pulse():
	if pulse_tween: pulse_tween.kill()
	pulse_tween = create_tween().set_loops()
	pulse_tween.tween_property($Sprite2D, "modulate:v", 1.5, 0.6)
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
	if not (body is CharacterBody2D): return
	if legend_mode:
		players_on_gate += 1
		if players_on_gate >= 2 and is_open:
			level_completed.emit()
	else:
		if is_open:
			level_completed.emit()

func _on_body_exited(body):
	if legend_mode and body is CharacterBody2D:
		players_on_gate = max(0, players_on_gate - 1)
