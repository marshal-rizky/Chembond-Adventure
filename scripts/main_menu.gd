extends Control

# main_menu.gd

func _ready():
	# Apply theme
	theme = UITheme.create_game_theme()

	# Update colors and visuals
	$VBoxContainer/Title.modulate = Color(0, 1, 1) # Cyan Title

	# Connect Buttons
	$VBoxContainer/StartBtn.pressed.connect(func(): AudioManager.play_sfx("ui_click"); _on_start_pressed())
	$VBoxContainer/QuitBtn.pressed.connect(func(): AudioManager.play_sfx("ui_click"); _on_quit_pressed())

	# Start music
	AudioManager.play_music()

	# Create floating atoms juice
	spawn_floating_atoms()

func spawn_floating_atoms():
	var symbols = ["H", "O", "C", "Na", "Cl", "Si"]
	for i in range(12):
		var atom = Label.new()
		atom.text = symbols[randi() % symbols.size()]
		atom.scale = Vector2(2, 2)
		atom.position = Vector2(randf_range(0, 1280), randf_range(0, 720))
		atom.modulate.a = 0.3
		add_child(atom)
		
		# Animate drift
		var tween = create_tween().set_loops()
		var target = atom.position + Vector2(randf_range(-100, 100), randf_range(-100, 100))
		tween.tween_property(atom, "position", target, randf_range(3.0, 6.0)).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(atom, "position", atom.position, randf_range(3.0, 6.0)).set_ease(Tween.EASE_IN_OUT)

func _on_start_pressed():
	# Transition to Main Game
	GameManager.current_level = 0
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_quit_pressed():
	get_tree().quit()
