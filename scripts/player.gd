extends CharacterBody2D

@export var speed: float = 360.0

var collected_elements: Dictionary = {}
signal collected_signal(symbol)

var nearby_elements: Array = []
const COLLECTION_THRESHOLD: float = 10.0 # More generous feel (Tile is 16px)

var trail_timer: float = 0.0
const TRAIL_INTERVAL: float = 0.05
var touch_vector: Vector2 = Vector2.ZERO
var prev_position: Vector2 = Vector2.ZERO

func _physics_process(delta):
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	prev_position = global_position
	
	# Combine Keyboard and Touch Input
	var kb_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var final_direction = kb_direction
	
	if touch_vector.length() > 0:
		final_direction = touch_vector
		
	velocity = final_direction * speed
	move_and_slide()

	var actually_moved = global_position.distance_to(prev_position) > 0.1
	if actually_moved:
		trail_timer += delta
		if trail_timer >= TRAIL_INTERVAL:
			spawn_trail()
			trail_timer = 0.0
			AudioManager.play_sfx("footstep")
	
	# Precision Collection Check
	check_precision_collection()

func check_precision_collection():
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
	
	for area in to_remove:
		nearby_elements.erase(area)

func _ready():
	collected_elements = {}
	prev_position = global_position
	$PickupZone.area_entered.connect(_on_pickup_zone_area_entered)
	$PickupZone.area_exited.connect(_on_pickup_zone_area_exited)
	
	# Look for joystick in UI
	var joystick = get_tree().current_scene.get_node_or_null("UI/VirtualJoystick")
	if joystick:
		joystick.joystick_vector.connect(func(v): touch_vector = v)

func spawn_trail():
	var trail = ColorRect.new()
	trail.size = Vector2(6, 6)
	trail.position = global_position - Vector2(3, 3)
	trail.color = Color(0.2, 0.5, 1.0, 0.4)
	trail.z_index = 3
	get_tree().current_scene.add_child(trail)

	var tween = trail.create_tween()
	tween.set_parallel(true)
	tween.tween_property(trail, "modulate:a", 0.0, 0.4)
	tween.tween_property(trail, "scale", Vector2(0.2, 0.2), 0.4)
	tween.tween_property(trail, "position", trail.position + Vector2(randf_range(-3, 3), randf_range(-3, 3)), 0.4)
	tween.tween_callback(trail.queue_free).set_delay(0.4)

func _on_pickup_zone_area_entered(area):
	if area.has_method("collect") and not area in nearby_elements:
		nearby_elements.append(area)
		if not area.collected.is_connected(_on_element_collected):
			area.collected.connect(_on_element_collected)

func _on_pickup_zone_area_exited(area):
	if area in nearby_elements:
		nearby_elements.erase(area)

func _on_element_collected(symbol):
	if not collected_elements.has(symbol):
		collected_elements[symbol] = 0
	collected_elements[symbol] += 1
	collected_signal.emit(symbol)

func get_collected() -> Dictionary:
	return collected_elements

func reset():
	collected_elements.clear()
	velocity = Vector2.ZERO
