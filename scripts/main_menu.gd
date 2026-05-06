extends Control

func _ready():
	theme = UITheme.create_game_theme()

	_spawn_grid_bg()
	_spawn_logo()

	$VBoxContainer/StartBtn.pressed.connect(func(): AudioManager.play_sfx("ui_click"); _on_start_pressed())
	$VBoxContainer/TutorialBtn.pressed.connect(func(): AudioManager.play_sfx("ui_click"); _on_tutorial_pressed())
	$VBoxContainer/LegendBtn.pressed.connect(func(): AudioManager.play_sfx("ui_click"); _on_legend_btn_pressed())
	$VBoxContainer/QuitBtn.pressed.connect(func(): AudioManager.play_sfx("ui_click"); _on_quit_pressed())
	$LegendRulesPopup/VBox/GotItBtn.pressed.connect(_on_got_it_pressed)

	$VBoxContainer/LegendBtn.disabled = not GameManager.legend_unlocked
	$LegendRulesPopup.visible = false

	AudioManager.play_music()
	spawn_floating_atoms()

func _spawn_grid_bg():
	var grid = ColorRect.new()
	grid.name = "GridBg"
	grid.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	grid.z_index = -10
	grid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shader = load("res://assets/shaders/grid.gdshader")
	var mat = ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("grid_size", 24.0)
	mat.set_shader_parameter("bg_color", Color(0.027, 0.043, 0.075, 1.0))
	mat.set_shader_parameter("line_color", Color(0.078, 0.718, 0.651, 0.12))
	mat.set_shader_parameter("line_width", 0.5)
	grid.material = mat
	grid.color = Color.WHITE
	add_child(grid)
	move_child(grid, 0)

func _spawn_logo():
	var hbox = HBoxContainer.new()
	hbox.name = "LogoRow"
	hbox.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	hbox.offset_top = 40
	hbox.offset_bottom = 100
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 10)
	add_child(hbox)

	var hex_lbl = Label.new()
	hex_lbl.text = "⬡"
	hex_lbl.add_theme_font_size_override("font_size", 32)
	hex_lbl.add_theme_color_override("font_color", Color("#14b8a6"))
	hbox.add_child(hex_lbl)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)

	var title_lbl = Label.new()
	title_lbl.text = "CHEMBOND"
	title_lbl.add_theme_font_size_override("font_size", 28)
	title_lbl.add_theme_color_override("font_color", Color("#5eead4"))
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	vbox.add_child(title_lbl)

	var sub_lbl = Label.new()
	sub_lbl.text = "ADVENTURE"
	sub_lbl.add_theme_font_size_override("font_size", 12)
	sub_lbl.add_theme_color_override("font_color", Color("#cfeae6"))
	sub_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	vbox.add_child(sub_lbl)

	hbox.add_child(vbox)

func spawn_floating_atoms():
	var element_colors = {
		"H": Color.CYAN, "O": Color.RED, "C": Color.GRAY,
		"Na": Color.YELLOW, "Cl": Color.GREEN, "N": Color.BLUE,
		"Mg": Color.ORANGE, "Ca": Color.ORANGE_RED, "Si": Color.SADDLE_BROWN,
		"S": Color.YELLOW_GREEN, "K": Color.MEDIUM_PURPLE, "Fe": Color.DARK_GRAY,
		"Cu": Color.CORAL, "Zn": Color.LIGHT_SLATE_GRAY, "P": Color.LIME_GREEN,
		"Al": Color.SILVER
	}
	var symbols = element_colors.keys()
	for i in range(35):
		var sym: String = symbols[randi() % symbols.size()]
		var col: Color = element_colors[sym]
		col.a = randf_range(0.04, 0.08)

		var lbl = Label.new()
		lbl.text = sym
		lbl.add_theme_font_size_override("font_size", randi_range(28, 52))
		lbl.add_theme_color_override("font_color", col)
		lbl.position = Vector2(randf_range(0, 1280), randf_range(0, 720))
		lbl.z_index = -5
		lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(lbl)

		var tween = create_tween().set_loops()
		var target = lbl.position + Vector2(randf_range(-150, 150), randf_range(-150, 150))
		tween.tween_property(lbl, "position", target, randf_range(6.0, 12.0)).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(lbl, "position", lbl.position, randf_range(6.0, 12.0)).set_ease(Tween.EASE_IN_OUT)

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
