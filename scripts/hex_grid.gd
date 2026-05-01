## ⬢ hex_grid.gd ⬢
## Controls the battlefield and guardian deployment.
extends Node2D

@export var map_radius := 4
@export var hex_cell_scene: PackedScene = preload("res://scenes/hex_cell.tscn")

var all_cells := {}

func _ready() -> void:
	_generate_ring_grid()
	# Give the engine a moment to breath
	await get_tree().process_frame
	_initialize_match()

func _generate_ring_grid() -> void:
	for q in range(-map_radius, map_radius + 1):
		var r1 := int(max(-map_radius, -q - map_radius))
		var r2 := int(max(-map_radius, -q + map_radius)) # Fixed min logic
		r2 = int(min(map_radius, -q + map_radius))
		
		for r in range(r1, r2 + 1):
			var s := -q - r
			_spawn_cell(Vector3i(q, r, s))

func _spawn_cell(p_coords: Vector3i) -> void:
	var cell := hex_cell_scene.instantiate()
	var data := HexData.new(p_coords)
	
	# Add a small margin (e.g., 1.05 instead of 1.0) to separate the cells
	var margin := 1.01 
	
	# Adjusted Pixel Math (Pointy-Topped) with Margin
	var x := GlobalSettings.HEX_RADIUS * (sqrt(3) * p_coords.x + sqrt(3)/2.0 * p_coords.y) * margin
	var y := GlobalSettings.HEX_RADIUS * (3.0/2.0 * p_coords.y) * margin
	
	cell.position = Vector2(x, y)
	add_child(cell)
	
	cell.setup(data)
	all_cells[p_coords] = cell
	
	# CONNECT HERE (Only once during spawn!)
	if not cell.cell_clicked.is_connected(_on_cell_clicked):
		cell.cell_clicked.connect(_on_cell_clicked)

func _initialize_match() -> void:
	print("⬢ H.I.V.E. | Deploying Guardians to the corners...")
	
	# 1. Clear all to Neutral first (safety)
	for coords in all_cells:
		_assign_cell(coords, HexData.Owner.NEUTRAL, 0.0)

	# 2. Position Mapping (Triangle Balance)
	# Player: Bottom-Right | Enemy 1: Top | Enemy 2: Bottom-Left
	var start_positions = [
		Vector3i(map_radius, 0, -map_radius),   # Player (SE)
		Vector3i(0, -map_radius, map_radius),   # Rival 1 (North)
		Vector3i(-map_radius, map_radius, 0)    # Rival 2 (SW)
	]

	# 3. Assignment
	# Player
	_assign_cell(start_positions[0], GlobalSettings.selected_animal, 50.0)
	
	# Rivals
	for i in range(GlobalSettings.selected_rivals.size()):
		if i + 1 < start_positions.size():
			_assign_cell(start_positions[i+1], GlobalSettings.selected_rivals[i], 50.0)

func _assign_cell(p_coords: Vector3i, p_type: HexData.Owner, p_energy: float) -> void:
	if all_cells.has(p_coords):
		var cell = all_cells[p_coords]
		cell.hex_data.current_owner = p_type
		cell.hex_data.energy = p_energy
		cell._update_visuals()


func _on_cell_clicked(coords: Vector3i) -> void:
	print("⬢ Resonance at: ", coords, " | Owner: ", all_cells[coords].hex_data.current_owner)
