# exit_gate.gd
# Script untuk pintu keluar maze — cek apakah inventory player udah pas dengan
# yang dibutuhkan, lalu buka/tutup gate dan emit signal kalau player berhasil lewat.
# Gate hanya terbuka kalau inventory PERSIS cocok — kurang atau lebih sama aja dikunci.
extends Area2D

signal level_completed

# Element yang harus dikumpulkan buat buka gate ini
@export var required_elements: Dictionary = {"H": 2, "O": 1}
var is_open: bool = false

# Tween buat efek pulse pada sprite dan LED glow
var pulse_tween: Tween
var led_pulse_tween: Tween

# Counter berapa player yang lagi di atas gate — penting buat mode legend (butuh 2 player)
var players_on_gate: int = 0
var legend_mode: bool = false  # set by main.gd when spawning in legend mode

# Konstanta warna LED — merah kalau terkunci, hijau kalau terbuka
const LED_RED       := Color(1.0, 0.27, 0.27, 1.0)
const LED_RED_GLOW  := Color(1.0, 0.27, 0.27, 0.35)
const LED_GREEN     := Color(0.30, 1.0, 0.45, 1.0)
const LED_GREEN_GLOW:= Color(0.30, 1.0, 0.45, 0.35)
const TINT_LOCKED   := Color(1.15, 0.85, 0.85, 1.0)
const TINT_OPEN     := Color(0.80, 1.20, 0.95, 1.0)

# Load sprite locked/open saat compile time
var tex_locked: Texture2D = preload("res://assets/sprites/gate_locked.png")
var tex_open: Texture2D = preload("res://assets/sprites/gate_open.png")

func _ready():
	# Sambungin signal body enter/exit untuk deteksi player yang lewat
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	$Sprite2D.scale = Vector2(0.5, 0.5)
	# Bangun polygon untuk LED indicator
	_build_led_polys()
	# Set tampilan awal sesuai state is_open
	update_visuals()
	# Mulai efek pulse dari awal
	start_pulse()

func _build_led_polys():
	# Bikin shape lingkaran untuk LED dan glow polygon
	var led: Polygon2D = $Led
	var glow: Polygon2D = $LedGlow
	led.polygon = _circle_points(1.6, 10)
	glow.polygon = _circle_points(3.4, 14)

func _circle_points(radius: float, segments: int) -> PackedVector2Array:
	# Helper: generate titik-titik lingkaran dengan jumlah segment tertentu
	var pts := PackedVector2Array()
	for i in range(segments):
		var a := TAU * float(i) / float(segments)
		pts.append(Vector2(cos(a), sin(a)) * radius)
	return pts

func start_pulse():
	# Mulai animasi pulse pada sprite (brightness) dan LED glow (scale)
	if pulse_tween: pulse_tween.kill()
	pulse_tween = create_tween().set_loops()
	pulse_tween.tween_property($Sprite2D, "modulate:v", 1.4, 0.6)
	pulse_tween.tween_property($Sprite2D, "modulate:v", 1.0, 0.6)

	if led_pulse_tween: led_pulse_tween.kill()
	led_pulse_tween = create_tween().set_loops()
	led_pulse_tween.tween_property($LedGlow, "scale", Vector2(1.4, 1.4), 0.5)
	led_pulse_tween.tween_property($LedGlow, "scale", Vector2(1.0, 1.0), 0.5)

func update_visuals():
	# Update texture, tint, dan warna LED sesuai state is_open
	if is_open:
		# Gate terbuka — hijau dan lebih terang
		$Sprite2D.texture = tex_open
		$Sprite2D.modulate = TINT_OPEN
		$Led.color = LED_GREEN
		$LedGlow.color = LED_GREEN_GLOW
	else:
		# Gate terkunci — merah dengan tint kemerahan
		$Sprite2D.texture = tex_locked
		$Sprite2D.modulate = TINT_LOCKED
		$Led.color = LED_RED
		$LedGlow.color = LED_RED_GLOW

func check_requirements(inventory: Dictionary):
	# Cek apakah inventory player PERSIS cocok dengan required_elements
	# — kalau kurang ATAU lebih, gate tetap terkunci
	var all_met = true
	for element in required_elements:
		if inventory.get(element, 0) != required_elements[element]:
			all_met = false
			break

	# Cek juga dari sisi lain: kalau ada element di inventory yang gak dibutuhkan atau beda jumlah
	if all_met:
		for element in inventory:
			var count = inventory[element]
			if count == 0: continue
			if not required_elements.has(element) or count != required_elements[element]:
				all_met = false
				break

	# Update state dan visual sesuai hasil pengecekan
	if all_met:
		if not is_open:
			is_open = true
			update_visuals()
			AudioManager.play_sfx("gate_unlock")
	else:
		# Kalau sebelumnya terbuka tapi sekarang gak cocok lagi — kunci balik
		if is_open:
			is_open = false
			update_visuals()

func _on_body_entered(body):
	# Player menyentuh gate — kalau terbuka, emit level_completed
	if not (body is CharacterBody2D): return
	if legend_mode:
		# Mode legend: butuh KEDUA player masuk ke gate sebelum level selesai
		players_on_gate += 1
		if players_on_gate >= 2 and is_open:
			level_completed.emit()
	else:
		# Mode normal: cukup satu player, langsung selesai kalau gate terbuka
		if is_open:
			level_completed.emit()

func _on_body_exited(body):
	# Player keluar dari area gate — kurangi counter (penting buat mode legend)
	if legend_mode and body is CharacterBody2D:
		players_on_gate = max(0, players_on_gate - 1)
