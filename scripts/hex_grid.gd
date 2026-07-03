## ⬢ hex_grid.gd ⬢
## Manager for grid generation, spectral flow computations, and cascade calculations.
## Decoupled from specific guardian mechanics via dynamic strategy injection hooks.
extends Node2D
class_name HexGrid

# --- RESOURCES ---
@export var map_radius: int = 4
@export var hex_cell_scene: PackedScene = preload("res://scenes/hex_cell.tscn")

# Universal Config Resources for Guardian Logic Instantiations
@export var wolf_resource: GuardianResource = preload("res://resources/Guardian_Wolf.tres")
@export var shark_resource: GuardianResource = preload("res://resources/Guardian_Shark.tres")

# --- STATE CORES ---
var all_cells: Dictionary = {} # Key: Vector3i -> Value: HexCell (Area2D)
var selected_source: Area2D = null
var overflow_buffer: Array[Dictionary] = []
var is_dragging: bool = false
var drag_line: Line2D

# --- INTERACTIVE ULTIMATE TARGETING STATE ---
var is_targeting_tsunami: bool = false
var tsunami_caster: Area2D = null
var tsunami_logic: RefCounted = null
var tsunami_highlighted_cells: Array[Area2D] = []
var current_preview_direction: Vector3i = Vector3i.ZERO
var targeting_line: Line2D

# --- ENGINE CORES ---

func _ready() -> void:
	_generate_ring_grid()
	await get_tree().process_frame
	_initialize_match()
	_setup_drag_line()
	_connect_rhythmic_clock()

func _process(_delta: float) -> void:
	if is_dragging and selected_source:
		_update_drag_visuals()
	elif is_targeting_tsunami:
		_update_tsunami_targeting_preview()
		_update_tsunami_targeting_line()
		_maintain_tsunami_preview_visuals()

# --- INITIALIZATION & CONNECTIONS ---

## Binds grid calculation ticks to central EventBus emissions.
func _connect_rhythmic_clock() -> void:
	EventBus.phase_changed.connect(_on_phase_changed)
	EventBus.pulse_impacted.connect(_on_pulse_impact)
	print("⬢ Grid | Successfully synchronized with global Rhythmic Event Bus.")

## Generates concentric hex rings using axial bounds.
func _generate_ring_grid() -> void:
	for q in range(-map_radius, map_radius + 1):
		var r1: int = int(max(-map_radius, -q - map_radius))
		var r2: int = int(min(map_radius, -q + map_radius))
		for r in range(r1, r2 + 1):
			_spawn_cell(Vector3i(q, r, -q - r))

## Spawns, positions, and wires interactive signals for individual cells.
func _spawn_cell(p_coords: Vector3i) -> void:
	var cell: Area2D = hex_cell_scene.instantiate() as Area2D
	var data := HexData.new(p_coords)
	
	# Utilize HexMath O(1) pixel transformation for centering
	cell.position = HexMath.cube_to_pixel(p_coords, GlobalSettings.HEX_RADIUS, GlobalSettings.HEX_MARGIN)
	
	add_child(cell)
	cell.setup(data)
	all_cells[p_coords] = cell
	cell.cell_clicked.connect(_on_cell_clicked)

## Distributes baseline resonance values at starting nodes.
func _initialize_match() -> void:
	print("⬢ Grid | Stabilizing starting nodes...")
	var start_positions: Array[Vector3i] = [
		Vector3i(map_radius, 0, -map_radius),
		Vector3i(0, -map_radius, map_radius),
		Vector3i(-map_radius, map_radius, 0)
	]

	_inject_resonance(start_positions[0], GlobalSettings.selected_animal, 50.0)
	
	for i in range(GlobalSettings.selected_rivals.size()):
		if i + 1 < start_positions.size():
			_inject_resonance(start_positions[i+1], GlobalSettings.selected_rivals[i], 50.0)

# --- GUARDIAN BINDINGS (DYNAMIC HOOK INJECTIONS) ---

## Dynamically constructs specific logic strategies without hardcoding file class paths into cell modules.
func _assign_guardian_logic(p_cell: Area2D) -> void:
	var role: int = p_cell.hex_data.current_owner
	if role == int(HexData.Owner.NEUTRAL):
		p_cell.guardian_logic = null
		return
		
	match role:
		HexData.Owner.WOLF:
			if wolf_resource:
				p_cell.guardian_logic = WolfLogic.new(p_cell, wolf_resource)
				print("⬢ Grid | Injected WolfLogic at ", p_cell.hex_data.cube_coords)
		HexData.Owner.SHARK:
			if shark_resource:
				p_cell.guardian_logic = SharkLogic.new(p_cell, shark_resource)
				print("⬢ Grid | Injected SharkLogic at ", p_cell.hex_data.cube_coords)
		_:
			p_cell.guardian_logic = null

# --- INTERACTION & DRAG-TO-FLOW MECHANICS ---

func _setup_drag_line() -> void:
	drag_line = Line2D.new()
	add_child(drag_line)
	drag_line.z_index = 20
	drag_line.width = 0.0
	drag_line.default_color = Color.WHITE

func _update_drag_visuals() -> void:
	var mouse_pos: Vector2 = get_local_mouse_position()
	drag_line.points = PackedVector2Array([selected_source.position, mouse_pos])
	
	var resonance: float = selected_source.hex_data.resonance[selected_source.hex_data.current_owner]
	drag_line.width = clamp(log(resonance + 1.0) * 5.0, 2.0, 20.0)
	
	var role_name: String = HexData.Owner.keys()[selected_source.hex_data.current_owner]
	drag_line.default_color = GlobalSettings.COLORS.get(role_name, Color.WHITE)

func _on_cell_clicked(p_coords: Vector3i) -> void:
	if BeatManager.current_phase != BeatManager.GamePhase.LOADING: return
	
	# Intercept clicked signals if player is choosing a Tsunami direction
	if is_targeting_tsunami:
		_handle_tsunami_targeting_click(p_coords)
		return
	
	var cell: Area2D = all_cells[p_coords] as Area2D
	if int(cell.hex_data.current_owner) == GlobalSettings.selected_animal:
		selected_source = cell
		is_dragging = true
		drag_line.visible = true

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and not event.pressed:
		if is_dragging:
			_finalize_drag()
		elif is_targeting_tsunami and event.button_index == MOUSE_BUTTON_RIGHT:
			# Cancel tactical targeting with right click
			_cancel_tsunami_targeting()

func _finalize_drag() -> void:
	is_dragging = false
	drag_line.visible = false
	get_viewport().get_camera_2d().offset = Vector2.ZERO
	
	var hover_cell: Area2D = _get_cell_at_mouse()
	if hover_cell and selected_source:
		# Use optimized HexMath distance helper
		var dist: int = HexMath.cube_distance(selected_source.hex_data.cube_coords, hover_cell.hex_data.cube_coords)
		if dist == 1:
			selected_source.set_target(hover_cell)
			Input.vibrate_handheld(20) # Haptic feedback click feel
	
	selected_source = null

func _get_cell_at_mouse() -> Area2D:
	var local_mouse: Vector2 = get_local_mouse_position()
	var target_coords: Vector3i = HexMath.pixel_to_cube(
		local_mouse, 
		GlobalSettings.HEX_RADIUS, 
		GlobalSettings.HEX_MARGIN
	)
	return all_cells.get(target_coords, null) as Area2D

# --- INTERACTIVE TSUNAMI TARGETING SYSTEM ---

## Initializes interactive targeting state.
func start_tsunami_targeting(p_caster: Area2D, p_logic: RefCounted) -> void:
	print("⬢ Grid | Entering 6-Directional Tsunami Targeting mode.")
	is_targeting_tsunami = true
	tsunami_caster = p_caster
	tsunami_logic = p_logic
	current_preview_direction = Vector3i.ZERO
	
	# Instantiate targeting line dynamic visual
	if not targeting_line:
		targeting_line = Line2D.new()
		add_child(targeting_line)
		targeting_line.z_index = 21
		targeting_line.default_color = Color("1a5fb4").lightened(0.3)
	
	targeting_line.width = 6.0
	targeting_line.visible = true

## Updates the dynamic mouse guide arrow representing the target vector.
func _update_tsunami_targeting_line() -> void:
	if not tsunami_caster or not targeting_line: return
	var mouse_pos: Vector2 = get_local_mouse_position()
	targeting_line.points = PackedVector2Array([tsunami_caster.position, mouse_pos])

## Track hover interactions to compute real-time fanning previews based on cursor angle.
func _update_tsunami_targeting_preview() -> void:
	var hover_cell := _get_cell_at_mouse()
	if not hover_cell or hover_cell == tsunami_caster:
		_clear_tsunami_preview()
		return
		
	var caster_coords: Vector3i = tsunami_caster.hex_data.cube_coords
	var hover_coords: Vector3i = hover_cell.hex_data.cube_coords
	
	var delta: Vector3i = hover_coords - caster_coords
	if delta != Vector3i.ZERO:
		# Mathematically snap the cursor offset vector to the nearest of the 6 core hex axes
		var snapped_dir: Vector3i = _snap_to_nearest_direction(delta)
		if snapped_dir != current_preview_direction:
			_clear_tsunami_preview()
			current_preview_direction = snapped_dir
			_build_tsunami_preview(snapped_dir)
	else:
		_clear_tsunami_preview()

## Snaps any custom delta coordinate vector to the closest of the 6 primary hex directions.
func _snap_to_nearest_direction(p_delta: Vector3i) -> Vector3i:
	var directions: Array[Vector3i] = [
		Vector3i(1, -1, 0), Vector3i(1, 0, -1), Vector3i(0, 1, -1),
		Vector3i(-1, 1, 0), Vector3i(-1, 0, 1), Vector3i(0, -1, 1)
	]
	var closest_dir: Vector3i = directions[0]
	var max_similarity: float = -99999.0
	
	for d: Vector3i in directions:
		var sim: float = p_delta.x * d.x + p_delta.y * d.y + p_delta.z * d.z
		if sim > max_similarity:
			max_similarity = sim
			closest_dir = d
			
	return closest_dir

## Builds a multi-step symmetrical fanning preview matching the target vector.
func _build_tsunami_preview(p_direction: Vector3i) -> void:
	if not tsunami_caster: return
	
	var adjacents := _get_adjacent_directions(p_direction)
	var left_adj: Vector3i = adjacents[0]
	var right_adj: Vector3i = adjacents[1]
	
	var center_coords: Vector3i = tsunami_caster.hex_data.cube_coords
	
	# Dynamically read the depth limit from the active resource configuration
	var total_steps: int = 7
	if tsunami_logic and tsunami_logic.get("res") != null:
		var logic_res = tsunami_logic.get("res")
		if logic_res and logic_res.get("ulti_gameplay_range") != null:
			total_steps = int(logic_res.get("ulti_gameplay_range"))
	
	for step in range(1, total_steps):
		for k in range(step + 1):
			# Symmetrical fanning vector calculation
			var target_coords: Vector3i = center_coords + (left_adj * (step - k)) + (right_adj * k)
			var cell := get_cell_at(target_coords)
			if cell and cell != tsunami_caster:
				tsunami_highlighted_cells.append(cell)

## Reinforces the glowing blue borders every frame to prevent hover-resets.
func _maintain_tsunami_preview_visuals() -> void:
	for cell in tsunami_highlighted_cells:
		if is_instance_valid(cell):
			var border := cell.get_node_or_null("HexBorder") as Line2D
			if border:
				border.width = 8.0
				border.default_color = Color("1a5fb4").lightened(0.2)

## Safely wipes active visual highlights and restores standard states.
func _clear_tsunami_preview() -> void:
	for cell in tsunami_highlighted_cells:
		if is_instance_valid(cell):
			cell._update_visuals()
	tsunami_highlighted_cells.clear()
	current_preview_direction = Vector3i.ZERO

## Cancels the targeting loop without siphoning resources.
func _cancel_tsunami_targeting() -> void:
	print("⬢ Grid | Tsunami Targeting mode canceled.")
	_clear_tsunami_preview()
	_restore_all_grid_borders()
	if targeting_line:
		targeting_line.visible = false
	
	is_targeting_tsunami = false
	tsunami_caster = null
	tsunami_logic = null

## Clears all guiding borders on neighbor cells.
func _restore_all_grid_borders() -> void:
	for cell in all_cells.values():
		cell._update_visuals()

## Click interception on direction locks the targeting and fires the tsunami.
func _handle_tsunami_targeting_click(p_coords: Vector3i) -> void:
	var clicked_cell := get_cell_at(p_coords)
	if not clicked_cell or clicked_cell == tsunami_caster:
		_cancel_tsunami_targeting()
		return
		
	var caster_coords: Vector3i = tsunami_caster.hex_data.cube_coords
	var delta: Vector3i = p_coords - caster_coords
	
	if delta != Vector3i.ZERO:
		var chosen_direction: Vector3i = _snap_to_nearest_direction(delta)
		print("⬢ Grid | Launching Tsunami direction confirmed: ", chosen_direction)
		
		_clear_tsunami_preview()
		_restore_all_grid_borders()
		if targeting_line:
			targeting_line.visible = false
		
		is_targeting_tsunami = false
		
		# Execute fire logic directly on RefCounted Strategy Logic
		if tsunami_logic and tsunami_logic.has_method("fire_tsunami"):
			tsunami_logic.call_deferred("fire_tsunami", chosen_direction)
			
		tsunami_caster = null
		tsunami_logic = null
	else:
		_cancel_tsunami_targeting()

## Utility helper to retrieve the two 60-degree adjacent directions of a vector.
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

# --- RHYTHM EVENT LISTENERS ---

func _on_pulse_impact() -> void:
	_visualize_impending_transfers()

func _on_phase_changed(p_new_phase: int) -> void:
	match p_new_phase:
		BeatManager.GamePhase.PULSING:
			_visualize_impending_transfers()
		BeatManager.GamePhase.ECHOING:
			# Cancel active targeting sequence on turn end to prevent interface state locks
			if is_targeting_tsunami:
				_cancel_tsunami_targeting()
			_process_pulse_queue()
			_process_overflow_buffer()
			_apply_global_regeneration()

func _visualize_impending_transfers() -> void:
	for c_coords: Vector3i in all_cells:
		var cell: Area2D = all_cells[c_coords] as Area2D
		if cell.target_cell:
			cell.start_pulsing_transfer()

# --- SPECTRAL RESONANCE MATRIX COMPUTATIONS ---

func _process_pulse_queue() -> void:
	var transfers: Array[Dictionary] = []
	for c_coords: Vector3i in all_cells:
		var cell: Area2D = all_cells[c_coords] as Area2D
		if cell.target_cell:
			transfers.append({"from": cell, "to": cell.target_cell})
	
	for t: Dictionary in transfers:
		_execute_transfer(t["from"], t["to"])
		t["from"].flash_transfer() 
		t["from"].set_target(null) 

## Resolves energy flow math between sender and receiver. Decoupled using logic interceptors.
func _execute_transfer(p_from: Area2D, p_to: Area2D) -> void:
	var sender_role: int = p_from.hex_data.current_owner
	if sender_role == int(HexData.Owner.NEUTRAL): return
	
	# Determine baseline transmission quantity
	var amount: float = p_from.hex_data.resonance[sender_role] * GlobalSettings.TRANSFER_RATE
	
	# Hook A: Dynamic Outbound Modulation (e.g., Shark siphons or buffs flow)
	if p_from.guardian_logic:
		amount = p_from.guardian_logic.modify_outgoing_flow(p_to, amount)
		
	# Hook B: Dynamic Inbound Filtering (e.g., Wolf ThornWall damping defenses)
	if p_to.guardian_logic:
		amount = p_to.guardian_logic.modify_incoming_flow(p_from, amount)
	
	# Process physical transfer execution
	p_from.hex_data.resonance[sender_role] -= amount
	_inject_with_overflow(p_to, sender_role as HexData.Owner, amount)
	
	_calculate_dominance(p_from)
	_calculate_dominance(p_to)
	p_from._update_visuals()
	p_to._update_visuals()

func _inject_with_overflow(p_cell: Area2D, p_role: HexData.Owner, p_amount: float) -> void:
	var current: float = p_cell.hex_data.resonance[p_role]
	var room: float = GlobalSettings.MAX_RESONANCE - current
	
	if p_amount <= room:
		p_cell.hex_data.resonance[p_role] += p_amount
	else:
		p_cell.hex_data.resonance[p_role] = GlobalSettings.MAX_RESONANCE
		overflow_buffer.append({
			"coords": p_cell.hex_data.cube_coords, 
			"role": p_role, 
			"amount": p_amount - room
		})

## Processes overflow cascades with a strict safety-brake to prevent infinite loops.
func _process_overflow_buffer() -> void:
	var cascade_count: int = 0
	var max_cascades: int = 8 # Safeguard brake matching Operational Protocol
	
	while overflow_buffer.size() > 0 and cascade_count < max_cascades:
		cascade_count += 1
		var current_batch: Array[Dictionary] = overflow_buffer.duplicate()
		overflow_buffer.clear()
		
		for data: Dictionary in current_batch:
			var neighbors: Array[Vector3i] = get_neighbors(data["coords"])
			var split_amount: float = data["amount"] / 6.0
			
			for n_coords: Vector3i in neighbors:
				var n_cell: Area2D = get_cell_at(n_coords)
				if n_cell:
					_inject_with_overflow(n_cell, data["role"] as HexData.Owner, split_amount)
					_calculate_dominance(n_cell)
					n_cell.call_deferred("_update_visuals")
					
	if cascade_count >= max_cascades:
		print("⬢ Grid | Cascade safety brake activated. Remaining overflow deferred.")

func _inject_resonance(p_coords: Vector3i, p_type: int, p_amount: float) -> void:
	if all_cells.has(p_coords):
		var cell: Area2D = all_cells[p_coords] as Area2D
		cell.hex_data.resonance[p_type] = p_amount
		_calculate_dominance(cell)
		cell._update_visuals()

## Resolves cell ownership shifts based on top spectrum heights.
func _calculate_dominance(p_cell: Area2D) -> void:
	var data: HexData = p_cell.hex_data
	var highest_role: HexData.Owner = HexData.Owner.NEUTRAL
	var max_val: float = 0.0
	
	for role: int in data.resonance:
		if data.resonance[role] > max_val:
			max_val = data.resonance[role]
			highest_role = role as HexData.Owner
			
	var old_owner: HexData.Owner = data.current_owner
	data.current_owner = highest_role if max_val > 5.0 else HexData.Owner.NEUTRAL
	
	# Automatically rebind strategic components on cell ownership swap
	if old_owner != data.current_owner:
		_assign_guardian_logic(p_cell)

# --- REGENERATION & TURN-TICK MANAGEMENT ---

## Triggers turn-based regeneration routines.
func _apply_global_regeneration() -> void:
	for coords: Vector3i in all_cells:
		var cell: Area2D = all_cells[coords] as Area2D
		var role: int = cell.hex_data.current_owner
		
		if role != int(HexData.Owner.NEUTRAL):
			# If a dynamic logic brain exists, let it calculate custom regeneration
			if cell.guardian_logic:
				cell.guardian_logic.process_regeneration()
			else:
				cell.hex_data.add_resonance(role, GlobalSettings.REGEN_AMOUNT)
		
		# Process expiration for tactical active buffers
		_tick_cell_buffs(cell)
		cell._update_visuals()

func _tick_cell_buffs(p_cell: Area2D) -> void:
	for buff: String in p_cell.active_buffs.keys():
		p_cell.active_buffs[buff] -= 1
		if p_cell.active_buffs[buff] <= 0:
			p_cell.active_buffs.erase(buff)

# --- COORDINATE & UTILITY HELPERS ---

func get_neighbors(p_coords: Vector3i) -> Array[Vector3i]:
	var directions: Array[Vector3i] = [
		Vector3i(1, -1, 0), Vector3i(1, 0, -1), Vector3i(0, 1, -1), 
		Vector3i(-1, 1, 0), Vector3i(-1, 0, 1), Vector3i(0, -1, 1)
	]
	var results: Array[Vector3i] = []
	for d: Vector3i in directions: 
		results.append(p_coords + d)
	return results

func get_cell_at(p_coords: Vector3i) -> Area2D:
	return all_cells.get(p_coords, null) as Area2D
