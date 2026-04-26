extends Node

# TutorialManager — injected into main.tscn, active only when GameManager.is_tutorial

var current_step: int = 0
var step_complete: bool = false

var player: CharacterBody2D = null
var exit_gate: Node = null

# Panel references (set by main.gd after spawning)
var panel: Panel = null
var panel_label: RichTextLabel = null
var dismiss_btn: Button = null

var steps = [
	{
		"text": "[b]Step 1:[/b] Use [b]WASD[/b] / Arrow Keys or the [b]joystick[/b] to move.",
		"trigger": "move",
		"arrow_target": ""
	},
	{
		"text": "[b]Objective:[/b] Collect the atoms shown in your [b]HUD[/b] to form the molecule.",
		"trigger": "tap",
		"arrow_target": "objective"
	},
	{
		"text": "[b]Good![/b] Walk over atoms to collect them. Watch your [b]inventory[/b] update.",
		"trigger": "tap",
		"arrow_target": "inventory"
	},
	{
		"text": "[color=yellow]⚠ Warning:[/color] Only collect the atoms you [b]need[/b]. Extra atoms will keep the gate [b]locked![/b]\n\n[b]Tip:[/b] Don't take molecules you don't need.",
		"trigger": "tap",
		"arrow_target": ""
	},
	{
		"text": "Picked up the wrong atom? Press [b]R[/b] or tap [b]Reset[/b] to restart the level.\n\n[b]Tip:[/b] Reset if you think you got the wrong molecules.",
		"trigger": "tap",
		"arrow_target": "reset"
	},
	{
		"text": "[b]Molecule complete![/b] The exit gate is now open — reach it to finish.",
		"trigger": "tap",
		"arrow_target": ""
	}
	# Step 7 (win) is handled by main.gd showing TutorialWinOverlay
]

var atom_collected_once: bool = false
var gate_opened: bool = false

func setup(p: CharacterBody2D, gate: Node):
	player = p
	exit_gate = gate
	player.collected_signal.connect(_on_atom_collected)
	show_step(0)

func _physics_process(_delta):
	if not is_instance_valid(player): return
	if current_step == 0 and not step_complete:
		if player.velocity.length() > 0.1:
			advance_step()

func show_step(index: int):
	if index >= steps.size(): return
	current_step = index
	step_complete = false
	var step = steps[index]
	panel_label.text = step.text
	panel.visible = true

func advance_step():
	if step_complete: return
	step_complete = true
	panel.visible = false
	var next = current_step + 1
	if next < steps.size():
		show_step(next)

func _on_atom_collected(_symbol):
	if current_step == 2 and not atom_collected_once:
		atom_collected_once = true
		advance_step()

func notify_gate_opened():
	if current_step == 4:
		advance_step()
	gate_opened = true

func _on_dismiss_pressed():
	if steps[current_step].trigger == "tap":
		advance_step()
