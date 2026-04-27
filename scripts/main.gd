extends Node2D

var current_maze: Node2D

func _ready():
	print("!!! MAIN STARTING !!!")

	var game_theme = UITheme.create_game_theme()
	$UI/HUD.theme = game_theme
	$UI/LevelSelector.theme = game_theme
	$UI/WinOverlay.theme = game_theme
	$UI/MasterOverlay.theme = game_theme

	var navbar_style = StyleBoxFlat.new()
	navbar_style.bg_color = Color(0.04, 0.04, 0.12, 0.75)
	navbar_style.border_color = Color(0.0, 0.4, 0.5, 0.4)
	navbar_style.border_width_bottom = 1
	navbar_style.set_corner_radius_all(0)
	navbar_style.set_content_margin_all(6)
	$UI/HUD.add_theme_stylebox_override("panel", navbar_style)

	$UI/WinOverlay/VBox/NextBtn.pressed.connect(func(): AudioManager.play_sfx("ui_click"); _on_next_level_pressed())
	$UI/MasterOverlay/VBox/RestartBtn.pressed.connect(func(): AudioManager.play_sfx("ui_click"); _on_restart_game_pressed())
	$UI/HUD/HBar/ResetBtn.pressed.connect(func(): AudioManager.play_sfx("reset"); get_tree().reload_current_scene())
	$UI/HUD/HBar/LeaveBtn.pressed.connect(func(): AudioManager.play_sfx("ui_click"); _go_to_menu())

	$UI/TutorialWinOverlay/VBox/MenuBtn.pressed.connect(func():
		AudioManager.play_sfx("ui_click")
		GameManager.reset_mode_flags()
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	)

	$UI/LegendaryOverlay/VBox/RestartBtn.pressed.connect(func():
		AudioManager.play_sfx("ui_click")
		GameManager.reset_mode_flags()
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	)

	var selector = $UI/LevelSelector
	for i in range(selector.get_child_count()):
		var btn = selector.get_child(i)
		var level_idx = i
		btn.pressed.connect(func(): AudioManager.play_sfx("ui_click"); _on_level_jump(level_idx))

	var maze_container = $MazeContainer
	var maze_scene = load("res://scenes/maze.tscn")
	current_maze = maze_scene.instantiate()
	maze_container.add_child(current_maze)

	var maze_data
	if GameManager.is_tutorial:
		maze_data = current_maze.load_tutorial_maze()
	elif GameManager.is_legend_mode:
		maze_data = current_maze.load_legend_maze(GameManager.legend_level)
	else:
		maze_data = current_maze.load_maze(GameManager.current_level)

	if not maze_data: return

	if GameManager.is_legend_mode:
		maze_container.scale = Vector2(2.0, 2.0)
		maze_container.position = Vector2(640.0 - 480.0, 360.0 - 320.0)
	else:
		maze_container.scale = Vector2(3.0, 3.0)
		maze_container.position = Vector2(640.0 - (960.0 / 2.0), 360.0 - (720.0 / 2.0))

	var current_q = GameManager.get_current_question()
	if not current_q: return

	$UI/HUD/HBar/ObjectiveLabel.text = "Objective: " + current_q.question
	$UI/HUD/HBar/InventoryLabel.text = "Inventory: (empty)"

	var spawn_plan
	if GameManager.is_legend_mode:
		spawn_plan = current_maze.get_legend_spawns(maze_data, current_q.required, 4)
	elif GameManager.is_tutorial:
		spawn_plan = current_maze.get_validated_spawns(maze_data, current_q.required, 1)
	else:
		var decoy_count = 6 + GameManager.current_level
		spawn_plan = current_maze.get_validated_spawns(maze_data, current_q.required, decoy_count)

	if not spawn_plan:
		get_tree().call_deferred("reload_current_scene")
		return

	var player_scene = load("res://scenes/player.tscn")
	var player = player_scene.instantiate()
	player.name = "Player"
	player.position = Vector2(maze_data.start * 16) + Vector2(8, 8)
	player.collected_signal.connect(_on_player_collected)
	current_maze.add_child(player)

	var pickup_scene = load("res://scenes/element_pickup.tscn")
	for pos in spawn_plan:
		var pickup = pickup_scene.instantiate()
		pickup.element_symbol = spawn_plan[pos]
		pickup.position = Vector2(pos * 16) + Vector2(8, 8)
		current_maze.add_child(pickup)

	var exit_scene = load("res://scenes/exit_gate.tscn")
	var exit_gate = exit_scene.instantiate()
	exit_gate.name = "ExitGate"
	exit_gate.position = Vector2(maze_data.exit * 16) + Vector2(8, 8)
	exit_gate.required_elements = current_q.required
	exit_gate.level_completed.connect(_on_exit_reached)
	current_maze.add_child(exit_gate)

	if GameManager.is_legend_mode:
		exit_gate.legend_mode = true
		_setup_legend_second_player(maze_data, player, current_q.required, spawn_plan)

	if GameManager.is_tutorial:
		_setup_tutorial(player, exit_gate)

	setup_vignette()
	print("!!! LEVEL VALIDATED AND LOADED !!!")

func _setup_legend_second_player(maze_data: Dictionary, player_left: CharacterBody2D, _required: Dictionary, _spawn_plan: Dictionary):
	var player_scene = load("res://scenes/player.tscn")
	var player_right = player_scene.instantiate()
	player_right.name = "PlayerRight"
	player_right.position = Vector2(maze_data.start_right * 16) + Vector2(8, 8)
	player_right.mirror_input = true
	player_right.mirror_source = player_left
	player_right.modulate = Color(0.8, 0.6, 1.0)
	player_right.collected_signal.connect(_on_player_collected)
	current_maze.add_child(player_right)

func _setup_tutorial(player: CharacterBody2D, exit_gate: Node):
	var tm = $UI/TutorialManager
	if not tm: return

	var panel = Panel.new()
	panel.name = "TutorialPanel"
	panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	panel.custom_minimum_size = Vector2(0, 100)
	panel.offset_top = -110
	panel.offset_bottom = -10
	panel.modulate = Color(1, 1, 1, 0.92)
	tm.add_child(panel)

	var lbl = RichTextLabel.new()
	lbl.bbcode_enabled = true
	lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	lbl.offset_left = 16
	lbl.offset_right = -120
	lbl.offset_top = 8
	lbl.offset_bottom = -8
	panel.add_child(lbl)

	var btn = Button.new()
	btn.text = "OK"
	btn.set_anchor_and_offset(SIDE_RIGHT, 1.0, -8)
	btn.set_anchor_and_offset(SIDE_LEFT, 1.0, -100)
	btn.set_anchor_and_offset(SIDE_TOP, 0.5, -20)
	btn.set_anchor_and_offset(SIDE_BOTTOM, 0.5, 20)
	panel.add_child(btn)

	tm.panel = panel
	tm.panel_label = lbl
	tm.dismiss_btn = btn
	btn.pressed.connect(tm._on_dismiss_pressed)
	tm.setup(player, exit_gate)

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
	var player = current_maze.get_node_or_null("Player")
	if not player: return
	var inventory = player.collected_elements.duplicate()

	if GameManager.is_legend_mode:
		var player_right = current_maze.get_node_or_null("PlayerRight")
		if player_right:
			for sym in player_right.collected_elements:
				inventory[sym] = inventory.get(sym, 0) + player_right.collected_elements[sym]

	$UI/HUD/HBar/InventoryLabel.text = format_inventory(inventory)
	screen_shake(2.0, 0.1)
	AudioManager.play_sfx("collect")

	var gate = current_maze.get_node_or_null("ExitGate")
	if gate:
		gate.check_requirements(inventory)
		if gate.is_open and GameManager.is_tutorial:
			var tm = get_node_or_null("UI/TutorialManager")
			if tm: tm.notify_gate_opened()

func _on_exit_reached():
	var flash = ColorRect.new()
	flash.color = Color.WHITE
	flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$UI.add_child(flash)
	var ft = create_tween()
	ft.tween_property(flash, "modulate:a", 0.0, 0.4)
	ft.tween_callback(flash.queue_free)
	screen_shake(4.0, 0.2)

	if GameManager.is_tutorial:
		GameManager.tutorial_completed = true
		GameManager.is_tutorial = false
		$UI/TutorialWinOverlay.visible = true
		AudioManager.play_sfx("level_complete")
		return

	if GameManager.is_legend_mode:
		if GameManager.legend_level == 2:
			$UI/LegendaryOverlay.visible = true
			AudioManager.play_sfx("game_complete")
		else:
			$UI/WinOverlay.visible = true
			AudioManager.play_sfx("level_complete")
		return

	if GameManager.current_level == 9:
		$UI/MasterOverlay.visible = true
		AudioManager.play_sfx("game_complete")
	else:
		$UI/WinOverlay.visible = true
		AudioManager.play_sfx("level_complete")

func _on_next_level_pressed():
	if GameManager.is_legend_mode:
		GameManager.legend_level += 1
		get_tree().reload_current_scene()
	else:
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

func _go_to_menu():
	GameManager.reset_mode_flags()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_restart_game_pressed():
	GameManager.reset_mode_flags()
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
