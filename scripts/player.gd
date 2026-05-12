# player.gd
# Script yang ngatur semua behavior player — gerak, collect element,
# animasi, efek trail, dan integrasi joystick virtual buat touch device.
extends CharacterBody2D

# Kecepatan gerak player dalam pixel per detik
@export var speed: float = 360.0

# Inventory element yang udah dikumpulkan — format {simbol: jumlah}
var collected_elements: Dictionary = {}
signal collected_signal(symbol)

# Daftar element yang lagi dekat dengan player (masuk PickupZone)
var nearby_elements: Array = []
const COLLECTION_THRESHOLD: float = 10.0 # More generous feel (Tile is 16px)

# Timer buat control seberapa sering trail di-spawn
var trail_timer: float = 0.0
const TRAIL_INTERVAL: float = 0.05

# Input dari touch/joystick dan posisi frame sebelumnya buat swept collision check
var touch_vector: Vector2 = Vector2.ZERO
var prev_position: Vector2 = Vector2.ZERO

var input_dir: Vector2 = Vector2.ZERO   # exposed for mirror mechanic
# Flag buat mode legend — player kanan mirror input dari player kiri
var mirror_input: bool = false
var mirror_source: Node = null

# Flag running aktif saat player melewati gate (animasi kabur)
var is_running: bool = false
var _last_dir: String = "south"  # remembered for idle facing

func _physics_process(delta):
	# Pakai floating motion mode supaya gak ada gravitasi
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	prev_position = global_position

	# Kalau ini player mirror, balikkan input dari player sumber
	if mirror_input and is_instance_valid(mirror_source):
		input_dir = Vector2(-mirror_source.input_dir.x, -mirror_source.input_dir.y)
	else:
		# Ambil input keyboard atau joystick (mana yang aktif)
		var kb_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		input_dir = kb_direction
		if touch_vector.length() > 0:
			input_dir = touch_vector

	velocity = input_dir * speed
	move_and_slide()
	_update_animation()

	# Kalau beneran gerak, spawn trail dan mainkan footstep sfx
	var actually_moved = global_position.distance_to(prev_position) > 0.1
	if actually_moved:
		trail_timer += delta
		if trail_timer >= TRAIL_INTERVAL:
			spawn_trail()
			trail_timer = 0.0
			AudioManager.play_sfx("footstep")

	# Precision Collection Check — cek apakah player menyentuh element terdekat
	check_precision_collection()

func check_precision_collection():
	# Ngecek semua element yang ada di nearby_elements pakai swept segment check
	# (dari posisi sebelumnya ke posisi sekarang) biar collect gak kelewatan
	var to_remove = []
	for area in nearby_elements:
		if not is_instance_valid(area):
			to_remove.append(area)
			continue

		# Swept collision check: find the closest point onto our movement segment
		var closest = Geometry2D.get_closest_point_to_segment(area.global_position, prev_position, global_position)
		if closest.distance_to(area.global_position) < COLLECTION_THRESHOLD:
			if area.has_method("collect"):
				area.collect()
				to_remove.append(area)

	# Hapus element yang udah di-collect dari daftar nearby
	for area in to_remove:
		nearby_elements.erase(area)

func _ready():
	collected_elements = {}
	prev_position = global_position
	# Sambungin signal enter/exit dari PickupZone (Area2D child)
	$PickupZone.area_entered.connect(_on_pickup_zone_area_entered)
	$PickupZone.area_exited.connect(_on_pickup_zone_area_exited)

	# Look for joystick in UI — sambungin kalau ada virtual joystick di scene
	var joystick = get_tree().current_scene.get_node_or_null("UI/VirtualJoystick")
	if joystick:
		joystick.joystick_vector.connect(func(v): touch_vector = v)

func spawn_trail():
	# Spawn kotak kecil biru transparan di posisi player — langsung fade out
	var trail = ColorRect.new()
	trail.size = Vector2(6, 6)
	trail.position = global_position - Vector2(3, 3)
	trail.color = Color(0.2, 0.5, 1.0, 0.4)
	trail.z_index = 3
	get_tree().current_scene.add_child(trail)

	# Tween: fade out + scale down + sedikit drift random biar keliatan natural
	var tween = trail.create_tween()
	tween.set_parallel(true)
	tween.tween_property(trail, "modulate:a", 0.0, 0.4)
	tween.tween_property(trail, "scale", Vector2(0.2, 0.2), 0.4)
	tween.tween_property(trail, "position", trail.position + Vector2(randf_range(-3, 3), randf_range(-3, 3)), 0.4)
	tween.tween_callback(trail.queue_free).set_delay(0.4)

func _on_pickup_zone_area_entered(area):
	# Element masuk zona pickup — tambahkan ke daftar dan sambungin signal collected
	if area.has_method("collect") and not area in nearby_elements:
		nearby_elements.append(area)
		if not area.collected.is_connected(_on_element_collected):
			area.collected.connect(_on_element_collected)

func _on_pickup_zone_area_exited(area):
	# Element keluar zona pickup — hapus dari daftar nearby
	if area in nearby_elements:
		nearby_elements.erase(area)

func _on_element_collected(symbol):
	# Dipanggil saat element berhasil di-collect — update inventory dan emit signal ke main
	if not collected_elements.has(symbol):
		collected_elements[symbol] = 0
	collected_elements[symbol] += 1
	collected_signal.emit(symbol)

	# Mainkan animasi collect kalau ada di AnimatedSprite2D
	var anim = get_node_or_null("AnimatedSprite2D")
	if anim and anim.sprite_frames and anim.sprite_frames.has_animation("collect"):
		anim.play("collect")

func get_collected() -> Dictionary:
	# Getter buat inventory — dipanggil dari luar kalau butuh data collected
	return collected_elements

func reset():
	# Reset inventory dan velocity — biasanya dipanggil saat level di-restart
	collected_elements.clear()
	velocity = Vector2.ZERO

func set_running(running: bool):
	# Aktifkan mode running — dipanggil saat player berhasil keluar lewat gate
	is_running = running

func _get_dir_name(vel: Vector2) -> String:
	# Konvert velocity ke nama arah: east/west/south/north buat nama animasi
	if abs(vel.x) > abs(vel.y):
		return "east" if vel.x > 0 else "west"
	return "south" if vel.y > 0 else "north"

func _update_animation():
	# Update AnimatedSprite2D berdasarkan state gerak player
	var anim = get_node_or_null("AnimatedSprite2D")
	if not anim: return

	# Kalau lagi running (kabur dari gate), mainkan animasi run
	if is_running:
		var dir = _get_dir_name(velocity if velocity.length() > 10 else Vector2.DOWN)
		var run_anim = "run_" + dir
		if anim.animation != run_anim:
			anim.play(run_anim)
		return

	# Kalau bergerak, mainkan walk animation sesuai arah
	if velocity.length() > 10:
		var dir = _get_dir_name(velocity)
		_last_dir = dir
		var walk_anim = "walk_" + dir
		if anim.animation != walk_anim:
			anim.play(walk_anim)
	else:
		# Kalau diam, mainkan idle sesuai arah terakhir yang diingat
		var idle_anim = "idle_" + _last_dir
		if anim.sprite_frames and anim.sprite_frames.has_animation(idle_anim):
			if anim.animation != idle_anim or not anim.is_playing():
				anim.play(idle_anim)
		else:
			# Fallback ke idle generik kalau animasi arah-spesifik gak ada
			if anim.animation != "idle" or not anim.is_playing():
				anim.play("idle")
