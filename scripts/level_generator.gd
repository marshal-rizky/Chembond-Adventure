extends Node
class_name LevelGenerator

# level_generator.gd: Helper for pathfinding and validation

# Returns a dictionary of {Vector2i: int} representing distances from the start
static func get_bfs_distances(walkable: Array, start: Vector2i) -> Dictionary:
	var distances = {}
	var queue = [start]
	distances[start] = 0
	
	var head = 0
	while head < queue.size():
		var curr = queue[head]
		head += 1
		
		for dir in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
			var neighbor = curr + dir
			if neighbor in walkable and not neighbor in distances:
				distances[neighbor] = distances[curr] + 1
				queue.append(neighbor)
	return distances

# Returns true if a path exists between start and end while avoiding blocked tiles
static func has_path(walkable: Array, start: Vector2i, end: Vector2i, blocked: Array = []) -> bool:
	if start == end: return true
	var visited = {}
	for b in blocked: visited[b] = true
	
	var queue = [start]
	visited[start] = true
	
	var head = 0
	while head < queue.size():
		var curr = queue[head]
		head += 1
		
		if curr == end: return true
		
		for dir in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
			var neighbor = curr + dir
			if neighbor in walkable and not neighbor in visited:
				visited[neighbor] = true
				queue.append(neighbor)
	return false

# Returns true if a path exists that visits ALL waypoints in order while avoiding blocked
static func has_sequential_path(walkable: Array, points: Array, blocked: Array = []) -> bool:
	for i in range(points.size() - 1):
		if not has_path(walkable, points[i], points[i+1], blocked):
			return false
	return true
