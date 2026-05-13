# main.gd
# Script utama yang ngatur semua gameplay — load maze, spawn player + elemen +
# exit gate, ngatur HUD, transisi antar level, dan handle win condition.
# Ini "conductor"-nya game, semua komponen dikumpulin di sini.
extends Node2D

# Referensi ke maze yang lagi aktif di scene
var current_maze: Node2D

func _ready():
	print("!!! MAIN STARTING !!!")

	# Apply tema UI ke semua overlay dan panel HUD
	var game_theme = UITheme.create_game_theme()
	$UI/HUD.theme = game_theme
	$UI/LevelSelector.theme = game_theme
	$UI/WinOverlay.theme = game_theme
	$UI/MasterOverlay.theme = game_theme
	$UI/TutorialWinOverlay.theme = game_theme
	$UI/LegendaryOverlay.theme = game_theme

	# Bikin style navbar HUD — dark navy dengan border bawah tipis
	var navbar_style = StyleBoxFlat.new()
	navbar_style.bg_color = Color(0.027, 0.043, 0.075, 0.92)
	navbar_style.border_color = UITheme.BORDER
	navbar_style.border_width_bottom = 2
	navbar_style.set_corner_radius_all(0)
	navbar_style.set_content_margin_all(6)
	$UI/HUD.add_theme_stylebox_override("panel", navbar_style)

	# HUD label retint to match terminal palette
	$UI/HUD/HBar/ObjectiveLabel.add_theme_color_override("font_color", UITheme.TEXT_HI)
	$UI/HUD/HBar/InventoryLabel.add_theme_color_override("font_color", UITheme.TEXT)
	$UI/HUD/HBar/ControlHint.add_theme_color_override("font_color", UITheme.TEXT_DIM)

	# Sambungin tombol-tombol di HUD ke fungsinya masing-masing
	$UI/WinOverlay/VBox/NextBtn.pressed.connect(func(): AudioManager.play_sfx("ui_click"); _on_next_level_pressed())
	$UI/MasterOverlay/VBox/RestartBtn.pressed.connect(func(): AudioManager.play_sfx("ui_click"); _on_restart_game_pressed())
	$UI/HUD/HBar/ResetBtn.pressed.connect(func(): AudioManager.play_sfx("reset"); get_tree().reload_current_scene())
	$UI/HUD/HBar/LeaveBtn.pressed.connect(func(): AudioManager.play_sfx("ui_click"); _go_to_menu())

	# Set teks label tombol
	$UI/HUD/HBar/ResetBtn.text = "↺ Ulang"
	$UI/HUD/HBar/LeaveBtn.text = "✕ Keluar"
	$UI/WinOverlay/VBox/NextBtn.text = "Lanjut →"

	# Tombol di TutorialWinOverlay — balik ke menu utama setelah tutorial selesai
	$UI/TutorialWinOverlay/VBox/MenuBtn.pressed.connect(func():
		AudioManager.play_sfx("ui_click")
		GameManager.reset_mode_flags()
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	)

	# Tombol di LegendaryOverlay — balik ke menu setelah menyelesaikan mode legend
	$UI/LegendaryOverlay/VBox/RestartBtn.pressed.connect(func():
		AudioManager.play_sfx("ui_click")
		GameManager.reset_mode_flags()
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	)

	# Setup tombol level selector — kalau tutorial disembunyiin, kalau legend hanya tampil 3 tombol
	var selector = $UI/LevelSelector
	if GameManager.is_tutorial:
		selector.visible = false
	elif GameManager.is_legend_mode:
		for i in range(selector.get_child_count()):
			selector.get_child(i).visible = i < 3
	for i in range(selector.get_child_count()):
		var btn = selector.get_child(i)
		var level_idx = i
		btn.pressed.connect(func(): AudioManager.play_sfx("ui_click"); _on_level_jump(level_idx))

	# Load dan instantiate maze sesuai mode yang aktif
	var maze_container = $MazeContainer
	var maze_scene = load("res://scenes/maze.tscn")
	current_maze = maze_scene.instantiate()
	maze_container.add_child(current_maze)

	# Pilih fungsi load maze sesuai mode: tutorial, legend, atau normal
	var maze_data
	if GameManager.is_tutorial:
		maze_data = current_maze.load_tutorial_maze()
	elif GameManager.is_legend_mode:
		maze_data = current_maze.load_legend_maze(GameManager.legend_level)
	else:
		maze_data = current_maze.load_maze(GameManager.current_level)

	if not maze_data: return

	# Scale dan posisi maze container — legend lebih kecil karena maze-nya lebih besar
	if GameManager.is_legend_mode:
		maze_container.scale = Vector2(2.0, 2.0)
		maze_container.position = Vector2(640.0 - 480.0, 360.0 - 320.0)
	else:
		maze_container.scale = Vector2(3.0, 3.0)
		maze_container.position = Vector2(640.0 - (960.0 / 2.0), 360.0 - (720.0 / 2.0))

	# Ambil soal sesuai level sekarang, update teks objective di HUD
	var current_q = GameManager.get_current_question()
	if not current_q: return

	$UI/HUD/HBar/ObjectiveLabel.text = "Tujuan: " + current_q.question
	$UI/HUD/HBar/InventoryLabel.text = "Inventaris: (kosong)"

	# Tentukan jumlah decoy dan generate spawn plan untuk elemen
	var spawn_plan
	if GameManager.is_legend_mode:
		spawn_plan = current_maze.get_legend_spawns(maze_data, current_q.required, 4)
	elif GameManager.is_tutorial:
		# Tutorial cuma 1 decoy biar gak terlalu susah buat pemula
		spawn_plan = current_maze.get_validated_spawns(maze_data, current_q.required, 1)
	else:
		# Makin tinggi level, makin banyak decoy yang muncul
		var decoy_count = 6 + GameManager.current_level
		spawn_plan = current_maze.get_validated_spawns(maze_data, current_q.required, decoy_count)

	# Kalau spawn gagal, reload scene dan coba lagi
	if not spawn_plan:
		get_tree().call_deferred("reload_current_scene")
		return

	# Spawn player di posisi start maze
	var player_scene = load("res://scenes/player.tscn")
	var player = player_scene.instantiate()
	player.name = "Player"
	player.position = Vector2(maze_data.start * 16) + Vector2(8, 8)
	player.collected_signal.connect(_on_player_collected)
	current_maze.add_child(player)

	# Spawn semua element pickup sesuai spawn plan
	var pickup_scene = load("res://scenes/element_pickup.tscn")
	for pos in spawn_plan:
		var pickup = pickup_scene.instantiate()
		pickup.element_symbol = spawn_plan[pos]
		pickup.position = Vector2(pos * 16) + Vector2(8, 8)
		current_maze.add_child(pickup)

	# Spawn exit gate di posisi exit maze, set required elements-nya
	var exit_scene = load("res://scenes/exit_gate.tscn")
	var exit_gate = exit_scene.instantiate()
	exit_gate.name = "ExitGate"
	exit_gate.position = Vector2(maze_data.exit * 16) + Vector2(8, 8)
	exit_gate.required_elements = current_q.required
	exit_gate.level_completed.connect(_on_exit_reached)
	current_maze.add_child(exit_gate)

	# Kalau mode legend, aktifkan legend mode di gate dan spawn player kedua
	if GameManager.is_legend_mode:
		exit_gate.legend_mode = true
		_setup_legend_second_player(maze_data, player, current_q.required, spawn_plan)

	# Kalau tutorial, setup panel tutorial
	if GameManager.is_tutorial:
		_setup_tutorial(player, exit_gate)

	# Tambahin efek vignette di pinggir layar biar kelihatan lebih dramatis
	setup_vignette()
	print("!!! LEVEL VALIDATED AND LOADED !!!")

func _setup_legend_second_player(maze_data: Dictionary, player_left: CharacterBody2D, _required: Dictionary, _spawn_plan: Dictionary):
	# Spawn player kedua untuk mode legend — input-nya di-mirror dari player pertama
	var player_scene = load("res://scenes/player.tscn")
	var player_right = player_scene.instantiate()
	player_right.name = "PlayerRight"
	player_right.position = Vector2(maze_data.start_right * 16) + Vector2(8, 8)
	# Player kanan geraknya kebalikan dari player kiri
	player_right.mirror_input = true
	player_right.mirror_source = player_left
	# Warna ungu biar beda dari player utama
	player_right.modulate = Color(0.8, 0.6, 1.0)
	player_right.collected_signal.connect(_on_player_collected)
	current_maze.add_child(player_right)

func _setup_tutorial(player: CharacterBody2D, exit_gate: Node):
	# Setup panel tutorial di bawah layar — nampilin instruksi langkah demi langkah
	var tm = $UI/TutorialManager
	if not tm: return

	# Bikin panel container buat tutorial — nempel di bawah layar
	var panel = Panel.new()
	panel.name = "TutorialPanel"
	panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	panel.custom_minimum_size = Vector2(0, 110)
	panel.offset_top = -120
	panel.offset_bottom = -10

	# HUD-matching dark style with teal top border
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.027, 0.043, 0.075, 0.55)
	panel_style.border_color = Color("#14b8a6")
	panel_style.border_width_top = 1
	panel_style.border_width_bottom = 0
	panel_style.border_width_left = 0
	panel_style.border_width_right = 0
	panel_style.set_corner_radius_all(0)
	panel_style.set_content_margin_all(0)
	panel.add_theme_stylebox_override("panel", panel_style)
	tm.add_child(panel)

	# Outer VBox: dots row + content row
	var outer_vbox = VBoxContainer.new()
	outer_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	outer_vbox.add_theme_constant_override("separation", 0)
	panel.add_child(outer_vbox)

	# Step dots row — titik-titik kecil di atas panel buat nunjukin progres tutorial
	var dots_hbox = HBoxContainer.new()
	dots_hbox.name = "StepDots"
	dots_hbox.add_theme_constant_override("separation", 4)
	dots_hbox.custom_minimum_size = Vector2(0, 9)
	var dots_margin = MarginContainer.new()
	dots_margin.add_theme_constant_override("margin_left", 14)
	dots_margin.add_theme_constant_override("margin_top", 5)
	dots_margin.add_theme_constant_override("margin_bottom", 0)
	dots_margin.add_theme_constant_override("margin_right", 0)
	dots_margin.add_child(dots_hbox)
	outer_vbox.add_child(dots_margin)

	# Bikin satu dot per langkah tutorial — warna gelap kalau belum, teal kalau udah
	for i in range(tm.steps.size()):
		var dot = ColorRect.new()
		dot.custom_minimum_size = Vector2(20, 3)
		dot.color = Color("#1d3554")
		dots_hbox.add_child(dot)

	# Content row: label + button — teks instruksi di kiri, tombol OK di kanan
	var content_hbox = HBoxContainer.new()
	content_hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_hbox.add_theme_constant_override("separation", 12)
	var content_margin = MarginContainer.new()
	content_margin.add_theme_constant_override("margin_left", 14)
	content_margin.add_theme_constant_override("margin_right", 14)
	content_margin.add_theme_constant_override("margin_top", 6)
	content_margin.add_theme_constant_override("margin_bottom", 8)
	content_margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_margin.add_child(content_hbox)
	outer_vbox.add_child(content_margin)

	# Label buat nampilin teks tutorial dengan support BBCode
	var lbl = RichTextLabel.new()
	lbl.bbcode_enabled = true
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl.size_flags_vertical = Control.SIZE_EXPAND_FILL
	lbl.scroll_active = false
	content_hbox.add_child(lbl)

	# Tombol OK buat lanjut ke langkah tutorial berikutnya
	var btn = Button.new()
	btn.text = "OK ▶"
	btn.custom_minimum_size = Vector2(80, 0)
	btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	btn.theme = UITheme.create_game_theme()
	content_hbox.add_child(btn)

	# Kasih referensi ke TutorialManager supaya dia bisa ngontrol panel ini
	tm.panel = panel
	tm.panel_label = lbl
	tm.dismiss_btn = btn
	tm.step_dots_container = dots_hbox
	btn.pressed.connect(tm._on_dismiss_pressed)

	# Kumpulin semua pickup yang ada di maze buat dikasih highlight tutorial
	var pickups: Array = []
	for child in current_maze.get_children():
		if child.has_method("set_tutorial_highlight"):
			pickups.append(child)

	# Serahin semua ke TutorialManager buat dikelola
	var required = GameManager.get_current_question().required
	tm.setup(player, exit_gate, required, pickups)

func setup_vignette():
	# Tambahin efek vignette (gelap di pinggir) pakai shader — cuma sekali aja
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
	mat.set_shader_parameter("tint_color", Color(0.15, 0.03, 0.03, 1.0))
	vignette.material = mat
	vignette.color = Color.WHITE
	$UI.add_child(vignette)

func screen_shake(intensity: float = 2.0, duration: float = 0.1):
	# Efek screen shake — gerakin MazeContainer ke random arah beberapa kali
	var container = $MazeContainer
	var original_pos = container.position
	var tween = create_tween()
	var steps = int(duration / 0.02)
	for i in range(steps):
		var offset = Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))
		tween.tween_property(container, "position", original_pos + offset, 0.02)
	# Kembaliin ke posisi semula setelah shake selesai
	tween.tween_property(container, "position", original_pos, 0.02)

func _unhandled_input(event):
	# Tombol R buat reset level sekarang — handy buat kalau salah collect
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_R:
			AudioManager.play_sfx("reset")
			get_tree().reload_current_scene()

func _on_player_collected(_symbol):
	# Dipanggil setiap kali player collect element — update inventory display
	var player = current_maze.get_node_or_null("Player")
	if not player: return
	var inventory = player.collected_elements.duplicate()

	# Mode legend: gabungin inventory dua player sebelum dicek
	if GameManager.is_legend_mode:
		var player_right = current_maze.get_node_or_null("PlayerRight")
		if player_right:
			for sym in player_right.collected_elements:
				inventory[sym] = inventory.get(sym, 0) + player_right.collected_elements[sym]

	# Update teks inventory di HUD
	$UI/HUD/HBar/InventoryLabel.text = format_inventory(inventory)
	screen_shake(2.0, 0.1)
	AudioManager.play_sfx("collect")

	# Cek apakah inventory udah cocok sama yang dibutuhkan gate
	var gate = current_maze.get_node_or_null("ExitGate")
	if gate:
		gate.check_requirements(inventory)
		# Kalau gate udah terbuka dan lagi di tutorial, kasih tau TutorialManager
		if gate.is_open and GameManager.is_tutorial:
			var tm = get_node_or_null("UI/TutorialManager")
			if tm: tm.notify_gate_opened()

func _on_exit_reached():
	# Player berhasil mencapai exit gate yang terbuka — tampilkan win overlay
	# Trigger run animation on player(s) as they escape
	var player = current_maze.get_node_or_null("Player")
	if player and player.has_method("set_running"):
		player.set_running(true)
	var player_right = current_maze.get_node_or_null("PlayerRight")
	if player_right and player_right.has_method("set_running"):
		player_right.set_running(true)

	# Flash putih singkat sebagai efek transisi saat keluar
	var flash = ColorRect.new()
	flash.color = Color.WHITE
	flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$UI.add_child(flash)
	var ft = create_tween()
	ft.tween_property(flash, "modulate:a", 0.0, 0.4)
	ft.tween_callback(flash.queue_free)
	screen_shake(4.0, 0.2)

	# Mode tutorial selesai — tampilkan overlay khusus tutorial
	if GameManager.is_tutorial:
		GameManager.tutorial_completed = true
		GameManager.is_tutorial = false
		$UI/TutorialWinOverlay.visible = true
		AudioManager.play_sfx("level_complete")
		return

	# Mode legend — cek apakah ini level terakhir legend atau masih ada lagi
	if GameManager.is_legend_mode:
		if GameManager.legend_level == 2:
			# Level terakhir legend — tampilkan overlay "Legendary!"
			$UI/LegendaryOverlay.visible = true
			AudioManager.play_sfx("game_complete")
		else:
			$UI/WinOverlay.visible = true
			AudioManager.play_sfx("level_complete")
		return

	# Mode normal — cek apakah ini level terakhir (level 9)
	if GameManager.current_level == 9:
		# Selesai semua! Tampilkan master overlay
		$UI/MasterOverlay.visible = true
		AudioManager.play_sfx("game_complete")
	else:
		# Masih ada level berikutnya
		$UI/WinOverlay.visible = true
		AudioManager.play_sfx("level_complete")

func _on_next_level_pressed():
	# Tombol "Next" di win overlay — lanjut ke level berikutnya
	if GameManager.is_legend_mode:
		GameManager.legend_level += 1
		get_tree().reload_current_scene()
	else:
		transition_to_next()

func transition_to_next():
	# Transisi fade ke hitam sebelum load level berikutnya — biar halus
	var fade = ColorRect.new()
	fade.color = Color.BLACK
	fade.modulate.a = 0.0
	fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	$UI.add_child(fade)

	var tween = create_tween()
	# Fade in ke hitam dulu...
	tween.tween_property(fade, "modulate:a", 1.0, 0.5)
	# ...baru reload scene dengan level berikutnya
	tween.tween_callback(func():
		GameManager.next_level()
		get_tree().reload_current_scene()
	)

func _go_to_menu():
	# Balik ke main menu — reset semua flag mode dulu
	GameManager.reset_mode_flags()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_restart_game_pressed():
	# Restart dari awal — reset ke level 0
	GameManager.reset_mode_flags()
	GameManager.current_level = 0
	get_tree().call_deferred("reload_current_scene")

func _on_level_jump(index: int):
	# Loncat langsung ke level tertentu lewat tombol level selector
	if GameManager.is_legend_mode:
		GameManager.legend_level = index
	else:
		GameManager.current_level = index
	get_tree().call_deferred("reload_current_scene")

func format_inventory(inventory: Dictionary) -> String:
	# Format dictionary inventory jadi string yang enak dibaca di HUD
	if inventory.is_empty():
		return "Inventaris: (kosong)"
	var parts = []
	for symbol in inventory:
		if inventory[symbol] > 0:
			parts.append(symbol + " ×" + str(inventory[symbol]))
	return "Inventaris: " + " | ".join(parts)
