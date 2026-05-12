# tutorial_manager.gd
# Script yang ngatur alur tutorial langkah demi langkah — dari cara gerak,
# baca objective, collect element, sampai masuk gate. Tiap langkah punya
# trigger sendiri (gerak, tap OK, collect element, atau gate terbuka).
extends Node

# Index langkah tutorial yang lagi aktif sekarang
var current_step: int = 0
var step_complete: bool = false

# Referensi ke player dan exit gate buat deteksi event
var player: CharacterBody2D = null
var exit_gate: Node = null

# Referensi ke elemen UI tutorial yang di-build oleh main.gd
var panel: Panel = null
var panel_label: RichTextLabel = null
var dismiss_btn: Button = null
var step_dots_container: HBoxContainer = null

# Data level — element yang harus dikumpulkan dan semua pickup di maze
var required_elements: Dictionary = {}
var element_pickups: Array = []

# Flag buat cegah peringatan decoy muncul lebih dari sekali
var _showing_decoy_warning: bool = false

# Konstanta index langkah — lebih enak dibaca daripada angka langsung
const STEP_MOVE      = 0
const STEP_OBJECTIVE = 1
const STEP_COLLECT   = 2
const STEP_GATE      = 3
const STEP_REACH     = 4

# Definisi semua langkah tutorial — text, trigger, dan apakah perlu tombol dismiss
var steps = [
	{
		"text": "Use [b]WASD[/b] / arrows or the [b]joystick[/b] to move.",
		"trigger": "move",        # Auto-advance saat player mulai bergerak
		"show_dismiss": false
	},
	{
		"text": "Your [color=#5eead4][b]Objective[/b][/color] bar shows the molecule to form.",
		"trigger": "tap",         # Player harus tekan OK buat lanjut
		"show_dismiss": true
	},
	{
		"text": "[color=#5eead4]Glowing atoms[/color] are the ones you need.\n\nWalk over them to collect.",
		"trigger": "collect_required",  # Auto-advance saat collect element yang bener
		"show_dismiss": false
	},
	{
		"text": "Watch your [color=#5eead4][b]Inventory[/b][/color] fill up.\n\nThe gate opens when your atoms are an [b]exact match[/b].",
		"trigger": "gate_open",   # Auto-advance saat gate terbuka
		"show_dismiss": false
	},
	{
		"text": "Gate is open! Walk through it to escape.",
		"trigger": "tap",         # Player tekan OK, terus masuk gate
		"show_dismiss": true
	},
]

func setup(p: CharacterBody2D, gate: Node, required: Dictionary, pickups: Array):
	# Inisialisasi tutorial dengan data level yang sedang berjalan
	player = p
	exit_gate = gate
	required_elements = required
	element_pickups = pickups
	# Sambungin signal collect dari player buat deteksi langkah STEP_COLLECT
	player.collected_signal.connect(_on_atom_collected)
	# Mulai dari langkah pertama
	show_step(0)

func _physics_process(_delta):
	# Cek apakah player udah mulai gerak untuk trigger langkah pertama
	if not is_instance_valid(player): return
	if current_step == STEP_MOVE and not step_complete:
		if player.velocity.length() > 0.1:
			advance_step()

func show_step(index: int):
	# Tampilkan langkah tutorial berdasarkan index
	if index >= steps.size(): return
	# Kalau berpindah dari STEP_COLLECT, hapus highlight atom
	if current_step == STEP_COLLECT and index != STEP_COLLECT:
		_clear_atom_glow()
	current_step = index
	step_complete = false
	_showing_decoy_warning = false
	var step = steps[index]
	panel_label.text = step.text
	dismiss_btn.visible = step.show_dismiss
	panel.visible = true
	# Kalau masuk langkah collect, nyalakan highlight pada atom yang dibutuhkan
	if index == STEP_COLLECT:
		_apply_atom_glow()
	# Update visual dots progress di atas panel
	_update_step_dots()

func _update_step_dots():
	# Update warna titik-titik progress — teal kalau sudah lewat, gelap kalau belum
	if not step_dots_container: return
	var dots = step_dots_container.get_children()
	for i in range(dots.size()):
		if i <= current_step:
			dots[i].color = Color("#14b8a6")  # Sudah lewat — teal
		else:
			dots[i].color = Color("#1d3554")  # Belum — gelap

func advance_step():
	# Pindah ke langkah berikutnya — kasih feedback "Got it!" dulu baru lanjut
	if step_complete: return
	step_complete = true
	panel_label.text += "\n\n[color=#14b8a6]✓ Got it![/color]"
	# Tunggu bentar biar player sempat baca konfirmasi
	await get_tree().create_timer(0.8).timeout
	panel.visible = false
	var next = current_step + 1
	if next < steps.size():
		show_step(next)

func _on_atom_collected(symbol: String):
	# Dipanggil saat player collect element — hanya aktif di langkah STEP_COLLECT
	if current_step != STEP_COLLECT or step_complete: return
	if required_elements.has(symbol) and required_elements[symbol] > 0:
		# Element yang bener di-collect — lanjut ke langkah berikutnya
		advance_step()
	elif not _showing_decoy_warning:
		# Collect decoy — tampilkan peringatan sekali aja
		_showing_decoy_warning = true
		panel_label.text = "[color=#ef4444]⚠ That's a decoy![/color] Extra atoms keep the gate [b]locked[/b].\n\nPress [b]R[/b] or tap [b]Reset[/b] to try again."
		dismiss_btn.visible = false

func notify_gate_opened():
	# Dipanggil dari main.gd saat gate terbuka — trigger advance di langkah STEP_GATE
	if current_step == STEP_GATE and not step_complete:
		advance_step()

func _on_dismiss_pressed():
	# Tombol OK ditekan — advance step kalau trigger-nya adalah "tap"
	if steps[current_step].trigger == "tap" and not step_complete:
		advance_step()

func _apply_atom_glow():
	# Nyalakan highlight pada tiap pickup — yang required glow, yang decoy diredupkan
	for pickup in element_pickups:
		if not is_instance_valid(pickup): continue
		var is_req = required_elements.has(pickup.element_symbol) and required_elements[pickup.element_symbol] > 0
		pickup.set_tutorial_highlight(is_req)

func _clear_atom_glow():
	# Matikan semua efek highlight tutorial pada pickup — kembaliin ke tampilan normal
	for pickup in element_pickups:
		if not is_instance_valid(pickup): continue
		pickup.clear_tutorial_highlight()
