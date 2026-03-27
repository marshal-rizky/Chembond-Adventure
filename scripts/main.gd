extends Node2D

var current_maze: Node2D

func _ready():
	print("!!! MAIN STARTING !!!")

	# Apply theme
	var game_theme = UITheme.create_game_theme()
	$UI/HUD.theme = game_theme
	$UI/LevelSelector.theme = game_theme
	$UI/WinOverlay.theme = game_theme
	$UI/MasterOverlay.theme = game_theme

	# Navbar-specific panel style (slim, transparent)
	var navbar_style = StyleBoxFlat.new()
	navbar_style.bg_color = Color(0.04, 0.04, 0.12, 0.75)
	navbar_style.border_color = Color(0.0, 0.4, 0.5, 0.4)
	navbar_style.border_width_bottom = 1
	navbar_style.set_corner_radius_all(0)
	navbar_style.set_content_margin_all(6)
	$UI/HUD.add_theme_stylebox_override("panel", navbar_style)

	# Connect UI Signals
	$UI/WinOverlay/VBox/NextBtn.pressed.connect(func(): AudioManager.play_sfx("ui_click"); _on_next_level_pressed())
	$UI/MasterOverlay/VBox/RestartBtn.pressed.connect(func(): AudioManager.play_sfx("ui_click"); _on_restart_game_pressed())
	$UI/HUD/HBar/ResetBtn.pressed.connect(func(): AudioManager.play_sfx("ui_click"); get_tree().reload_current_scene())
	
	var selector = $UI/LevelSelector
	for i in range(selector.get_child_count()):
		var btn = selector.get_child(i)
		var level_idx = i  # Capture by value
		btn.pressed.connect(func(): AudioManager.play_sfx("ui_click"); _on_level_jump(level_idx))
	
	# 1. Load Maze
	var maze_container = $MazeContainer
	var maze_scene = load("res://scenes/maze.tscn")
	current_maze = maze_scene.instantiate()
	maze_container.add_child(current_maze)

	var maze_data = current_maze.load_maze(GameManager.current_level)
	if not maze_data: return
	
	maze_container.scale = Vector2(3.0, 3.0)
	maze_container.position = Vector2(640.0 - (960.0/2.0), 360.0 - (720.0/2.0))
	
	# 2. Setup Objective
	var current_q = GameManager.get_current_question()
	if not current_q: return
	
	$UI/HUD/HBar/ObjectiveLabel.text = "Objective: " + current_q.question
	$UI/HUD/HBar/InventoryLabel.text = "Inventory: (empty)"
	
	# 3. Spawns
	var decoy_count = 6 + GameManager.current_level
	var spawn_plan = current_maze.get_validated_spawns(maze_data, current_q.required, decoy_count)
	
	if not spawn_plan:
		get_tree().call_deferred("reload_current_scene")
		return
		
	# 4. Player
	var player_scene = load("res://scenes/player.tscn")
	var player = player_scene.instantiate()
	player.position = Vector2(maze_data.start * 16) + Vector2(8, 8)
	player.collected_signal.connect(_on_player_collected)
	current_maze.add_child(player)

	# 5. Elements
	var pickup_scene = load("res://scenes/element_pickup.tscn")
	for pos in spawn_plan:
		var pickup = pickup_scene.instantiate()
		pickup.element_symbol = spawn_plan[pos]
		pickup.position = Vector2(pos * 16) + Vector2(8, 8)
		current_maze.add_child(pickup)

	# 6. Exit Gate
	var exit_scene = load("res://scenes/exit_gate.tscn")
	var exit_gate = exit_scene.instantiate()
	exit_gate.position = Vector2(maze_data.exit * 16) + Vector2(8, 8)
	exit_gate.required_elements = current_q.required
	exit_gate.level_completed.connect(_on_exit_reached)
	current_maze.add_child(exit_gate)

	# 7. Screen Effects (Vignette)
	setup_vignette()
	
	print("!!! LEVEL VALIDATED AND LOADED !!!")

func setup_vignette():
	if get_node_or_null("UI/Vignette"): return
	var vignette = ColorRect.new()
	vignette.name = "Vignette"
	vignette.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shader = load("res://assets/shaders/vignette.gdshader")
	var mat = ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("strength", 0.5)
	mat.set_shader_parameter("radius", 0.65)
	mat.set_shader_parameter("softness", 0.45)
	vignette.material = mat
	vignette.color = Color.WHITE
	$UI.add_child(vignette)

func screen_shake(intensity: float = 2.0, duration: float = 0.1):
	var container = $MazeContainer
	var original_pos = container.position
	var tween = create_tween()
	var steps = int(duration / 0.02)
	for i in range(steps):
		var offset = Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))
		tween.tween_property(container, "position", original_pos + offset, 0.02)
	tween.tween_property(container, "position", original_pos, 0.02)

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_R:
			AudioManager.play_sfx("reset")
			get_tree().reload_current_scene()

func _on_player_collected(_symbol):
	var player = current_maze.get_node("Player")
	var inventory = player.collected_elements
	$UI/HUD/HBar/InventoryLabel.text = format_inventory(inventory)
	screen_shake(2.0, 0.1)
	AudioManager.play_sfx("collect")

	var gate = current_maze.get_node("ExitGate")
	if gate:
		gate.check_requirements(inventory)

func _on_exit_reached():
	# White flash
	var flash = ColorRect.new()
	flash.color = Color.WHITE
	flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$UI.add_child(flash)
	var ft = create_tween()
	ft.tween_property(flash, "modulate:a", 0.0, 0.4)
	ft.tween_callback(flash.queue_free)

	screen_shake(4.0, 0.2)

	if GameManager.current_level == 9: # Level 10 finished
		$UI/MasterOverlay.visible = true
		AudioManager.play_sfx("game_complete")
	else:
		$UI/WinOverlay.visible = true
		AudioManager.play_sfx("level_complete")

func _on_next_level_pressed():
	transition_to_next()

func transition_to_next():
	var fade = ColorRect.new()
	fade.color = Color.BLACK
	fade.modulate.a = 0.0
	fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	$UI.add_child(fade)
	
	var tween = create_tween()
	tween.tween_property(fade, "modulate:a", 1.0, 0.5)
	tween.tween_callback(func():
		GameManager.next_level()
		get_tree().reload_current_scene()
	)

func _on_restart_game_pressed():
	GameManager.current_level = 0
	get_tree().call_deferred("reload_current_scene")

func _on_level_jump(index: int):
	GameManager.current_level = index
	get_tree().call_deferred("reload_current_scene")

func format_inventory(inventory: Dictionary) -> String:
	if inventory.is_empty():
		return "Inventory: (empty)"
	var parts = []
	for symbol in inventory:
		if inventory[symbol] > 0:
			parts.append(symbol + " ×" + str(inventory[symbol]))
	return "Inventory: " + " | ".join(parts)
