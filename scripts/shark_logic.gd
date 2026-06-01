## ⬢ shark_logic.gd ⬢
## Core logic component for the Shark archetype.
extends GuardianLogic
class_name SharkLogic

func apply_passive() -> void:
	# Bloodlust logic will be triggered inside hex_grid.gd transfers, 
	# but we can add secondary passive effects here later.
	pass


## PHASE V - ACTIVE ABILITY: MAELSTROM
func activate_ability() -> bool:
	# 1. Phase-Sperre: Abilities are forbidden during calculation impacts
	if BeatManager.current_phase == BeatManager.GamePhase.ECHOING:
		print("⬢ Shark | Maelstrom rejected: The tides are locked during impact!")
		return false
		
	# 2. Global Use Limit: Bound to a maximum of 3 deployments per beat
	if BeatManager.wolf_actions_this_round >= res.active_max_uses_per_round:
		print("⬢ Shark | Maelstrom rejected: Tonal capacity reached for this round!")
		return false

	# 3. Energy Resource Validation
	var shark_res: float = cell.hex_data.resonance[HexData.Owner.SHARK]
	if shark_res >= res.active_cost:
		cell.hex_data.resonance[HexData.Owner.SHARK] -= res.active_cost
		
		# Execute the core siphon calculation
		_execute_maelstrom_siphon()
		
		# Increment the action points (Using the shared round tracking)
		BeatManager.wolf_actions_this_round += 1
		cell._update_visuals()
		return true
		
	print("⬢ Shark | Maelstrom failed: Insufficient resonance storage.")
	return false

## Calculates neighbor profiles to siphon enemy power and feed friendly sharks
func _execute_maelstrom_siphon() -> void:
	print("⬢ Shark | MAELSTROM unleashed! Spinning up the vortex...")
	var grid = cell.get_parent()
	var neighbors: Array[Vector3i] = grid.get_neighbors(cell.hex_data.cube_coords)
	
	var hostile_cells: Array[Area2D] = []
	var shark_cells: Array[Area2D] = []
	
	# Step A: Sort neighboring grid nodes into tactical pools
	for n_coords in neighbors:
		var n_cell = grid.get_cell_at(n_coords)
		if n_cell:
			var n_owner = n_cell.hex_data.current_owner
			if n_owner == HexData.Owner.SHARK:
				shark_cells.append(n_cell)
			else:
				# Any node that is not owned by the Shark (Neutral or Rival) is Hostile
				hostile_cells.append(n_cell)
				
	# Step B: Calculate raw extraction values
	var total_drained_energy := 0.0
	for enemy in hostile_cells:
		# Extract 7 energy from the most dominant spectrum slot currently in control
		var enemy_role = enemy.hex_data.current_owner
		var current_power = enemy.hex_data.resonance[enemy_role]
		
		# Siphon up to 7 energy, but never more than the cell actually holds
		var drain_target = min(7.0, current_power)
		enemy.hex_data.resonance[enemy_role] -= drain_target
		total_drained_energy += drain_target
		
		# Immediately update enemy tile visually to display loss
		enemy._update_visuals()
		
	# Step C: Calculate and distribute the Pack-Buff
	var total_distributed_buffs := 0.0
	if shark_cells.size() > 0:
		var dynamic_buff_value: float = 3.0 + (3.0 * hostile_cells.size())
		
		for ally in shark_cells:
			ally.hex_data.add_resonance(HexData.Owner.SHARK, dynamic_buff_value)
			total_distributed_buffs += dynamic_buff_value
			ally._update_visuals()
			
	# Step D: Apply Net Energy Retention to the core vortex node
	var net_retention = total_drained_energy - total_distributed_buffs
	cell.hex_data.add_resonance(HexData.Owner.SHARK, max(0.0, net_retention))
	
	print("⬢ Shark | Siphon summary: Drained ", total_drained_energy, " | Distributed Buffs: ", total_distributed_buffs)



func activate_ultimate() -> bool:
	print("⬢ Shark | Tsunami request sent to the depth.")
	return true