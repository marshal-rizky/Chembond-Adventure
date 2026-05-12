# game_manager.gd
# Ini autoload singleton yang ngatur state global game — level sekarang,
# daftar soal, mode tutorial/legend, dll. Dipanggil dari mana aja lewat "GameManager".
extends Node

# Array buat nyimpen semua soal biasa dan soal khusus mode legend
var questions: Array = []
var legend_questions: Array = []

# Level yang lagi dimainkan sekarang (index 0-9 buat mode normal)
var current_level: int = 0

# Flag-flag buat ngecek mode apa yang lagi aktif
var is_tutorial: bool = false
var tutorial_completed: bool = false
var is_legend_mode: bool = false
var legend_level: int = 0
var legend_unlocked: bool = true  # set false before shipping; require level 9 clear

func _ready():
	# Langsung load soal pas game pertama kali jalan
	load_questions()
	print("GameManager: Questions loaded.")

func load_questions():
	# Cek dulu file-nya ada gak, biar gak crash
	if not FileAccess.file_exists("res://assets/questions.json"):
		print("ERROR: questions.json not found!")
		return

	# Buka file JSON, baca isinya, terus parse jadi array
	var file = FileAccess.open("res://assets/questions.json", FileAccess.READ)
	var content = file.get_as_text()
	var all_questions = JSON.parse_string(content)

	# Pisahin antara soal legend (ada field "legend": true) dan soal biasa
	for q in all_questions:
		if q.get("legend", false):
			legend_questions.append(q)
		else:
			questions.append(q)

func get_current_question():
	# Ambil soal sesuai mode yang lagi aktif
	if is_legend_mode:
		if legend_level < legend_questions.size():
			return legend_questions[legend_level]
		return null
	# Mode normal — ambil soal berdasarkan current_level
	if current_level < questions.size():
		return questions[current_level]
	return null

func next_level():
	# Pindah ke level berikutnya — ada bedanya antara mode legend sama mode normal
	if is_legend_mode:
		legend_level += 1
		# Kalau udah habis, balik ke awal
		if legend_level >= legend_questions.size():
			legend_level = 0
		return legend_level
	current_level += 1
	# Kalau udah selesai semua level normal, loop balik ke 0
	if current_level >= questions.size():
		current_level = 0
	return current_level

func reset_mode_flags():
	# Reset semua flag mode — dipanggil pas balik ke menu utama
	is_tutorial = false
	is_legend_mode = false
	legend_level = 0
