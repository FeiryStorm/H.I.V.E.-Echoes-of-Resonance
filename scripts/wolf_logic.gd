## ⬢ wolf_logic.gd ⬢
## Specialized Wolf capabilities including the complete Call of the Pack simulation.
extends GuardianLogic
class_name WolfLogic

func apply_passive() -> void:
	var regen: float = 6.0 
	var grid = cell.get_parent()
	var neighbors = grid.get_neighbors(cell.hex_data.cube_coords)
	
	for n_coords in neighbors:
		var n_cell = grid.get_cell_at(n_coords)
		if n_cell and n_cell.hex_data.current_owner == HexData.Owner.WOLF:
			regen += 0.5
	
	cell.hex_data.add_resonance(HexData.Owner.WOLF, min(regen, 9.0))
	cell._update_visuals()

func activate_ability() -> bool:
	if BeatManager.current_phase == BeatManager.GamePhase.ECHOING:
		print("⬢ Wolf | Ability rejected: Too late for defense!")
		return false
		
	if BeatManager.wolf_actions_this_round >= 3:
		print("⬢ Wolf | Ability rejected: Round limit reached!")
		return false

	var wolf_res = cell.hex_data.resonance[HexData.Owner.WOLF]
	if wolf_res >= 15.0:
		cell.hex_data.resonance[HexData.Owner.WOLF] -= 15.0
		cell.active_buffs["ThornWall"] = 3
		BeatManager.wolf_actions_this_round += 1
		cell._update_visuals()
		return true
	return false


## --- THE ULTIMATE CALL ---
func activate_ultimate() -> bool:
	if BeatManager.current_phase == BeatManager.GamePhase.ECHOING:
		print("⬢ Wolf | Ultimate rejected: Too late!")
		return false
		
	if BeatManager.wolf_ultimate_used_this_round:
		print("⬢ Wolf | Ultimate rejected: Already unleashed this round!")
		return false

	var wolf_res: float = cell.hex_data.resonance[HexData.Owner.WOLF]
	if wolf_res >= 50.0:
		cell.hex_data.resonance[HexData.Owner.WOLF] -= 50.0
		BeatManager.wolf_ultimate_used_this_round = true
		
		_emit_three_ring_shockwave()
		return true
	return false

## Emits the cascading 3-ring shockwave across the battlefield
func _emit_three_ring_shockwave() -> void:
	print("⬢ Wolf | CALL OF THE PACK: Cascading 3-Ring Shockwave initiated!")
	var grid = cell.get_parent()
	var center_coords: Vector3i = cell.hex_data.cube_coords
	
	for coords in grid.all_cells:
		var n_cell = grid.all_cells[coords]
		var diff: Vector3i = center_coords - coords
		var distance: int = int((abs(diff.x) + abs(diff.y) + abs(diff.z)) / 2)
		
		var energy_to_inject := 0.0
		var flash_delay := 0.0
		
		match distance:
			1:
				energy_to_inject = 33.0
				flash_delay = 0.0
			2:
				energy_to_inject = 22.0
				flash_delay = 0.15
			3:
				energy_to_inject = 11.0
				flash_delay = 0.3
			_:
				continue
				
		_execute_delayed_ripple(n_cell, energy_to_inject, flash_delay, grid, distance)

## Handles the delayed activation and fading per cell ring
func _execute_delayed_ripple(p_cell: Area2D, p_energy: float, p_delay: float, p_grid: Node2D, p_distance: int) -> void:
	if p_delay > 0:
		await p_cell.get_tree().create_timer(p_delay).timeout
		
	if is_instance_valid(p_cell):
		p_cell.hex_data.add_resonance(HexData.Owner.WOLF, p_energy)
		p_grid._calculate_dominance(p_cell)
		
		# FIX: Update visuals FIRST to apply color and labels...
		p_cell._update_visuals()
		
		# ...and THEN apply the radiant flash over it, so it doesn't get overridden!
		_flash_cell_resonance(p_cell, p_distance)

## Triggers a wave-graded radiant glow effect on a captured cell ⬢ - Graded Shockwave FX

func _flash_cell_resonance(p_cell: Area2D, p_distance: int) -> void:
	var base_border = p_cell.get_node_or_null("HexBorder") as Line2D
	var base_shape = p_cell.get_node_or_null("HexShape") as Polygon2D
	if not base_border or not base_shape: return
	
	# Determine initial explosion width and color boost based on distance
	var flash_width := 4.5
	var color_boost := 1.0
	
	match p_distance:
		1: 
			flash_width = 18.0 # Epicenter: Massive expansion
			color_boost = 1.4  # Slight over-brightness
		2: 
			flash_width = 12.0 # Wave peak
			color_boost = 1.2
		3: 
			flash_width = 7.0  # Ripple edge
			color_boost = 1.0

	# Apply initial shockwave state
	base_border.width = flash_width
	var original_color = base_border.default_color
	base_border.default_color = original_color * color_boost
	
	# Create a powerful, fast explosion feel with a smooth decay
	var tween := p_cell.create_tween().set_parallel(true)
	
	# Return border width back to standard (1.5 or 4.0 if hovered)
	var target_width: float = 4.0 if p_cell.is_hovered else 1.5
	tween.tween_property(base_border, "width", target_width, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(base_border, "default_color", original_color, 0.4)


