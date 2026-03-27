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

func is_spacing_valid(new_pos: Vector2i, occupied: Array) -> bool:
	for pos in occupied:
		if new_pos == pos: return false
	return true
