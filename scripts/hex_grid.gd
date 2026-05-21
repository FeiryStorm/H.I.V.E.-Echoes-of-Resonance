## ⬢ hex_grid.gd ⬢
## Manager for grid generation, spectral flow, and overflow cascades.
extends Node2D

@export var hex_cell_scene: PackedScene = preload("res://scenes/hex_cell.tscn")
@export var map_radius := 4

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
	
# RE-CONNECT SIGNALS (Crucial Step)
	if BeatManager:
		# Ensure phase_changed is connected for the ECHOING impact
		if not BeatManager.phase_changed.is_connected(_on_phase_changed):
			BeatManager.phase_changed.connect(_on_phase_changed)
		
		# Ensure pulse_impact is connected for the PULSING visual
		if not BeatManager.pulse_impact.is_connected(_on_pulse_impact):
			BeatManager.pulse_impact.connect(_on_pulse_impact)
			
		print("⬢ H.I.V.E. | Grid successfully synchronized with Heartbeat.")

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

#--- INTERACTION & BEAT ---

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
	
	var resonance = selected_source.hex_data.resonance[selected_source.hex_data.current_owner]
	# Limit the max width to 20.0 so it doesn't cover the map
	drag_line.width = clamp(log(resonance + 1.0) * 5.0, 2.0, 20.0)
	
	# Match guardian color immediately
	var role_name = HexData.Owner.keys()[selected_source.hex_data.current_owner]
	drag_line.default_color = GlobalSettings.COLORS[role_name]

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

## Calculates the cell directly under the mouse using static math (O(1)).
func _get_cell_at_mouse() -> Area2D:
	var local_mouse := get_local_mouse_position()
	
	# FIX: Explicitly type target_coords as Vector3i to solve the inference error
	var target_coords: Vector3i = HexMath.pixel_to_cube(
		local_mouse, 
		GlobalSettings.HEX_RADIUS, 
		GlobalSettings.HEX_MARGIN
	)
	
	return all_cells.get(target_coords, null) as Area2D

## Triggered at the start of PULSING phase (from BeatManager)
func _on_pulse_impact() -> void:
	print("⬢ H.I.V.E. | Visual Charge Phase started.")
	_visualize_impending_transfers()

## Triggered when ANY phase changes
func _on_phase_changed(p_new_phase: int) -> void:
	match p_new_phase:
		BeatManager.GamePhase.PULSING:
			print("⬢ H.I.V.E. | Pulsing Phase: Charging visuals...")
			_visualize_impending_transfers()
			
		BeatManager.GamePhase.ECHOING:
			print("⬢ H.I.V.E. | Echoing Phase: Impact!")
			_process_pulse_queue()
			_process_overflow_buffer()
			_apply_global_regeneration()

func _visualize_impending_transfers() -> void:
	print("⬢ H.I.V.E. | Pulsing: Energy is charging up...")
	for c_coords in all_cells:
		var cell = all_cells[c_coords]
		if cell.target_cell:
			cell.start_pulsing_transfer()


# --- RESONANCE LOGIC ---

## Updated Queue Process to ensure lines disappear AFTER calculation
func _process_pulse_queue() -> void:
	var transfers := []
	for c_coords in all_cells:
		var cell = all_cells[c_coords]
		if cell.target_cell:
			transfers.append({"from": cell, "to": cell.target_cell})
	
	for t in transfers:
		# 1. Math
		_execute_transfer(t.from, t.to)
		# 2. Spectacle (Flash)
		t.from.flash_transfer() 
		# 3. Cleanup: IMPORTANT - Clear target now so it's ready for next LOADING
		t.from.set_target(null) 
	


func _execute_transfer(p_from: Area2D, p_to: Area2D) -> void:
	var sender_role = p_from.hex_data.current_owner
	if sender_role == HexData.Owner.NEUTRAL: return
	
	var amount: float = p_from.hex_data.resonance[sender_role] * GlobalSettings.TRANSFER_RATE
	
	# DEFENSE-SYNC: Reduce damage if ThornWall is active
	if p_to.active_buffs.has("ThornWall"):
		amount *= 0.5 # 50% Damage Reduction
		print("⬢ Wolf | Thorns absorb resonance!")
	
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

## Process all collected overflows in an immediate cascading chain reaction.
func _process_overflow_buffer() -> void:
	print("⬢ H.I.V.E. | Triggering immediate cascade reaction...")
	
	var cascade_count := 0
	var max_cascades := 100 # Safety brake to prevent endless loops
	
	# Keep looping as long as new overflows are added to the buffer
	while overflow_buffer.size() > 0 and cascade_count < max_cascades:
		cascade_count += 1
		
		# Duplicate and clear the buffer instantly to catch new recursive overflows
		var current_batch := overflow_buffer.duplicate()
		overflow_buffer.clear()
		
		for data in current_batch:
			var neighbors := get_neighbors(data.coords)
			var split_amount: float = data.amount / 6.0
			
			for n_coords in neighbors:
				var n_cell := get_cell_at(n_coords) as Area2D
				if n_cell:
					# Inject directly. If this cell exceeds 100, 
					# it will append a NEW entry to the cleared overflow_buffer!
					_inject_with_overflow(n_cell, data.role, split_amount)
					_calculate_dominance(n_cell)
					n_cell._update_visuals()
					
	if cascade_count >= max_cascades:
		print("⬢ WARNING | Cascade safety brake triggered! Potential infinite loop detected.")

func _calculate_dominance(p_cell: Area2D) -> void:
	var data = p_cell.hex_data
	var highest_role = HexData.Owner.NEUTRAL
	var max_val = 0.0
	for role in data.resonance:
		if data.resonance[role] > max_val:
			max_val = data.resonance[role]
			highest_role = role
	data.current_owner = highest_role if max_val > 5.0 else HexData.Owner.NEUTRAL

## ⬢ hex_grid.gd ⬢ - Wolf Mechanics

func _apply_global_regeneration() -> void:
	for coords in all_cells:
		var cell = all_cells[coords]
		var role = cell.hex_data.current_owner
		
		if role == HexData.Owner.WOLF:
			_apply_wolf_passive(cell)
		elif role != HexData.Owner.NEUTRAL:
			cell.hex_data.add_resonance(role, GlobalSettings.REGEN_AMOUNT)
		
		# Tick down active buffs
		_tick_cell_buffs(cell)
		cell._update_visuals()

## New Wolf Regeneration Logic
func _apply_wolf_passive(p_cell: Area2D) -> void:
	# Standard regen is 3.0 (from GlobalSettings updated to 3)
	var regen: float = 3.0 + 3.0 # Wolf Base: 6.0
	var neighbors = get_neighbors(p_cell.hex_data.cube_coords)
	
	for n_coords in neighbors:
		var n_cell = get_cell_at(n_coords)
		if n_cell and n_cell.hex_data.current_owner == HexData.Owner.WOLF:
			regen += 0.5 # Pack Bonus (+3 max)
			
	p_cell.hex_data.add_resonance(HexData.Owner.WOLF, regen)

func _tick_cell_buffs(p_cell: Area2D) -> void:
	for buff in p_cell.active_buffs.keys():
		p_cell.active_buffs[buff] -= 1
		if p_cell.active_buffs[buff] <= 0:
			p_cell.active_buffs.erase(buff)


# --- UTILS ---

func get_neighbors(p_coords: Vector3i) -> Array[Vector3i]:
	var directions = [Vector3i(1,-1,0), Vector3i(1,0,-1), Vector3i(0,1,-1), 
					  Vector3i(-1,1,0), Vector3i(-1,0,1), Vector3i(0,-1,1)]
	var results: Array[Vector3i] = []
	for d in directions: results.append(p_coords + d)
	return results

func get_cell_at(p_coords: Vector3i) -> Area2D:
	return all_cells.get(p_coords, null)
