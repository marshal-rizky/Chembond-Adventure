extends Control

func _ready():
	theme = UITheme.create_game_theme()
	$VBoxContainer/Title.modulate = Color(0, 1, 1)

	$VBoxContainer/StartBtn.pressed.connect(func(): AudioManager.play_sfx("ui_click"); _on_start_pressed())
	$VBoxContainer/TutorialBtn.pressed.connect(func(): AudioManager.play_sfx("ui_click"); _on_tutorial_pressed())
	$VBoxContainer/LegendBtn.pressed.connect(func(): AudioManager.play_sfx("ui_click"); _on_legend_btn_pressed())
	$VBoxContainer/QuitBtn.pressed.connect(func(): AudioManager.play_sfx("ui_click"); _on_quit_pressed())
	$LegendRulesPopup/VBox/GotItBtn.pressed.connect(_on_got_it_pressed)

	$VBoxContainer/LegendBtn.disabled = not GameManager.legend_unlocked
	$LegendRulesPopup.visible = false

	AudioManager.play_music()
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
		var tween = create_tween().set_loops()
		var target = atom.position + Vector2(randf_range(-100, 100), randf_range(-100, 100))
		tween.tween_property(atom, "position", target, randf_range(3.0, 6.0)).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(atom, "position", atom.position, randf_range(3.0, 6.0)).set_ease(Tween.EASE_IN_OUT)

func _on_start_pressed():
	GameManager.reset_mode_flags()
	GameManager.current_level = 0
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_tutorial_pressed():
	GameManager.reset_mode_flags()
	GameManager.is_tutorial = true
	GameManager.current_level = 0
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_legend_btn_pressed():
	$LegendRulesPopup.visible = true

func _on_got_it_pressed():
	$LegendRulesPopup.visible = false
	GameManager.reset_mode_flags()
	GameManager.is_legend_mode = true
	GameManager.legend_level = 0
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_quit_pressed():
	get_tree().quit()
