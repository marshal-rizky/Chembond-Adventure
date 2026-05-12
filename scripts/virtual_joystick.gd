# virtual_joystick.gd
# Script untuk virtual joystick di layar sentuh — deteksi touch dan drag,
# terus emit vector arah yang bisa dipakai player buat gerak.
# Cocok buat main di HP atau tablet.
extends Control

# virtual_joystick.gd

# Signal yang di-emit tiap frame saat joystick bergerak — diterima oleh player.gd
signal joystick_vector(vector: Vector2)

# Referensi ke node base dan handle joystick
@onready var base = $Base
@onready var handle = $Base/Handle

# Radius maksimal yang bisa dijangkau handle dari center
var max_distance: float = 50.0

# State tracking — apakah lagi ada yang nge-drag, dan index jarinya
var dragging: bool = false
var finger_index: int = -1

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			# Touch baru — cek apakah jarinya kena area joystick (dua kali radius buat toleransi)
			var dist = event.position.distance_to(base.global_position)
			if dist < max_distance * 2.0: # Catch touch near the base
				dragging = true
				finger_index = event.index
		elif event.index == finger_index:
			# Jari diangkat — reset joystick ke tengah dan emit zero vector
			dragging = false
			finger_index = -1
			handle.position = Vector2.ZERO
			joystick_vector.emit(Vector2.ZERO)

	if event is InputEventScreenDrag and dragging and event.index == finger_index:
		# Jari lagi di-drag — hitung delta dari center joystick
		var center = base.global_position
		var delta = event.position - center
		# Batasi jarak handle supaya gak keluar dari lingkaran base
		delta = delta.limit_length(max_distance)
		handle.position = delta

		# Normalize and emit — kirim vector arah yang udah dinormalisasi (-1 sampai 1)
		var output = delta / max_distance
		joystick_vector.emit(output)
