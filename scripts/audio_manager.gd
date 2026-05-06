extends Node

# AudioManager - Autoload singleton for game audio

var sfx_players: Dictionary = {}
var music_player: AudioStreamPlayer

func _ready():
	# Preload all SFX
	var sfx_files = {
		"collect": "res://assets/audio/sfx/collect.wav",
		"gate_unlock": "res://assets/audio/sfx/gate_unlock.wav",
		"level_complete": "res://assets/audio/sfx/level_complete.wav",
		"game_complete": "res://assets/audio/sfx/game_complete.wav",
		"ui_click": "res://assets/audio/sfx/ui_click.wav",
		"footstep": "res://assets/audio/sfx/footstep.wav",
		"reset": "res://assets/audio/sfx/reset.wav",
	}

	for key in sfx_files:
		var player = AudioStreamPlayer.new()
		var stream = load(sfx_files[key])
		if stream:
			player.stream = stream
			player.bus = "Master"
		add_child(player)
		sfx_players[key] = player

	# Footstep needs lower volume
	if sfx_players.has("footstep"):
		sfx_players["footstep"].volume_db = -12.0

	# Setup music player
	music_player = AudioStreamPlayer.new()
	var music_stream = load("res://assets/audio/music/ambient.wav")
	if music_stream:
		music_player.stream = music_stream
		music_player.volume_db = -10.0
		music_player.bus = "Master"
	add_child(music_player)

func play_sfx(sfx_name: String):
	if sfx_players.has(sfx_name):
		var player = sfx_players[sfx_name]
		if sfx_name == "footstep" and player.playing:
			return
		player.play()

func play_music():
	if music_player and not music_player.playing:
		music_player.play()
		# Loop by reconnecting finished signal
		if not music_player.finished.is_connected(_on_music_finished):
			music_player.finished.connect(_on_music_finished)

func stop_music():
	if music_player:
		music_player.stop()

func _on_music_finished():
	music_player.play()
