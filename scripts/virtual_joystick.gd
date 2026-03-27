extends Control

# virtual_joystick.gd

signal joystick_vector(vector: Vector2)

@onready var base = $Base
@onready var handle = $Base/Handle

var max_distance: float = 50.0
var dragging: bool = false
var finger_index: int = -1

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			var dist = event.position.distance_to(base.global_position)
			if dist < max_distance * 2.0: # Catch touch near the base
				dragging = true
				finger_index = event.index
		elif event.index == finger_index:
			dragging = false
			finger_index = -1
			handle.position = Vector2.ZERO
			joystick_vector.emit(Vector2.ZERO)
			
	if event is InputEventScreenDrag and dragging and event.index == finger_index:
		var center = base.global_position
		var delta = event.position - center
		delta = delta.limit_length(max_distance)
		handle.position = delta
		
		# Normalize and emit
		var output = delta / max_distance
		joystick_vector.emit(output)
