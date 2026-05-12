# maze_manager.gd
# Script yang ngatur semua maze — dari definisi layout ASCII sampai nge-build tile map-nya
# di runtime, plus validasi spawn posisi element biar maze tetap bisa diselesaikan.
extends Node2D

# maze_manager.gd (Complete 10-Level Edition)

# TileMapLayer yang jadi tempat semua tile dan collision wall dipasang
@onready var tilemap: TileMapLayer = $TileMapLayer

# Layouts: 10 Unique, Solvable Labyrinths
# Semua maze didefinisikan sebagai string ASCII 20x15:
# '#' = dinding, '.' = lantai, 'S' = start, 'E' = exit
var layouts = [
	{ "name": "L1: Water (H2O)", "ascii": [
		"####################", "#S.#...#.....#.....#", "#..#.#.#.###.#.###.#", "#.##.#...#.#...#.#.#", "#....###.#.#.###.#.#", "#.##.....#.#.....#.#", "#....###.#.#.###.#.#", "#.##.#.#.#.#.#.#.#.#", "#....#.#.#.#.#.#.#.#", "#.####.#...#.#.#...#", "#......###.#.#.###.#", "#.####.....#.#.....#", "#......###.#.#.###.#", "#.########.#.....#E#", "####################"
	]},
	{ "name": "L2: Carbon Dioxide (CO2)", "ascii": [
		"####################", "#S.#.....#.....#...#", "#..#.###.#.###.#.#.#", "#.##.#...#.#...#.#.#", "#....#.###.#.###.#.#", "#.####.....#.....#.#", "#......###.#.###.#.#", "#.####.#...#...#.#.#", "#.#....#.#####.#.#.#", "#.#.####.......#.#.#", "#.#....#.#####.#.#.#", "#.####.#.#.....#...#", "#......#.#.#####.#.#", "#.######.#.......#E#", "####################"
	]},
	{ "name": "L3: Methane (CH4)", "ascii": [
		"####################", "#S.......#.........#", "#.##.#.#.#.#.##.##.#", "#..#.#.#...#..#..#.#", "#..#.#.###.##.#..#.#", "#.##.#.....#..#.##.#", "#....###.#.#..#....#", "##.#...#.#.#.##.##.#", "#..#.#.#.#......#..#", "#.##.#.#.####.#.#..#", "#....#.#.....#.#.#.#", "#.####.#.###.#.#.#.#", "#......#.#...#.#...#", "#.####.#.#.###.###E#", "####################"
	]},
	{ "name": "L4: Table Salt (NaCl)", "ascii": [
		"####################", "#S.#.#.........#...#", "#..#.#.#######.#.#.#", "#.##...#.....#...#.#", "#....###.###.#####.#", "#.##.....#.#.......#", "#..#.#####.###.###.#", "#..#.#.........#.#.#", "#.##.#.###.###.#.#.#", "#....#.#.....#.#.#.#", "#.####.#.###.#.#.#.#", "#.#....#...#...#...#", "#.#.##.###.#######.#", "#.#..#...........#E#", "####################"
	]},
	{ "name": "L5: Sulfuric Acid (H2SO4)", "ascii": [
		"####################", "#S.......#.......#.#", "#.##.#.#.#.#.##.##.#", "#..#.#.#...#..#....#", "#..#.#.###.##.#.##.#", "#.##.#.....#..#..#.#", "#....###.#.#.##..#.#", "#.##...#.#.#....##.#", "#..#.#.#.#.#.##..#.#", "#.##.#.#.####..#.#.#", "#....#.#.....#.#...#", "#.####.#.###.#.#.#.#", "#......#.#...#...#.#", "#.####.#.#.###.###E#", "####################"
	]},
	{ "name": "L6: Sodium Hydroxide (NaOH)", "ascii": [
		"####################", "#S.#.......#.....#.#", "#..#.#.#.#.#.#.#.#.#", "#.##.#.#.#.#.#.#...#", "#....#.#.#...#.###.#", "#.##.#.#.###.#...#.#", "#..#.#.#...#.###.#.#", "#.##.#.###.#.....#.#", "#....#.....#.###.#.#", "#.##.###.#.#.#.#...#", "#..#...#.#.#.#.#.#.#", "#.####.#.#.#.#.#.#.#", "#......#.#...#...#.#", "#.####.#.#.###.###E#", "####################"
	]},
	{ "name": "L7: Ammonium Chloride (NH4Cl)", "ascii": [
		"####################", "#S...#.......#.....#", "#.##.###.###.#.###.#", "#..#.....#.....#...#", "#.##.#.###.###.#.#.#", "#....#.#.....#.#.#.#", "#.####.#.###.#.#.#.#", "#......#.#...#...#.#", "#.####.#.#.####.##.#", "#.#..#.#.#.....#...#", "#.#..#.#.#####.#.#.#", "#.#..#.#.......#.#.#", "#.#..#.#.#######.#.#", "#.#..#...........#E#", "####################"
	]},
	{ "name": "L8: Calcium Hydroxide (Ca(OH)2)", "ascii": [
		"####################", "#S.#.......#...#...#", "#..#.#.###.#.#.#.#.#", "#.##.#.#.#.#.#...#.#", "#....#.#.#.#.###.#.#", "#.##.#.#.#.#...#.#.#", "#..#.#.#.#.#.#.#.#.#", "#..#.#...#.#.#.#.#.#", "#.##.###.#.#.#.#...#", "#........#...#.###.#", "#.##.#.#####.#...#.#", "#..#.#.......###.#.#", "#.##.###.###.....#.#", "#........#...###.#E#", "####################"
	]},
	{ "name": "L9: Sodium Carbonate (Na2CO3)", "ascii": [
		"####################", "#S.#...#...#...#...#", "#..#.#.#.#.#.#.#.#.#", "#.##.#...#...#...#.#", "#....#.#.###.###.#.#", "#.##.#.#.#.....#.#.#", "#..#.#.#.#.###.#.#.#", "#.##.#.#.#.#.#.#...#", "#....#.#.#.#.#.###.#", "#.####.#.#.#.#...#.#", "#......#.#.#.#.#.#.#", "#.####.#...#...#.#.#", "#......#.###.###.#.#", "#.######.........#E#", "####################"
	]},
	{ "name": "L10: Acetic Acid (CH3COOH)", "ascii": [
		"####################", "#S.......#.......#.#", "#.#.###..#..###.##.#", "#.#.#..#.#.#..#....#", "#.#.#..#.#.#..#.##.#", "#.#....#.#....#..#.#", "#.#.##.#.#.##.#..#.#", "#.#..#.#.#..#.#.##.#", "#.##.#.#.##.#.#....#", "#....#.#....#.#.##.#", "#.#..#.#.#..#.#..#.#", "#.#.##.#.#.##.#..#.#", "#.#....#.#....#.##.#", "#.###..#.#..###...E#", "####################"
	]}
]

# Layout khusus untuk mode tutorial — lebih simpel biar mudah dipahami
var tutorial_layout = {
	"name": "Tutorial: Water (H2O)",
	"ascii": [
		"####################",
		"#S.#.....#.....#...#",
		"#.#.###.#.###.#.##.#",
		"#.#...#...#...#....#",
		"#.###.###.#.###.##.#",
		"#.....#...#.#...#..#",
		"#.###.#.###.#.#.#.##",
		"#.#...#.....#.#.#..#",
		"#.#.#######.#.#.##.#",
		"#...#.......#.#....#",
		"#.###.#######.#.##.#",
		"#.#...#.......#....#",
		"#.#.###.#######.##.#",
		"#.......#.........E#",
		"####################"
	]
}

# Layout khusus mode Legend — maze lebih besar (30x20), ada dua start point
var legend_layouts = [
	{ "name": "Legend I: Glucose (C6H12O6)", "ascii": [
		"##############################",
		"#....#......#....#.....#....#",
		"#.##.#.####.#.##.#.###.#.##.#",
		"#..#...#..#...#.....#..#..#.#",
		"##.#.###..####.#.####..####.#",
		"#..#.#....#....#.#.....#....#",
		"#.##.#.##.#.###.#.###.##.##.#",
		"#....#..#.#...#.#...#..#..#.#",
		"#.####.##.###.#.#.#.####.#..#",
		"#....#....#...#.#.#......#..#",
		"#S...#.##.E...#...#.##...#.S#",
		"#.##.#..#.#.###.###..##.##..#",
		"#..#.##.#.#...#.#..#..#..#..#",
		"#..#...#..###.#.#.##.##..#.##",
		"#.###.##....#.#.#....#...#..#",
		"#...#..#.##.#.#.####.#.###..#",
		"#.#.##.#..#.#.#....#.#.#.##.#",
		"#.#....##.#...####.#...#...#.#",
		"#.######..#........#.####..#.#",
		"##############################"
	]},
	{ "name": "Legend II: Calcium Phosphate (Ca3(PO4)2)", "ascii": [
		"##############################",
		"#..#....#...#..#...#.....#..#",
		"#.##.##.#.#.##.#.#.#.###.#.##",
		"#....#..#.#....#.#.#.#...#..#",
		"####.#.##.#.####.#.#.#.####.#",
		"#....#..#.#.#....#.#.#......#",
		"#.####.##.#.#.##.#.#.######.#",
		"#.#....#..#.#..#.#.#.#......#",
		"#.#.##.####.##.#.###.#.#####.",
		"#...#.......#..#.....#......#",
		"#S..#..####.E..#.###.#...#..S",
		"#.###..#..#.#.##...#.##.##..#",
		"#....#.#..#.#....#.#....#...#",
		"####.#.####.####.#.#.##.#.###",
		"#....#......#....#.#..#.#...#",
		"#.##.######.#.##.#.##.#.###.#",
		"#..#.#......#..#.#....#.#...#",
		"##.#.#.######.##.#.####.#.###",
		"#..#.........#...#......#...#",
		"##############################"
	]},
	{ "name": "Legend III: Aluminum Sulfate (Al2(SO4)3)", "ascii": [
		"##############################",
		"#.#...#....#....#...#.....#.#",
		"#.#.#.#.##.#.##.#.#.#.###.#.#",
		"#...#....#.#..#...#...#...#.#",
		"#.####.###.##.#.###.###.###.#",
		"#.#....#...#..#.#...#...#...#",
		"#.#.####.#.#.##.#.###.#####.#",
		"#.#.#....#.#..#.#.#...#.....#",
		"#...#.####.##.#.#.#.###.####.",
		"#.###....#....#.#.#...#.....#",
		"#S..####.E....#.#.#.###.###.S",
		"#.#.#....#.####.#.#.#...#...#",
		"#.#.#.##.#.#....#.#.#.###.#.#",
		"#.#...#..#.#.##.#.#.#.#...#.#",
		"#.#.###..#.#..#.###.#.#.###.#",
		"#.#.#....#.##.#.....#.#.....#",
		"#.#.#.####..#.#.#####.#####.#",
		"#...#......#..#.#.....#.....#",
		"#.########.####.#.#########.#",
		"##############################"
	]}
]

func load_tutorial_maze():
	# Load maze tutorial — lebih simpel dari maze normal, dipakai saat mode tutorial aktif
	var ascii_rows = tutorial_layout.ascii
	tilemap.clear()
	for child in tilemap.get_children():
		child.queue_free()

	var floor_tiles = []
	var start_pos = Vector2i(1, 1)
	var exit_pos = Vector2i(1, 1)

	# Iterasi tiap karakter di ASCII layout, bangun tile dan collision-nya
	for y in range(ascii_rows.size()):
		var row = ascii_rows[y]
		for x in range(row.length()):
			var c = row[x]
			var coord = Vector2i(x, y)
			match c:
				"#":
					# Dinding — set tile dan tambah StaticBody2D buat collision
					tilemap.set_cell(coord, 0, Vector2i(0, 3))
					var wall_body = StaticBody2D.new()
					wall_body.position = Vector2(x * 16 + 8, y * 16 + 8)
					var col_shape = CollisionShape2D.new()
					var rect = RectangleShape2D.new()
					rect.size = Vector2(16, 16)
					col_shape.shape = rect
					wall_body.add_child(col_shape)
					tilemap.add_child(wall_body)
				".", "S", "E":
					# Lantai yang bisa dilewati — checkerboard dua warna gelap
					floor_tiles.append(coord)
					tilemap.set_cell(coord, 0, Vector2i(2, 1))
					var floor_bg = ColorRect.new()
					floor_bg.size = Vector2(16, 16)
					floor_bg.position = Vector2(x * 16, y * 16)
					floor_bg.color = Color("#0f0f23") if (x + y) % 2 == 0 else Color("#121230")
					floor_bg.z_index = -1
					tilemap.add_child(floor_bg)
					if c == "S":
						start_pos = coord
						tilemap.set_cell(coord, 0, Vector2i(2, 1))
					elif c == "E":
						exit_pos = coord
						tilemap.set_cell(coord, 0, Vector2i(2, 1))

	print("Loaded tutorial maze")
	return {"walkable": floor_tiles, "start": start_pos, "exit": exit_pos, "name": tutorial_layout.name}

func load_legend_maze(index: int):
	# Load maze untuk mode legend — maze lebih besar, ada dua start point (kiri dan kanan)
	if index < 0 or index >= legend_layouts.size():
		print("ERROR: Legend maze index out of bounds: ", index)
		return null

	var layout = legend_layouts[index]
	var ascii_rows = layout.ascii
	tilemap.clear()
	for child in tilemap.get_children():
		child.queue_free()

	var floor_tiles = []
	# Default fallback kalau 'S' gak ketemu
	var start_left = Vector2i(0, 10)
	var start_right = Vector2i(29, 10)
	var exit_pos = Vector2i(14, 10)
	var found_starts = []

	# Parse ASCII layout — sama seperti load_maze tapi cari dua titik 'S'
	for y in range(ascii_rows.size()):
		var row = ascii_rows[y]
		for x in range(row.length()):
			var c = row[x]
			var coord = Vector2i(x, y)
			match c:
				"#":
					tilemap.set_cell(coord, 0, Vector2i(0, 3))
					var wall_body = StaticBody2D.new()
					wall_body.position = Vector2(x * 16 + 8, y * 16 + 8)
					var col_shape = CollisionShape2D.new()
					var rect = RectangleShape2D.new()
					rect.size = Vector2(16, 16)
					col_shape.shape = rect
					wall_body.add_child(col_shape)
					tilemap.add_child(wall_body)
				".", "S", "E":
					floor_tiles.append(coord)
					tilemap.set_cell(coord, 0, Vector2i(2, 1))
					var floor_bg = ColorRect.new()
					floor_bg.size = Vector2(16, 16)
					floor_bg.position = Vector2(x * 16, y * 16)
					floor_bg.color = Color("#0f0f23") if (x + y) % 2 == 0 else Color("#121230")
					floor_bg.z_index = -1
					tilemap.add_child(floor_bg)
					if c == "S":
						tilemap.set_cell(coord, 0, Vector2i(2, 1))
						found_starts.append(coord)
					elif c == "E":
						exit_pos = coord
						tilemap.set_cell(coord, 0, Vector2i(2, 1))

	# Tentukan mana start kiri dan kanan berdasarkan posisi X
	if found_starts.size() >= 2:
		if found_starts[0].x < found_starts[1].x:
			start_left = found_starts[0]
			start_right = found_starts[1]
		else:
			start_left = found_starts[1]
			start_right = found_starts[0]

	print("Loaded legend maze: ", layout.name)
	return {
		"walkable": floor_tiles,
		"start": start_left,
		"start_right": start_right,
		"exit": exit_pos,
		"name": layout.name
	}

func load_maze(index: int):
	# Load maze normal berdasarkan index (0-9) — parse ASCII dan build tilemap
	if index < 0 or index >= layouts.size():
		print("ERROR: Maze index out of bounds: ", index)
		return null

	var layout = layouts[index]
	var ascii_rows = layout.ascii
	tilemap.clear()

	# Bersihkan semua child lama (StaticBody collision, ColorRect floor, dll)
	for child in tilemap.get_children():
		child.queue_free()

	var floor_tiles = []
	var start_pos = Vector2i(1, 1)
	var exit_pos = Vector2i(1, 1)

	# Loop tiap baris dan kolom ASCII untuk bikin tile yang sesuai
	for y in range(ascii_rows.size()):
		var row = ascii_rows[y]
		for x in range(row.length()):
			var c = row[x]
			var coord = Vector2i(x, y)

			match c:
				"#": # Wall
					# Set tile dinding dan tambahkan collision body
					tilemap.set_cell(coord, 0, Vector2i(0, 3))
					var wall_body = StaticBody2D.new()
					wall_body.position = Vector2(x * 16 + 8, y * 16 + 8)
					var col_shape = CollisionShape2D.new()
					var rect = RectangleShape2D.new()
					rect.size = Vector2(16, 16)
					col_shape.shape = rect
					wall_body.add_child(col_shape)
					tilemap.add_child(wall_body)

				".", "S", "E", "*": # Walkable
					# Lantai bisa dilewati — masukkan ke floor_tiles buat validasi spawn
					floor_tiles.append(coord)
					tilemap.set_cell(coord, 0, Vector2i(2, 1))

					# Checkerboard Pattern Logic — dua warna gelap selang-seling
					var floor_bg = ColorRect.new()
					floor_bg.size = Vector2(16, 16)
					floor_bg.position = Vector2(x * 16, y * 16)
					if (x + y) % 2 == 0:
						floor_bg.color = Color("#0f0f23")
					else:
						floor_bg.color = Color("#121230")
					floor_bg.z_index = -1 # Always behind
					tilemap.add_child(floor_bg)

					if c == "S":
						# Simpan posisi start player
						start_pos = coord
						tilemap.set_cell(coord, 0, Vector2i(2, 1))
					elif c == "E":
						# Simpan posisi exit gate
						exit_pos = coord
						tilemap.set_cell(coord, 0, Vector2i(2, 1))

	print("Loaded ASCII Maze: ", layout.name)
	return {
		"walkable": floor_tiles,
		"start": start_pos,
		"exit": exit_pos,
		"name": layout.name
	}

func get_validated_spawns(maze_data: Dictionary, required: Dictionary, decoy_count: int):
	# Fungsi utama buat nentuin di mana element bakal di-spawn —
	# pastiin semua required element bisa dicapai, dan decoy gak nutup jalan
	var walkable = maze_data.walkable
	var start = maze_data.start
	var exit = maze_data.exit

	# Cek dulu apakah ada path dari start ke exit (maze valid)
	if not LevelGenerator.has_path(walkable, start, exit):
		print("ERROR: Maze not solvable!")
		return null

	# Hitung jarak dari start dan exit ke semua tile dengan BFS
	var dist_from_start = LevelGenerator.get_bfs_distances(walkable, start)
	var dist_from_exit = LevelGenerator.get_bfs_distances(walkable, exit)

	# Zone B = tile yang jauh dari start DAN exit — zona aman buat spawn element
	var zone_b = []
	for tile in walkable:
		if dist_from_exit.get(tile, 999) <= 1: continue
		if dist_from_start.get(tile, 999) <= 1: continue
		zone_b.append(tile)

	# Ubah dict required jadi list flat, contoh: {H:2, O:1} → [H, H, O]
	var req_list = []
	for symbol in required:
		for i in range(required[symbol]): req_list.append(symbol)

	# Batasi total element maksimal 40% dari zone_b biar gak terlalu penuh
	var max_elements = int(zone_b.size() * 0.4)
	if (req_list.size() + decoy_count) > max_elements:
		decoy_count = max_elements - req_list.size()

	# Coba generate spawn plan maksimal 20 kali
	var spawn_plan = {}
	var attempts = 0
	while attempts < 20:
		spawn_plan.clear()
		var required_tiles: Array = []
		var decoy_tiles: Array = []
		var occupied = [start, exit]
		var candidate_tiles = zone_b.duplicate()
		candidate_tiles.shuffle()

		# Tempatkan dulu semua required element dengan spacing yang valid
		var success = true
		for symbol in req_list:
			var found = false
			for i in range(candidate_tiles.size()):
				var tile = candidate_tiles[i]
				if is_spacing_valid(tile, occupied):
					spawn_plan[tile] = symbol
					occupied.append(tile)
					required_tiles.append(tile)
					candidate_tiles.remove_at(i)
					found = true
					break
			if not found: success = false; break

		if not success: attempts += 1; continue

		# Build deceptive decoy pool: includes required elements (extra pickups = lockout)
		# Decoy pool campuran — termasuk simbol yang sama dengan required biar player bingung
		var decoy_pool = []
		for symbol in required:
			decoy_pool.append(symbol)
		for extra in ["Cl", "Na", "Mg", "S", "K", "Ca", "N", "Si", "Fe", "Cu", "Zn", "H", "O", "C"]:
			if extra not in decoy_pool:
				decoy_pool.append(extra)

		# Tempatkan decoy — hanya kalau gak nutup path ke required atau exit
		var decoys_placed = 0
		for d in range(decoy_count):
			var placed = false
			for i in range(candidate_tiles.size()):
				var tile = candidate_tiles[i]
				if is_spacing_valid(tile, occupied):
					if LevelGenerator.has_path(walkable, start, exit, [tile]):
						spawn_plan[tile] = decoy_pool[randi() % decoy_pool.size()]
						occupied.append(tile)
						decoy_tiles.append(tile)
						candidate_tiles.remove_at(i)
						decoys_placed += 1
						placed = true
						break
			if not placed:
				break

		var req_pos = required_tiles
		var decoy_pos = decoy_tiles

		# Verifikasi terakhir: semua required element bisa dicapai dari start DAN bisa ke exit
		var all_req_reachable = true
		for rp in req_pos:
			if not LevelGenerator.has_path(walkable, start, rp, decoy_pos):
				all_req_reachable = false; break
			if not LevelGenerator.has_path(walkable, rp, exit, decoy_pos):
				all_req_reachable = false; break

		if all_req_reachable:
			print("Generation Success! (", req_pos.size(), " required, ", decoy_pos.size(), " decoys)")
			return spawn_plan

		attempts += 1

	print("ERROR: Generation failed after 20 attempts")
	return null

func get_legend_spawns(maze_data: Dictionary, required: Dictionary, decoy_count: int):
	# Khusus mode legend — split maze jadi kiri/kanan, tiap player ngurus setengah element
	var walkable = maze_data.walkable
	var start_left = maze_data.start
	var start_right = maze_data.start_right
	var exit = maze_data.exit

	var half_x = 15  # maze width 30, center col

	# Pisahin tile berdasarkan setengah kiri dan kanan maze
	var left_tiles = walkable.filter(func(t): return t.x < half_x)
	var right_tiles = walkable.filter(func(t): return t.x >= half_x)

	# Bagi required element antara dua sisi — sisi kanan dapat sisa kalau jumlahnya ganjil
	var left_required = {}
	var right_required = {}
	for symbol in required:
		var count = required[symbol]
		left_required[symbol] = count / 2
		right_required[symbol] = count - (count / 2)

	var spawn_plan = {}

	# Jalankan spawn generation untuk masing-masing sisi
	var left_plan = _spawn_half(left_tiles, start_left, exit, left_required, decoy_count / 2)
	var right_plan = _spawn_half(right_tiles, start_right, exit, right_required, decoy_count - decoy_count / 2)

	if not left_plan or not right_plan:
		print("ERROR: Legend spawn generation failed")
		return null

	# Gabungin dua spawn plan jadi satu
	for pos in left_plan: spawn_plan[pos] = left_plan[pos]
	for pos in right_plan: spawn_plan[pos] = right_plan[pos]
	return spawn_plan

func _spawn_half(tiles: Array, spawn: Vector2i, exit: Vector2i, required: Dictionary, decoy_count: int):
	# Helper buat spawn di setengah maze — dipanggil dua kali di get_legend_spawns
	var req_list = []
	for symbol in required:
		for i in range(required[symbol]): req_list.append(symbol)

	# Pool decoy khusus legend — ada P dan Al untuk molekul kompleks
	var decoy_pool = ["Cl", "Na", "Mg", "S", "K", "Ca", "N", "Si", "Fe", "Cu", "Zn", "H", "O", "C", "P", "Al"]

	var spawn_plan = {}
	var attempts = 0
	while attempts < 20:
		spawn_plan.clear()
		var occupied = [spawn, exit]
		var candidates = tiles.duplicate()
		candidates.shuffle()

		# Tempatkan required element dulu
		var success = true
		for symbol in req_list:
			var found = false
			for i in range(candidates.size()):
				var tile = candidates[i]
				if is_spacing_valid(tile, occupied):
					spawn_plan[tile] = symbol
					occupied.append(tile)
					candidates.remove_at(i)
					found = true
					break
			if not found:
				success = false
				break
		if not success:
			attempts += 1
			continue

		# Tambahin decoy secara random dari decoy_pool
		for _d in range(decoy_count):
			for i in range(candidates.size()):
				var tile = candidates[i]
				if is_spacing_valid(tile, occupied):
					spawn_plan[tile] = decoy_pool[randi() % decoy_pool.size()]
					occupied.append(tile)
					candidates.remove_at(i)
					break

		return spawn_plan

	return null

func is_spacing_valid(new_pos: Vector2i, occupied: Array) -> bool:
	# Ngecek apakah tile baru gak menumpuk dengan tile yang sudah terpakai
	for pos in occupied:
		if new_pos == pos: return false
	return true
