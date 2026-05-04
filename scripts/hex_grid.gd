## ⬢ hex_grid.gd ⬢
## Manager for grid generation, spectral flow, and overflow cascades.
extends Node2D

@export var map_radius := 4
@export var hex_cell_scene: PackedScene = preload("res://scenes/hex_cell.tscn")

# --- STATE ---
var all_cells := {}
var selected_source: Area2D = null
var overflow_buffer := []
var is_dragging := false
var drag_line: Line2D

# --- ENGINE CORES ---

func _ready() -> void:
	_generate_ring_grid()
	await get_tree().process_frame
	_initialize_match()
	_setup_drag_line()
	
	if BeatManager:
		BeatManager.pulse_impact.connect(_on_pulse_impact)

# --- GRID GENERATION ---

func _generate_ring_grid() -> void:
	for q in range(-map_radius, map_radius + 1):
		var r1 := int(max(-map_radius, -q - map_radius))
		var r2 := int(min(map_radius, -q + map_radius))
		for r in range(r1, r2 + 1):
			_spawn_cell(Vector3i(q, r, -q - r))

func _spawn_cell(p_coords: Vector3i) -> void:
	var cell := hex_cell_scene.instantiate()
	var data := HexData.new(p_coords)
	
	cell.position = Vector2(
		GlobalSettings.HEX_RADIUS * (sqrt(3) * p_coords.x + sqrt(3)/2.0 * p_coords.y) * GlobalSettings.HEX_MARGIN,
		GlobalSettings.HEX_RADIUS * (3.0/2.0 * p_coords.y) * GlobalSettings.HEX_MARGIN
	)
	
	add_child(cell)
	cell.setup(data)
	all_cells[p_coords] = cell
	cell.cell_clicked.connect(_on_cell_clicked)

# --- MATCH LOGIC ---

func _initialize_match() -> void:
	print("⬢ H.I.V.E. | Synchronizing Spectrums...")
	var start_positions = [
		Vector3i(map_radius, 0, -map_radius),
		Vector3i(0, -map_radius, map_radius),
		Vector3i(-map_radius, map_radius, 0)
	]

	_inject_resonance(start_positions[0], GlobalSettings.selected_animal, 50.0)
	
	for i in range(GlobalSettings.selected_rivals.size()):
		if i + 1 < start_positions.size():
			_inject_resonance(start_positions[i+1], GlobalSettings.selected_rivals[i], 50.0)

func _inject_resonance(p_coords: Vector3i, p_type: int, p_amount: float) -> void:
	if all_cells.has(p_coords):
		var cell = all_cells[p_coords]
		cell.hex_data.resonance[p_type] = p_amount
		_calculate_dominance(cell)
		cell._update_visuals()

# --- INTERACTION & BEAT ---

func _setup_drag_line() -> void:
	drag_line = Line2D.new()
	add_child(drag_line)
	drag_line.z_index = 20
	drag_line.width = 0.0 # Starts invisible
	drag_line.default_color = Color.WHITE

func _process(_delta: float) -> void:
	if is_dragging and selected_source:
		_update_drag_visuals()

func _update_drag_visuals() -> void:
	var mouse_pos = get_local_mouse_position()
	drag_line.points = PackedVector2Array([selected_source.position, mouse_pos])
	
	# Dynamic scale based on resonance (logarithmic feel)
	var resonance = selected_source.hex_data.resonance[selected_source.hex_data.current_owner]
	drag_line.width = log(resonance + 1.0) * 5.0
	
	# Camera Lean (Max 15px)
	var drag_vec = (mouse_pos - selected_source.position).limit_length(150.0)
	var lean = (drag_vec / 150.0) * 15.0
	get_viewport().get_camera_2d().offset = lean

func _on_cell_clicked(p_coords: Vector3i) -> void:
	if BeatManager.current_phase != BeatManager.GamePhase.LOADING: return
	
	var cell = all_cells[p_coords]
	if cell.hex_data.current_owner == GlobalSettings.selected_animal:
		selected_source = cell
		is_dragging = true
		drag_line.visible = true

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and not event.pressed:
		if is_dragging:
			_finalize_drag()

func _finalize_drag() -> void:
	is_dragging = false
	drag_line.visible = false
	get_viewport().get_camera_2d().offset = Vector2.ZERO
	
	# Check for cell under mouse
	var hover_cell = _get_cell_at_mouse()
	if hover_cell and selected_source:
		var dist = int((abs(selected_source.hex_data.cube_coords.x - hover_cell.hex_data.cube_coords.x) + \
					abs(selected_source.hex_data.cube_coords.y - hover_cell.hex_data.cube_coords.y) + \
					abs(selected_source.hex_data.cube_coords.z - hover_cell.hex_data.cube_coords.z)) / 2)
		
		if dist == 1:
			selected_source.set_target(hover_cell)
			Input.vibrate_handheld(20) # Snapping haptics
	
	selected_source = null

func _get_cell_at_mouse() -> Area2D:
	for cell in all_cells.values():
		if cell.is_hovered: return cell
	return null
# func _on_cell_clicked(p_coords: Vector3i) -> void:
# 	if BeatManager.current_phase != BeatManager.GamePhase.LOADING: return
# 	var clicked_cell: Area2D = all_cells[p_coords]
	
# 	if clicked_cell.hex_data.current_owner == GlobalSettings.selected_animal:
# 		selected_source = clicked_cell
# 	elif selected_source != null:
# 		var diff: Vector3i = selected_source.hex_data.cube_coords - p_coords
# 		var distance: int = int((abs(diff.x) + abs(diff.y) + abs(diff.z)) / 2)
# 		if distance == 1:
# 			selected_source.set_target(clicked_cell)
# 			selected_source = null

func _on_pulse_impact() -> void:
	_process_pulse_queue()
	_process_overflow_buffer()
	_apply_global_regeneration()

# --- RESONANCE LOGIC ---

func _process_pulse_queue() -> void:
	var transfers := []
	for c_coords in all_cells:
		var cell = all_cells[c_coords]
		if cell.target_cell:
			transfers.append({"from": cell, "to": cell.target_cell})
	
	for t in transfers:
		_execute_transfer(t.from, t.to)
		t.from.flash_transfer()
		t.from.set_target(null)

func _execute_transfer(p_from: Area2D, p_to: Area2D) -> void:
	var sender_role = p_from.hex_data.current_owner
	if sender_role == HexData.Owner.NEUTRAL: return
	
	var amount: float = p_from.hex_data.resonance[sender_role] * GlobalSettings.TRANSFER_RATE
	p_from.hex_data.resonance[sender_role] -= amount
	
	_inject_with_overflow(p_to, sender_role, amount)
	_calculate_dominance(p_to)
	p_from._update_visuals()
	p_to._update_visuals()

func _inject_with_overflow(p_cell: Area2D, p_role: int, p_amount: float) -> void:
	var current = p_cell.hex_data.resonance[p_role]
	var room = GlobalSettings.MAX_RESONANCE - current
	
	if p_amount <= room:
		p_cell.hex_data.resonance[p_role] += p_amount
	else:
		p_cell.hex_data.resonance[p_role] = GlobalSettings.MAX_RESONANCE
		overflow_buffer.append({"coords": p_cell.hex_data.cube_coords, "role": p_role, "amount": p_amount - room})

func _process_overflow_buffer() -> void:
	var current_batch = overflow_buffer.duplicate()
	overflow_buffer.clear()
	for data in current_batch:
		var neighbors = get_neighbors(data.coords)
		var split = data.amount / 6.0
		for n_coords in neighbors:
			var n_cell = get_cell_at(n_coords)
			if n_cell:
				n_cell.hex_data.add_resonance(data.role, split)
				_calculate_dominance(n_cell)
				n_cell._update_visuals()

func _calculate_dominance(p_cell: Area2D) -> void:
	var data = p_cell.hex_data
	var highest_role = HexData.Owner.NEUTRAL
	var max_val = 0.0
	for role in data.resonance:
		if data.resonance[role] > max_val:
			max_val = data.resonance[role]
			highest_role = role
	data.current_owner = highest_role if max_val > 5.0 else HexData.Owner.NEUTRAL

func _apply_global_regeneration() -> void:
	for c_coords in all_cells:
		var cell = all_cells[c_coords]
		var role = cell.hex_data.current_owner
		if role != HexData.Owner.NEUTRAL:
			cell.hex_data.add_resonance(role, GlobalSettings.REGEN_AMOUNT)
			cell._update_visuals()

# --- UTILS ---

func get_neighbors(p_coords: Vector3i) -> Array[Vector3i]:
	var directions = [Vector3i(1,-1,0), Vector3i(1,0,-1), Vector3i(0,1,-1), 
					  Vector3i(-1,1,0), Vector3i(-1,0,1), Vector3i(0,-1,1)]
	var results: Array[Vector3i] = []
	for d in directions: results.append(p_coords + d)
	return results

func get_cell_at(p_coords: Vector3i) -> Area2D:
	return all_cells.get(p_coords, null)
