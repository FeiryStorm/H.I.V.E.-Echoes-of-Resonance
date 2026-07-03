## ⬢ hex_math.gd ⬢
## Static utility class for fast, high-performance hexagonal coordinate transformations.
## Acts as the single source of truth for all grid mathematics (O(1)).
extends RefCounted
class_name HexMath

## Converts a global pixel position to a Vector3i Cube coordinate (O(1)).
static func pixel_to_cube(p_pixel_pos: Vector2, p_radius: float, p_margin: float) -> Vector3i:
	var effective_radius: float = p_radius * p_margin
	
	var q: float = (sqrt(3.0) / 3.0 * p_pixel_pos.x - 1.0 / 3.0 * p_pixel_pos.y) / effective_radius
	var r: float = (2.0 / 3.0 * p_pixel_pos.y) / effective_radius
	var s: float = -q - r
	
	var rx: float = round(q)
	var ry: float = round(r)
	var rz: float = round(s)
	
	var x_diff: float = abs(rx - q)
	var y_diff: float = abs(ry - r)
	var z_diff: float = abs(rz - s)
	
	if x_diff > y_diff and x_diff > z_diff:
		rx = -ry - rz
	elif y_diff > z_diff:
		ry = -rx - rz
	else:
		rz = -rx - ry
		
	return Vector3i(int(rx), int(ry), int(rz))


## Converts a Vector3i Cube coordinate to a global 2D pixel position (O(1)).
static func cube_to_pixel(p_cube: Vector3i, p_radius: float, p_margin: float) -> Vector2:
	var effective_radius: float = p_radius * p_margin
	var x: float = effective_radius * (sqrt(3.0) * p_cube.x + sqrt(3.0) / 2.0 * p_cube.y)
	var y: float = effective_radius * (3.0 / 2.0 * p_cube.y)
	return Vector2(x, y)


## Calculates the Manhattan distance between two cube coordinates (O(1)).
static func cube_distance(p_a: Vector3i, p_b: Vector3i) -> int:
	return int((abs(p_a.x - p_b.x) + abs(p_a.y - p_b.y) + abs(p_a.z - p_b.z)) / 2.0)
