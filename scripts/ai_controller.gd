## ⬢ ai_controller.gd ⬢
## Rival logic adapted for spectral resonance spectrums.
extends Node

@onready var grid: Node2D = get_parent()
@export var max_actions_per_beat := 5 # The AI's "Hand-Speed" limit

# --- ENGINE CORES ---

func _ready() -> void:
	if BeatManager:
		BeatManager.phase_changed.connect(_on_phase_changed)

# --- SIGNAL HANDLING ---

func _on_phase_changed(p_new_phase: int) -> void:
	if p_new_phase == BeatManager.GamePhase.LOADING:
		# Artificial thinking delay
		await get_tree().create_timer(0.5).timeout
		_think()



func _think() -> void:
	if not grid: return
	
	var possible_actions := []
	
	# 1. Collect all potential moves
	for coords in grid.all_cells:
		var cell: Area2D = grid.all_cells[coords]
		var role: int = cell.hex_data.current_owner
		
		# Rival check
		if role != GlobalSettings.selected_animal and role != HexData.Owner.NEUTRAL:
			# Only consider cells with enough power to actually make an impact
			if cell.hex_data.resonance[role] > 20.0:
				possible_actions.append(cell)
	
	# 2. Sort by energy (AI wants to move its strongest cells first)
	possible_actions.sort_custom(func(a, b): 
		return a.hex_data.resonance[a.hex_data.current_owner] > b.hex_data.resonance[b.hex_data.current_owner]
	)
	
	# 3. Limit the number of actions
	var actions_taken := 0
	for ai_cell in possible_actions:
		if actions_taken >= max_actions_per_beat:
			break
			
		if _ai_decide_action(ai_cell):
			actions_taken += 1

## Decisions for a single cell. Returns true if a target was set.
func _ai_decide_action(p_cell: Area2D) -> bool:
	var my_role: int = p_cell.hex_data.current_owner
	var neighbors: Array[Vector3i] = grid.get_neighbors(p_cell.hex_data.cube_coords)
	neighbors.shuffle()
	
	for n_coords in neighbors:
		var target: Area2D = grid.get_cell_at(n_coords)
		if target:
			# Only attack if the target isn't already dominated by me
			if target.hex_data.current_owner != my_role:
				p_cell.set_target(target)
				return true # Succesfully planned an action
				
	return false # No valid target found
