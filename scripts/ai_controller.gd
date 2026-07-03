## ⬢ ai_controller.gd ⬢
## Tactical agent controller orchestrating moves for rival spectrums.
## Connects directly to the EventBus to plan actions during the LOADING phase.
extends Node
class_name AIController

# --- NODES ---
@onready var grid: HexGrid = get_parent() as HexGrid

# --- CONFIGURATION ---
@export var max_actions_per_beat: int = 5

# --- ENGINE CORES ---

func _ready() -> void:
	# Decouple clock monitoring straight to EventBus signals
	EventBus.phase_changed.connect(_on_phase_changed)

# --- EVENT BUS LISTENERS ---

func _on_phase_changed(p_new_phase: int) -> void:
	if p_new_phase == int(BeatManager.GamePhase.LOADING):
		# Create an artificial human-like thinking delay before planning moves
		await get_tree().create_timer(0.5).timeout
		_think()

# --- AI CORE DECISION BRAIN ---

## Analyzes the battlefield layout, filters relevant nodes, and issues move commands.
func _think() -> void:
	if not grid: return
	
	var possible_actions: Array[Area2D] = []
	
	# 1. Gather all potential cells owned by rival factions
	for coords: Vector3i in grid.all_cells:
		var cell: Area2D = grid.all_cells[coords] as Area2D
		if not cell: continue
		
		var role: int = cell.hex_data.current_owner
		
		# Rival checks: Filter out neutrals and the player's selected guardian
		if role != GlobalSettings.selected_animal and role != int(HexData.Owner.NEUTRAL):
			# Tactical limit: Only act if the cell has enough resonance capital
			if cell.hex_data.resonance[role] > 20.0:
				possible_actions.append(cell)
	
	# 2. Sort available cells by dominance (Rivals want to spread from their power centers first)
	possible_actions.sort_custom(func(a: Area2D, b: Area2D) -> bool:
		var owner_a: int = a.hex_data.current_owner
		var owner_b: int = b.hex_data.current_owner
		return a.hex_data.resonance[owner_a] > b.hex_data.resonance[owner_b]
	)
	
	# 3. Issue commands limited by the hand-speed balancing threshold
	var actions_taken: int = 0
	for ai_cell: Area2D in possible_actions:
		if actions_taken >= max_actions_per_beat:
			break
			
		if _ai_decide_action(ai_cell):
			actions_taken += 1

## Evaluates the local surroundings of a cell and plans flow target coordinates.
func _ai_decide_action(p_cell: Area2D) -> bool:
	var my_role: int = p_cell.hex_data.current_owner
	var neighbors: Array[Vector3i] = grid.get_neighbors(p_cell.hex_data.cube_coords)
	
	# Randomize neighbor search vectors to make spreading patterns organic
	neighbors.shuffle()
	
	for n_coords: Vector3i in neighbors:
		var target: Area2D = grid.get_cell_at(n_coords) as Area2D
		if target:
			# Target check: Only spread energy to nodes not currently owned by this specific rival
			if target.hex_data.current_owner != my_role:
				p_cell.set_target(target)
				
				# FUTURE EXTENSION HOOK: 
				# This is the exact place where rival tactical logic (e.g. casting abilities)
				# can be executed once guardian expansion phases go live!
				
				return true # Successfully planned a transfer
				
	return false # No viable neighboring vector target found