extends Node

var questions: Array = []
var legend_questions: Array = []
var current_level: int = 0

var is_tutorial: bool = false
var tutorial_completed: bool = false
var is_legend_mode: bool = false
var legend_level: int = 0
var legend_unlocked: bool = true  # set false before shipping; require level 9 clear

func _ready():
	load_questions()
	print("GameManager: Questions loaded.")

func load_questions():
	if not FileAccess.file_exists("res://assets/questions.json"):
		print("ERROR: questions.json not found!")
		return
	var file = FileAccess.open("res://assets/questions.json", FileAccess.READ)
	var content = file.get_as_text()
	var all_questions = JSON.parse_string(content)
	for q in all_questions:
		if q.get("legend", false):
			legend_questions.append(q)
		else:
			questions.append(q)

func get_current_question():
	if is_legend_mode:
		if legend_level < legend_questions.size():
			return legend_questions[legend_level]
		return null
	if current_level < questions.size():
		return questions[current_level]
	return null

func next_level():
	if is_legend_mode:
		legend_level += 1
		if legend_level >= legend_questions.size():
			legend_level = 0
		return legend_level
	current_level += 1
	if current_level >= questions.size():
		current_level = 0
	return current_level

func reset_mode_flags():
	is_tutorial = false
	is_legend_mode = false
	legend_level = 0
