## ⬢ shark_logic.gd ⬢
## Specialized Shark tactical controller implementing Bloodlust, Maelstrom siphoning, and linear Tsunamis.
## Inherits from RefCounted for memory safety.
extends GuardianLogic
class_name SharkLogic

# --- CORE INTERACTION HOOKS ---

## Triggers the active Maelstrom siphon vortex.
func activate_ability() -> bool:
	if BeatManager.current_phase == BeatManager.GamePhase.ECHOING:
		print("⬢ Shark | Maelstrom rejected: The tides are locked during impact!")
		return false
		
	var current_actions: int = BeatManager.get_action_count(int(HexData.Owner.SHARK))
	if current_actions >= res.active_max_uses_per_round:
		print("⬢ Shark | Maelstrom rejected: Tonal capacity reached for this round!")
		return false

	var shark_res: float = cell.hex_data.resonance[int(HexData.Owner.SHARK)]
	if shark_res >= res.active_cost:
		cell.hex_data.resonance[int(HexData.Owner.SHARK)] -= res.active_cost
		
		_execute_maelstrom_siphon()
		
		BeatManager.register_action(int(HexData.Owner.SHARK))
		cell._update_visuals()
		return true
		
	print("⬢ Shark | Maelstrom failed: Insufficient resonance storage.")
	return false

## Triggers the linear directional Tsunami wave by entering targeting mode.
func activate_ultimate() -> bool:
	if BeatManager.current_phase == BeatManager.GamePhase.ECHOING: 
		return false
		
	if BeatManager.is_ultimate_used(int(HexData.Owner.SHARK)): 
		return false
	
	var shark_res: float = cell.hex_data.resonance[int(HexData.Owner.SHARK)]
	if shark_res >= res.ulti_cost:
		var grid := cell.get_parent() as HexGrid
		if grid:
			# Dedicate control loop to interactive 6-directional targeting setup
			grid.start_tsunami_targeting(cell, self)
			return true
			
	return false

## Fires the actual Tsunami wave after coordinates and direction have been chosen.
func fire_tsunami(p_direction: Vector3i) -> void:
	var shark_res: float = cell.hex_data.resonance[int(HexData.Owner.SHARK)]
	assert(shark_res >= res.ulti_cost, "⬢ Shark | Tsunami execution failed: Resonance resource lost.")
	
	cell.hex_data.resonance[int(HexData.Owner.SHARK)] -= res.ulti_cost
	BeatManager.register_ultimate(int(HexData.Owner.SHARK))
	
	_emit_tsunami_wave(p_direction)

# --- DECOUPLING FLOW HOOKS ---

## PASSIVE: BLOODLUST
## Intercepts outbound energy. If the target's total resonance is weakened (< 33%), siphons with 1.5x throughput.
func modify_outgoing_flow(p_target: Area2D, p_base_amount: float) -> float:
	var target_energy: float = p_target.hex_data.get_total_energy()
	if target_energy < (GlobalSettings.MAX_RESONANCE * 0.33):
		print("⬢ Shark | Bloodlust active! Siphoning weakened node with 1.5x throughput.")
		return p_base_amount * 1.5
	return p_base_amount

# --- INTERNAL ABILITY CALCULATIONS ---

## Standard vortex siphon drawing energy from hostiles and buffing nearby allies.
func _execute_maelstrom_siphon() -> void:
	print("⬢ Shark | MAELSTROM unleashed! Spinning up the vortex...")
	var grid := cell.get_parent() as HexGrid
	if not grid: return
	
	var neighbors: Array[Vector3i] = grid.get_neighbors(cell.hex_data.cube_coords)
	var hostile_cells: Array[Area2D] = []
	var shark_cells: Array[Area2D] = []
	
	# Step 1: Filter surroundings into tactical pools
	for n_coords in neighbors:
		var n_cell := grid.get_cell_at(n_coords) as Area2D
		if n_cell:
			var n_owner: int = n_cell.hex_data.current_owner
			if n_owner == int(HexData.Owner.SHARK):
				shark_cells.append(n_cell)
			else:
				hostile_cells.append(n_cell)
				
	# Step 2: Siphon power from surrounding enemies (up to 7.0 each)
	var total_drained_energy: float = 0.0
	for enemy in hostile_cells:
		var enemy_role: int = enemy.hex_data.current_owner
		var current_power: float = enemy.hex_data.resonance[enemy_role]
		
		var drain_target: float = min(7.0, current_power)
		enemy.hex_data.resonance[enemy_role] -= drain_target
		total_drained_energy += drain_target
		enemy._update_visuals()
		
	# Step 3: Compute and distribute the pack resonance buff to allies
	var total_distributed_buffs: float = 0.0
	if shark_cells.size() > 0:
		var dynamic_buff_value: float = 3.0 + (3.0 * hostile_cells.size())
		
		for ally in shark_cells:
			ally.hex_data.add_resonance(int(HexData.Owner.SHARK), dynamic_buff_value)
			total_distributed_buffs += dynamic_buff_value
			ally._update_visuals()
			
	# Step 4: Retain the surplus energy difference on the caster node
	var net_retention: float = total_drained_energy - total_distributed_buffs
	cell.hex_data.add_resonance(int(HexData.Owner.SHARK), max(0.0, net_retention))
	
	print("⬢ Shark | Siphon summary: Drained ", total_drained_energy, " | Distributed Buffs: ", total_distributed_buffs)

## Summons a cascading directional fanning cone Tsunami wave.
func _emit_tsunami_wave(p_direction: Vector3i) -> void:
	print("⬢ Shark | TSUNAMI: Unleashing wave vector: ", p_direction)
	var grid := cell.get_parent() as HexGrid
	if not grid: return
	
	var adjacents := _get_adjacent_directions(p_direction)
	var left_adj: Vector3i = adjacents[0]
	var right_adj: Vector3i = adjacents[1]
	
	var center_coords: Vector3i = cell.hex_data.cube_coords
	var total_steps: int = int(res.ulti_gameplay_range) if res else 7
	
	# Iterate through the wave layers
	for step in range(1, total_steps):
		# Dynamic damage scaling from Resource values
		var base_dmg: float = res.ulti_base_damage if res else 25.0
		var step_scale: float = res.ulti_step_damage_scale if res else 7.0
		var current_damage: float = base_dmg + (step - 1) * step_scale
		
		var layer_delay: float = step * 0.15
		
		# Symmetrical fanning cone loop
		for k in range(step + 1):
			var target_coords: Vector3i = center_coords + (left_adj * (step - k)) + (right_adj * k)
			var target_cell := grid.get_cell_at(target_coords) as Area2D
			
			if target_cell:
				_execute_tsunami_impact(target_cell, layer_delay, current_damage, grid)

## Deals damage inside the tsunami sweep path and triggers water animations.
func _execute_tsunami_impact(p_cell: Area2D, p_delay: float, p_damage: float, p_grid: HexGrid) -> void:
	if not p_cell: return
	if p_delay > 0.0:
		await p_cell.get_tree().create_timer(p_delay).timeout
		
	if is_instance_valid(p_cell):
		var owner: int = p_cell.hex_data.current_owner
		
		# Case 1: Opposing rival structures (Siphon and damage)
		if owner != int(HexData.Owner.SHARK) and owner != int(HexData.Owner.NEUTRAL):
			print("⬢ Shark | Tsunami wave crash at ", p_cell.hex_data.cube_coords, " | Damage: ", p_damage)
			
			var old_resonance: float = p_cell.hex_data.resonance[owner]
			var new_resonance: float = max(0.0, old_resonance - p_damage)
			p_cell.hex_data.resonance[owner] = new_resonance
			
			var crushed_capacity: float = old_resonance - new_resonance
			var drain_rate: float = res.ulti_drain_efficiency if res else 0.5
			var drained_gain: float = crushed_capacity * drain_rate
			
			# Reclaim custom percentage of the crushed capacity as friendly active Shark resonance
			if drained_gain > 0.0:
				p_cell.hex_data.add_resonance(int(HexData.Owner.SHARK), drained_gain)
				
		# Case 2: Neutral structures (Flood and claimed conversion)
		elif owner == int(HexData.Owner.NEUTRAL):
			print("⬢ Shark | Tsunami floods neutral cell at ", p_cell.hex_data.cube_coords)
			var claim_rate: float = res.ulti_neutral_claim_efficiency if res else 0.5
			var claimed_resonance: float = p_damage * claim_rate
			p_cell.hex_data.add_resonance(int(HexData.Owner.SHARK), claimed_resonance)
			
		# Case 3: Friendly Shark structures (Surge with tidal energy boost)
		else:
			print("⬢ Shark | Tsunami energizes friendly cell at ", p_cell.hex_data.cube_coords)
			var boost_rate: float = res.ulti_friendly_boost_scale if res else 0.25
			p_cell.hex_data.add_resonance(int(HexData.Owner.SHARK), p_damage * boost_rate)
			
		p_grid._calculate_dominance(p_cell)
		p_cell._update_visuals()
		_flash_water_wave(p_cell)

## Triggers a procedural deep-blue visual flash representing the tidal sweep.
func _flash_water_wave(p_cell: Area2D) -> void:
	var border := p_cell.get_node_or_null("HexBorder") as Line2D
	if not border: return
	
	border.width = 14.0
	var original_color: Color = border.default_color
	border.default_color = Color("1a5fb4") # Deep tidal blue wave crest
	
	var tween: Tween = p_cell.create_tween().set_parallel(true)
	var target_width: float = 4.0 if p_cell.is_hovered else 1.5
	
	tween.tween_property(border, "width", target_width, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(border, "default_color", original_color, 0.5)

# --- COORDINATE UTILITIES ---

## Computes the two adjacent directions of a vector.
func _get_adjacent_directions(p_dir: Vector3i) -> Array[Vector3i]:
	var directions: Array[Vector3i] = [
		Vector3i(1, -1, 0), Vector3i(1, 0, -1), Vector3i(0, 1, -1),
		Vector3i(-1, 1, 0), Vector3i(-1, 0, 1), Vector3i(0, -1, 1)
	]
	var idx: int = directions.find(p_dir)
	if idx != -1:
		var left_idx := (idx - 1 + 6) % 6
		var right_idx := (idx + 1) % 6
		return [directions[left_idx], directions[right_idx]]
	return [Vector3i.ZERO, Vector3i.ZERO]
