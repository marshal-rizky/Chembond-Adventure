extends Area2D

signal level_completed

@export var required_elements: Dictionary = {"H": 2, "O": 1}
var is_open: bool = false
var pulse_tween: Tween
var led_pulse_tween: Tween
var players_on_gate: int = 0
var legend_mode: bool = false  # set by main.gd when spawning in legend mode

const LED_RED       := Color(1.0, 0.27, 0.27, 1.0)
const LED_RED_GLOW  := Color(1.0, 0.27, 0.27, 0.35)
const LED_GREEN     := Color(0.30, 1.0, 0.45, 1.0)
const LED_GREEN_GLOW:= Color(0.30, 1.0, 0.45, 0.35)
const TINT_LOCKED   := Color(1.15, 0.85, 0.85, 1.0)
const TINT_OPEN     := Color(0.80, 1.20, 0.95, 1.0)

var tex_locked: Texture2D = preload("res://assets/sprites/gate_locked.png")
var tex_open: Texture2D = preload("res://assets/sprites/gate_open.png")

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	$Sprite2D.scale = Vector2(0.5, 0.5)
	_build_led_polys()
	update_visuals()
	start_pulse()

func _build_led_polys():
	var led: Polygon2D = $Led
	var glow: Polygon2D = $LedGlow
	led.polygon = _circle_points(1.6, 10)
	glow.polygon = _circle_points(3.4, 14)

func _circle_points(radius: float, segments: int) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in range(segments):
		var a := TAU * float(i) / float(segments)
		pts.append(Vector2(cos(a), sin(a)) * radius)
	return pts

func start_pulse():
	if pulse_tween: pulse_tween.kill()
	pulse_tween = create_tween().set_loops()
	pulse_tween.tween_property($Sprite2D, "modulate:v", 1.4, 0.6)
	pulse_tween.tween_property($Sprite2D, "modulate:v", 1.0, 0.6)

	if led_pulse_tween: led_pulse_tween.kill()
	led_pulse_tween = create_tween().set_loops()
	led_pulse_tween.tween_property($LedGlow, "scale", Vector2(1.4, 1.4), 0.5)
	led_pulse_tween.tween_property($LedGlow, "scale", Vector2(1.0, 1.0), 0.5)

func update_visuals():
	if is_open:
		$Sprite2D.texture = tex_open
		$Sprite2D.modulate = TINT_OPEN
		$Led.color = LED_GREEN
		$LedGlow.color = LED_GREEN_GLOW
	else:
		$Sprite2D.texture = tex_locked
		$Sprite2D.modulate = TINT_LOCKED
		$Led.color = LED_RED
		$LedGlow.color = LED_RED_GLOW

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
