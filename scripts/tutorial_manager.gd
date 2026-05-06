extends Node

var current_step: int = 0
var step_complete: bool = false

var player: CharacterBody2D = null
var exit_gate: Node = null

var panel: Panel = null
var panel_label: RichTextLabel = null
var dismiss_btn: Button = null
var step_dots_container: HBoxContainer = null

var required_elements: Dictionary = {}
var element_pickups: Array = []
var _showing_decoy_warning: bool = false

const STEP_MOVE      = 0
const STEP_OBJECTIVE = 1
const STEP_COLLECT   = 2
const STEP_GATE      = 3
const STEP_REACH     = 4

var steps = [
	{
		"text": "Use [b]WASD[/b] / arrows or the [b]joystick[/b] to move.",
		"trigger": "move",
		"show_dismiss": false
	},
	{
		"text": "Your [color=#5eead4][b]Objective[/b][/color] bar shows the molecule to form.",
		"trigger": "tap",
		"show_dismiss": true
	},
	{
		"text": "[color=#5eead4]Glowing atoms[/color] are the ones you need.\n\nWalk over them to collect.",
		"trigger": "collect_required",
		"show_dismiss": false
	},
	{
		"text": "Watch your [color=#5eead4][b]Inventory[/b][/color] fill up.\n\nThe gate opens when your atoms are an [b]exact match[/b].",
		"trigger": "gate_open",
		"show_dismiss": false
	},
	{
		"text": "Gate is open! Walk through it to escape.",
		"trigger": "tap",
		"show_dismiss": true
	},
]

func setup(p: CharacterBody2D, gate: Node, required: Dictionary, pickups: Array):
	player = p
	exit_gate = gate
	required_elements = required
	element_pickups = pickups
	player.collected_signal.connect(_on_atom_collected)
	show_step(0)

func _physics_process(_delta):
	if not is_instance_valid(player): return
	if current_step == STEP_MOVE and not step_complete:
		if player.velocity.length() > 0.1:
			advance_step()

func show_step(index: int):
	if index >= steps.size(): return
	if current_step == STEP_COLLECT and index != STEP_COLLECT:
		_clear_atom_glow()
	current_step = index
	step_complete = false
	_showing_decoy_warning = false
	var step = steps[index]
	panel_label.text = step.text
	dismiss_btn.visible = step.show_dismiss
	panel.visible = true
	if index == STEP_COLLECT:
		_apply_atom_glow()
	_update_step_dots()

func _update_step_dots():
	if not step_dots_container: return
	var dots = step_dots_container.get_children()
	for i in range(dots.size()):
		if i <= current_step:
			dots[i].color = Color("#14b8a6")
		else:
			dots[i].color = Color("#1d3554")

func advance_step():
	if step_complete: return
	step_complete = true
	panel_label.text += "\n\n[color=#14b8a6]✓ Got it![/color]"
	await get_tree().create_timer(0.8).timeout
	panel.visible = false
	var next = current_step + 1
	if next < steps.size():
		show_step(next)

func _on_atom_collected(symbol: String):
	if current_step != STEP_COLLECT or step_complete: return
	if required_elements.has(symbol) and required_elements[symbol] > 0:
		advance_step()
	elif not _showing_decoy_warning:
		_showing_decoy_warning = true
		panel_label.text = "[color=#ef4444]⚠ That's a decoy![/color] Extra atoms keep the gate [b]locked[/b].\n\nPress [b]R[/b] or tap [b]Reset[/b] to try again."
		dismiss_btn.visible = false

func notify_gate_opened():
	if current_step == STEP_GATE and not step_complete:
		advance_step()

func _on_dismiss_pressed():
	if steps[current_step].trigger == "tap" and not step_complete:
		advance_step()

func _apply_atom_glow():
	for pickup in element_pickups:
		if not is_instance_valid(pickup): continue
		var is_req = required_elements.has(pickup.element_symbol) and required_elements[pickup.element_symbol] > 0
		pickup.set_tutorial_highlight(is_req)

func _clear_atom_glow():
	for pickup in element_pickups:
		if not is_instance_valid(pickup): continue
		pickup.clear_tutorial_highlight()
