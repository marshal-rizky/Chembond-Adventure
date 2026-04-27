extends Node2D

# maze_manager.gd (Complete 10-Level Edition)

@onready var tilemap: TileMapLayer = $TileMapLayer

# Layouts: 10 Unique, Solvable Labyrinths
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
	var ascii_rows = tutorial_layout.ascii
	tilemap.clear()
	for child in tilemap.get_children():
		child.queue_free()

	var floor_tiles = []
	var start_pos = Vector2i(1, 1)
	var exit_pos = Vector2i(1, 1)

	for y in range(ascii_rows.size()):
		var row = ascii_rows[y]
		for x in range(row.length()):
			var c = row[x]
			var coord = Vector2i(x, y)
			match c:
				"#":
					tilemap.set_cell(coord, 0, Vector2i(1, 0))
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
					tilemap.set_cell(coord, 0, Vector2i(0, 0))
					var floor_bg = ColorRect.new()
					floor_bg.size = Vector2(16, 16)
					floor_bg.position = Vector2(x * 16, y * 16)
					floor_bg.color = Color("#0f0f23") if (x + y) % 2 == 0 else Color("#121230")
					floor_bg.z_index = -1
					tilemap.add_child(floor_bg)
					if c == "S":
						start_pos = coord
						tilemap.set_cell(coord, 0, Vector2i(2, 0))
					elif c == "E":
						exit_pos = coord
						tilemap.set_cell(coord, 0, Vector2i(3, 0))

	print("Loaded tutorial maze")
	return {"walkable": floor_tiles, "start": start_pos, "exit": exit_pos, "name": tutorial_layout.name}

func load_legend_maze(index: int):
	if index < 0 or index >= legend_layouts.size():
		print("ERROR: Legend maze index out of bounds: ", index)
		return null

	var layout = legend_layouts[index]
	var ascii_rows = layout.ascii
	tilemap.clear()
	for child in tilemap.get_children():
		child.queue_free()

	var floor_tiles = []
	var start_left = Vector2i(0, 10)
	var start_right = Vector2i(29, 10)
	var exit_pos = Vector2i(14, 10)
	var found_starts = []

	for y in range(ascii_rows.size()):
		var row = ascii_rows[y]
		for x in range(row.length()):
			var c = row[x]
			var coord = Vector2i(x, y)
			match c:
				"#":
					tilemap.set_cell(coord, 0, Vector2i(1, 0))
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
					tilemap.set_cell(coord, 0, Vector2i(0, 0))
					var floor_bg = ColorRect.new()
					floor_bg.size = Vector2(16, 16)
					floor_bg.position = Vector2(x * 16, y * 16)
					floor_bg.color = Color("#0f0f23") if (x + y) % 2 == 0 else Color("#121230")
					floor_bg.z_index = -1
					tilemap.add_child(floor_bg)
					if c == "S":
						tilemap.set_cell(coord, 0, Vector2i(2, 0))
						found_starts.append(coord)
					elif c == "E":
						exit_pos = coord
						tilemap.set_cell(coord, 0, Vector2i(3, 0))

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
	if index < 0 or index >= layouts.size():
		print("ERROR: Maze index out of bounds: ", index)
		return null
		
	var layout = layouts[index]
	var ascii_rows = layout.ascii
	tilemap.clear()
	
	for child in tilemap.get_children():
		child.queue_free()
	
	var floor_tiles = []
	var start_pos = Vector2i(1, 1)
	var exit_pos = Vector2i(1, 1)
	
	for y in range(ascii_rows.size()):
		var row = ascii_rows[y]
		for x in range(row.length()):
			var c = row[x]
			var coord = Vector2i(x, y)
			
			match c:
				"#": # Wall
					tilemap.set_cell(coord, 0, Vector2i(1, 0))
					var wall_body = StaticBody2D.new()
					wall_body.position = Vector2(x * 16 + 8, y * 16 + 8)
					var col_shape = CollisionShape2D.new()
					var rect = RectangleShape2D.new()
					rect.size = Vector2(16, 16)
					col_shape.shape = rect
					wall_body.add_child(col_shape)
					tilemap.add_child(wall_body)
					
				".", "S", "E", "*": # Walkable
					floor_tiles.append(coord)
					tilemap.set_cell(coord, 0, Vector2i(0,0))
					
					# Checkerboard Pattern Logic
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
						start_pos = coord
						tilemap.set_cell(coord, 0, Vector2i(2, 0))
					elif c == "E": 
						exit_pos = coord
						tilemap.set_cell(coord, 0, Vector2i(3, 0))
			
	print("Loaded ASCII Maze: ", layout.name)
	return {
		"walkable": floor_tiles,
		"start": start_pos,
		"exit": exit_pos,
		"name": layout.name
	}

func get_validated_spawns(maze_data: Dictionary, required: Dictionary, decoy_count: int):
	var walkable = maze_data.walkable
	var start = maze_data.start
	var exit = maze_data.exit
	
	if not LevelGenerator.has_path(walkable, start, exit):
		print("ERROR: Maze not solvable!")
		return null
		
	var dist_from_start = LevelGenerator.get_bfs_distances(walkable, start)
	var dist_from_exit = LevelGenerator.get_bfs_distances(walkable, exit)
	
	var zone_b = []
	for tile in walkable:
		if dist_from_exit.get(tile, 999) <= 1: continue
		if dist_from_start.get(tile, 999) <= 1: continue
		zone_b.append(tile)
	
	var req_list = []
	for symbol in required:
		for i in range(required[symbol]): req_list.append(symbol)
	
	var max_elements = int(zone_b.size() * 0.4)
	if (req_list.size() + decoy_count) > max_elements:
		decoy_count = max_elements - req_list.size()
		
	var spawn_plan = {}
	var attempts = 0
	while attempts < 20:
		spawn_plan.clear()
		var required_tiles: Array = []
		var decoy_tiles: Array = []
		var occupied = [start, exit]
		var candidate_tiles = zone_b.duplicate()
		candidate_tiles.shuffle()

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
		var decoy_pool = []
		for symbol in required:
			decoy_pool.append(symbol)
		for extra in ["Cl", "Na", "Mg", "S", "K", "Ca", "N", "Si", "Fe", "Cu", "Zn", "H", "O", "C"]:
			if extra not in decoy_pool:
				decoy_pool.append(extra)

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
	var walkable = maze_data.walkable
	var start_left = maze_data.start
	var start_right = maze_data.start_right
	var exit = maze_data.exit

	var half_x = 15  # maze width 30, center col

	var left_tiles = walkable.filter(func(t): return t.x < half_x)
	var right_tiles = walkable.filter(func(t): return t.x >= half_x)

	var left_required = {}
	var right_required = {}
	for symbol in required:
		var count = required[symbol]
		left_required[symbol] = count / 2
		right_required[symbol] = count - (count / 2)

	var spawn_plan = {}

	var left_plan = _spawn_half(left_tiles, start_left, exit, left_required, decoy_count / 2)
	var right_plan = _spawn_half(right_tiles, start_right, exit, right_required, decoy_count - decoy_count / 2)

	if not left_plan or not right_plan:
		print("ERROR: Legend spawn generation failed")
		return null

	for pos in left_plan: spawn_plan[pos] = left_plan[pos]
	for pos in right_plan: spawn_plan[pos] = right_plan[pos]
	return spawn_plan

func _spawn_half(tiles: Array, spawn: Vector2i, exit: Vector2i, required: Dictionary, decoy_count: int):
	var req_list = []
	for symbol in required:
		for i in range(required[symbol]): req_list.append(symbol)

	var decoy_pool = ["Cl", "Na", "Mg", "S", "K", "Ca", "N", "Si", "Fe", "Cu", "Zn", "H", "O", "C", "P", "Al"]

	var spawn_plan = {}
	var attempts = 0
	while attempts < 20:
		spawn_plan.clear()
		var occupied = [spawn, exit]
		var candidates = tiles.duplicate()
		candidates.shuffle()

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
	for pos in occupied:
		if new_pos == pos: return false
	return true
