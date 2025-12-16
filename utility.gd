extends Node
# Lerp between two cube coordinates
func cube_lerp(a: Vector3i, b: Vector3i, t: float) -> Vector3:
	return Vector3(
		lerp(a.x, b.x, t),
		lerp(a.y, b.y, t),
		lerp(a.z, b.z, t)
	)

# Round floating-point cube coords to nearest hex
func cube_round(c: Vector3) -> Vector3i:
	var rx = round(c.x)
	var ry = round(c.y)
	var rz = round(c.z)

	var x_diff = abs(rx - c.x)
	var y_diff = abs(ry - c.y)
	var z_diff = abs(rz - c.z)

	if x_diff > y_diff and x_diff > z_diff:
		rx = -ry - rz
	elif y_diff > z_diff:
		ry = -rx - rz
	else:
		rz = -rx - ry

	return Vector3i(rx, ry, rz)

# Line between two hexes (offset coordinates)
func get_line_points(a: Vector2i, b: Vector2i, is_odd_r := true) -> Array:
	var ac = hex_offset_to_cube(a, is_odd_r)
	var bc = hex_offset_to_cube(b, is_odd_r)

	var N = hex_cube_distance(ac, bc)
	var results: Array = []

	for i in range(N + 1):
		var t = float(i) / float(max(N, 1))
		var cube = cube_round(cube_lerp(ac, bc, t))
		# Convert back to offset
		var col = cube.x
		var row = cube.z + int((cube.x - (cube.x & 1 if is_odd_r else (1 - cube.x & 1))) / 2)
		results.append(Vector2i(col, row))

	return results

func pairs(list: Array) -> Array:
	var result: Array = []
	for i in list.size():
		for j in range(i + 1, list.size()):
			result.append([list[i], list[j]])
	return result

# Convert Godot TileMap hex coordinate (offset) to cube coordinate
func hex_offset_to_cube(hex: Vector2i, is_odd_r := true) -> Vector3i:
	var col = hex.x
	var row = hex.y

	var x = col
	var z = row - (col - (col & 1 if is_odd_r else (1 - col & 1))) / 2
	var y = -x - z

	return Vector3i(x, y, z)

# Cube distance between two cube coords
func hex_cube_distance(a: Vector3i, b: Vector3i) -> int:
	return max(abs(a.x - b.x), abs(a.y - b.y), abs(a.z - b.z))

# Full hex distance using offset coords (what YOU want)
func hex_distance(a: Vector2i, b: Vector2i, is_odd_r := true) -> int:
	var ac = hex_offset_to_cube(a, is_odd_r)
	var bc = hex_offset_to_cube(b, is_odd_r)
	return hex_cube_distance(ac, bc)
