extends Node

var questions: Array = []
var current_level: int = 0

func _ready():
	load_questions()
	print("GameManager: Questions loaded.")

func load_questions():
	if not FileAccess.file_exists("res://assets/questions.json"):
		print("ERROR: questions.json not found!")
		return
		
	var file = FileAccess.open("res://assets/questions.json", FileAccess.READ)
	var content = file.get_as_text()
	questions = JSON.parse_string(content)

func get_current_question():
	if current_level < questions.size():
		return questions[current_level]
	return null

func next_level():
	current_level += 1
	if current_level >= questions.size():
		current_level = 0 # Loop back for now
	return current_level
