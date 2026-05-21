## ⬢ hex_math.gd ⬢
## Static utility class for fast pixel-to-hex transformations.
class_name HexMath

## Converts a global pixel position to a Vector3i Cube coordinate (O(1)).
static func pixel_to_cube(p_pixel_pos: Vector2, p_radius: float, p_margin: float) -> Vector3i:
	var effective_radius := p_radius * p_margin
	
	var q: float = (sqrt(3.0) / 3.0 * p_pixel_pos.x - 1.0 / 3.0 * p_pixel_pos.y) / effective_radius
	var r: float = (2.0 / 3.0 * p_pixel_pos.y) / effective_radius
	var s: float = -q - r
	
	# FIX: Explicit float type declarations instead of automated inference (:=)
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
