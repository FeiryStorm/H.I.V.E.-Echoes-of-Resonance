## ⬢ wolf_logic.gd ⬢
## Specialized Wolf tactical controller implementing pack-regeneration, ThornWall, and shockwaves.
## Inherits from RefCounted for memory safety.
extends GuardianLogic
class_name WolfLogic

# --- CORE INTERACTION HOOKS ---

## Custom turn-based pack-regeneration calculation.
func process_regeneration() -> void:
	if not cell or not cell.hex_data or not res: return
	
	# 1. Base regeneration from GuardianResource
	var regen: float = res.base_regeneration + 3.0 # Pack bonus baseline: 6.0
	
	var grid: HexGrid = cell.get_parent() as HexGrid
	if grid:
		var neighbors: Array[Vector3i] = grid.get_neighbors(cell.hex_data.cube_coords)
		
		# 2. Add local pack bonus (+0.5 energy per neighboring Wolf cell)
		for n_coords: Vector3i in neighbors:
			var n_cell: Area2D = grid.get_cell_at(n_coords)
			if n_cell and n_cell.hex_data.current_owner == int(HexData.Owner.WOLF):
				regen += 0.5
				
	# 3. Inject directly, capped at maximum threshold (9.0)
	cell.hex_data.add_resonance(int(HexData.Owner.WOLF), min(regen, 9.0))

## Triggers the active defensive ThornWall ability.
func activate_ability() -> bool:
	if BeatManager.current_phase == BeatManager.GamePhase.ECHOING: 
		return false
		
	# Check action point restrictions dynamically
	var current_actions: int = BeatManager.get_action_count(int(HexData.Owner.WOLF))
	if current_actions >= res.active_max_uses_per_round: 
		return false

	var wolf_res: float = cell.hex_data.resonance[int(HexData.Owner.WOLF)]
	
	# Uses cost and duration parameters directly from the resource configuration
	if wolf_res >= res.active_cost:
		cell.hex_data.resonance[int(HexData.Owner.WOLF)] -= res.active_cost
		cell.active_buffs["ThornWall"] = res.active_duration_pulses
		
		BeatManager.register_action(int(HexData.Owner.WOLF))
		cell._update_visuals()
		return true
		
	return false

## Triggers the concentric shockwave ultimate.
func activate_ultimate() -> bool:
	if BeatManager.current_phase == BeatManager.GamePhase.ECHOING: 
		return false
		
	if BeatManager.is_ultimate_used(int(HexData.Owner.WOLF)): 
		return false
		
	var wolf_res: float = cell.hex_data.resonance[int(HexData.Owner.WOLF)]
	
	if wolf_res >= res.ulti_cost:
		cell.hex_data.resonance[int(HexData.Owner.WOLF)] -= res.ulti_cost
		BeatManager.register_ultimate(int(HexData.Owner.WOLF))
		_emit_three_ring_shockwave()
		return true
		
	return false

# --- DECOUPLING FLOW HOOKS ---

## Intercepts and halves incoming damage/resonance flow if the ThornWall is active.
func modify_incoming_flow(_p_attacker: Area2D, p_base_amount: float) -> float:
	if cell.active_buffs.has("ThornWall"):
		print("⬢ Wolf | ThornWall active! Absorbing 50% incoming resonance.")
		return p_base_amount * 0.5
	return p_base_amount

# --- INTERNAL MATHEMATICAL LAYOUTS ---

## Emits a concentric 3-ring wave of energy using O(1) distance math.
func _emit_three_ring_shockwave() -> void:
	print("⬢ Wolf | CALL OF THE PACK: Cascading 3-Ring Shockwave initiated!")
	var grid: HexGrid = cell.get_parent() as HexGrid
	if not grid: return
	
	var center_coords: Vector3i = cell.hex_data.cube_coords
	
	for coords: Vector3i in grid.all_cells:
		var n_cell: Area2D = grid.all_cells[coords] as Area2D
		if not n_cell: continue
		
		# Get distance via optimized HexMath helper
		var distance: int = HexMath.cube_distance(center_coords, coords)
		
		var energy_to_inject: float = 0.0
		var flash_delay: float = 0.0
		
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

## Handles staggered temporal shockwave activation using dynamic Timers.
func _execute_delayed_ripple(p_cell: Area2D, p_energy: float, p_delay: float, p_grid: HexGrid, p_distance: int) -> void:
	if p_delay > 0.0:
		await p_cell.get_tree().create_timer(p_delay).timeout
		
	if is_instance_valid(p_cell):
		p_cell.hex_data.add_resonance(int(HexData.Owner.WOLF), p_energy)
		p_grid._calculate_dominance(p_cell)
		p_cell._update_visuals()
		_flash_cell_resonance(p_cell, p_distance)

## Procedurally flares cell borders matching the distance intensity.
func _flash_cell_resonance(p_cell: Area2D, p_distance: int) -> void:
	var base_border := p_cell.get_node_or_null("HexBorder") as Line2D
	var base_shape := p_cell.get_node_or_null("HexShape") as Polygon2D
	if not base_border or not base_shape: return
	
	var flash_width: float = 4.5
	var color_boost: float = 1.0
	
	match p_distance:
		1: 
			flash_width = 18.0
			color_boost = 1.4
		2: 
			flash_width = 12.0
			color_boost = 1.2
		3: 
			flash_width = 7.0
			color_boost = 1.0

	base_border.width = flash_width
	var original_color: Color = base_border.default_color
	base_border.default_color = original_color * color_boost
	
	var tween: Tween = p_cell.create_tween().set_parallel(true)
	var target_width: float = 4.0 if p_cell.is_hovered else 1.5
	
	tween.tween_property(base_border, "width", target_width, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(base_border, "default_color", original_color, 0.4)